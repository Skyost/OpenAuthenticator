import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/model/settings/entry.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/validation/server.dart';
import 'package:open_authenticator/utils/validation/sign_in/email_link.dart';
import 'package:open_authenticator/utils/validation/sign_in/github.dart';
import 'package:open_authenticator/utils/validation/sign_in/google.dart';
import 'package:open_authenticator/utils/validation/sign_in/microsoft.dart';
import 'package:open_authenticator/utils/validation/sign_in/oauth2.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';
import 'package:open_authenticator/widgets/dialog/waiting_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Contains all the user authentication providers.
final userAuthenticationProviders = NotifierProvider<UserAuthenticationProviders, List<FirebaseAuthenticationProvider>>(UserAuthenticationProviders.new);

/// The class that handles the listening of authentication providers.
class UserAuthenticationProviders extends Notifier<List<FirebaseAuthenticationProvider>> {
  @override
  List<FirebaseAuthenticationProvider> build() {
    Stream<List<FirebaseAuthenticationProvider>> stream = FirebaseAuth.instance.userChanges().map(getUserLinkedProviders);
    StreamSubscription subscription = stream.listen((value) => state = value);
    ref.onDispose(subscription.cancel);
    return getUserLinkedProviders();
  }

  List<FirebaseAuthenticationProvider> getUserLinkedProviders([User? user]) {
    user ??= FirebaseAuth.instance.currentUser;
    List<FirebaseAuthenticationProvider> linkedProviders = [];
    if (user == null) {
      return linkedProviders;
    }
    for (FirebaseAuthenticationProvider provider in FirebaseAuthenticationProvider.availableProviders) {
      for (UserInfo userInfo in user.providerData) {
        if (userInfo.providerId == provider.providerId) {
          linkedProviders.add(provider);
          break;
        }
      }
    }
    return linkedProviders;
  }
}

/// Allows to configure Firebase authentication provider.
sealed class FirebaseAuthenticationProvider {
  /// The available providers.
  static final List<FirebaseAuthenticationProvider> availableProviders = [
    for (FirebaseAuthenticationProvider provider in [
      const EmailLinkAuthenticationProvider._(),
      const GoogleAuthenticationProvider._(),
      const AppleAuthenticationProvider._(),
      const MicrosoftAuthenticationProvider._(),
      const TwitterAuthenticationProvider._(),
      const GithubAuthenticationProvider._(),
    ])
      if (provider.isAvailable) provider,
  ];

  /// The platforms on which this provider is available.
  final List<Platform> availablePlatforms;

  /// Whether a confirmation is needed.
  final bool confirmationNeeded;

  /// Creates a new Firebase authentication provider instance.
  const FirebaseAuthenticationProvider._({
    required this.availablePlatforms,
    this.confirmationNeeded = false,
  });

  /// Returns whether this provider is available for the current platform.
  bool get isAvailable => availablePlatforms.contains(currentPlatform);

  /// Returns the federated provider id.
  String get providerId;

  /// Tries to log in.
  Future<FirebaseAuthenticationState?> trySignIn(BuildContext context, AsyncNotifierProviderRef ref);

  /// Whether to show the loading dialog.
  bool get showLoadingDialog => true;
}

/// Allows to authenticate using an OAuth2 provider.
mixin OAuth2AuthenticationProvider<T extends AuthProvider> on LinkProvider {
  /// Creates the Firebase [AuthProvider].
  T createAuthProvider();

  /// Creates the fallback auth provider.
  OAuth2SignIn createFallbackAuthProvider();

  /// Creates the [AuthCredential] that corresponds to the [OAuth2Credentials].
  AuthCredential createCredential(OAuth2Response response);

  /// The fallback provider timeout.
  Duration? get fallbackTimeout => T is OAuth2SignInServer ? const Duration(minutes: 5) : null;

  /// Whether we should use an [OAuth2SignIn] instead of an [AuthCredential].
  bool get shouldFallback => currentPlatform == Platform.windows || currentPlatform == Platform.linux;

  @override
  Future<FirebaseAuthenticationState?> _tryTo(
    BuildContext context,
    AsyncNotifierProviderRef ref, {
    required Future<UserCredential> Function(AuthCredential) credentialAction,
    required Future<UserCredential> Function(AuthProvider) providerAction,
  }) async {
    UserCredential userCredential;
    OAuth2SignIn fallbackAuthProvider = createFallbackAuthProvider();
    if (shouldFallback) {
      OAuth2Response? response = await fallbackAuthProvider.signIn(context);
      if (response == null) {
        return null;
      }
      userCredential = await credentialAction(createCredential(response));
    } else {
      T authProvider = createAuthProvider();
      for (String scope in fallbackAuthProvider.scopes) {
        addScope(authProvider, scope);
      }
      userCredential = await providerAction(authProvider);
    }
    if (userCredential.user == null) {
      return null;
    }
    return FirebaseAuthenticationStateLoggedIn(user: userCredential.user!);
  }

  /// Calls [provider.addScope], if possible.
  void addScope(T provider, String scope);
}

/// Allows to confirm a login.
mixin ConfirmationProvider<T> on FirebaseAuthenticationProvider {
  /// Returns whether this provider is waiting for confirmation.
  Future<bool> isWaitingForConfirmation(AsyncNotifierProviderRef ref) => Future.value(false);

  /// Creates the [FirebaseAuthenticationStateWaitingForConfirmation] if [isWaitingForConfirmation] is true.
  Future<FirebaseAuthenticationStateWaitingForConfirmation?> createWaitingForAuthenticationState(AsyncNotifierProviderRef ref) => Future.value(null);

  /// Confirms the log in, with the given [code], if needed.
  Future<FirebaseAuthenticationState?> confirm(AsyncNotifierProviderRef ref, T? code) =>
      Future.value(FirebaseAuth.instance.currentUser == null ? null : FirebaseAuthenticationStateLoggedIn(user: FirebaseAuth.instance.currentUser!));

  /// Cancels the confirmation.
  Future<bool> cancelConfirmation(AsyncNotifierProviderRef ref);
}

/// Allows to link an account.
mixin LinkProvider on FirebaseAuthenticationProvider {
  /// Tries to log in.
  Future<FirebaseAuthenticationState?> trySignIn(BuildContext context, AsyncNotifierProviderRef ref) => _tryTo(
        context,
        ref,
        credentialAction: FirebaseAuth.instance.signInWithCredential,
        providerAction: FirebaseAuth.instance.signInWithProvider,
      );

  /// Tries to link the current provider.
  Future<FirebaseAuthenticationState?> tryLink(BuildContext context, AsyncNotifierProviderRef ref) => _tryTo(
        context,
        ref,
        credentialAction: FirebaseAuth.instance.currentUser!.linkWithCredential,
        providerAction: FirebaseAuth.instance.currentUser!.linkWithProvider,
      );

  /// Tries to unlink the current provider.
  Future<FirebaseAuthenticationState?> tryUnlink(BuildContext context, AsyncNotifierProviderRef ref) async {
    if (FirebaseAuth.instance.currentUser == null) {
      return FirebaseAuthenticationStateLoggedOut();
    }
    await FirebaseAuth.instance.currentUser!.unlink(providerId);
    return FirebaseAuth.instance.currentUser == null
        ? FirebaseAuthenticationStateLoggedOut()
        : FirebaseAuthenticationStateLoggedIn(
            user: FirebaseAuth.instance.currentUser!,
          );
  }

  /// Tries to do the specified [credentialAction] or [providerAction].
  Future<FirebaseAuthenticationState?> _tryTo(
    BuildContext context,
    AsyncNotifierProviderRef ref, {
    required Future<UserCredential> Function(AuthCredential) credentialAction,
    required Future<UserCredential> Function(AuthProvider) providerAction,
  });
}

/// The email link authentication provider.
class EmailLinkAuthenticationProvider extends FirebaseAuthenticationProvider with ConfirmationProvider<String> {
  /// The preferences key where the email is temporally stored.
  static const String _kFirebaseAuthenticationEmailKey = 'firebaseAuthenticationEmail';

  /// Creates a new email link authentication provider instance.
  const EmailLinkAuthenticationProvider._()
      : super._(
          availablePlatforms: const [
            Platform.android,
            Platform.iOS,
            Platform.macOS,
            Platform.windows,
          ],
        );

  @override
  bool get showLoadingDialog => currentPlatform != Platform.windows;

  @override
  Future<FirebaseAuthenticationState?> trySignIn(BuildContext context, AsyncNotifierProviderRef ref) async {
    String? email = await TextInputDialog.prompt(
      context,
      title: translations.authentication.emailDialog.title,
      message: translations.authentication.emailDialog.message,
      validator: TextInputDialog.validateEmail,
      keyboardType: TextInputType.emailAddress,
    );
    if (email == null || !context.mounted) {
      return null;
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    ActionCodeSettings actionCodeSettings = ActionCodeSettings(
      url: App.firebaseLoginUrl,
      handleCodeInApp: true,
      androidPackageName: packageInfo.packageName,
      iOSBundleId: packageInfo.packageName,
    );
    if (currentPlatform == Platform.windows) {
      EmailLinkSignIn emailLinkSignIn = EmailLinkSignIn(email: email);
      OAuth2Response? response;
      if (context.mounted) {
        response = await showWaitingOverlay(
          context,
          future: emailLinkSignIn.sendSignInLinkToEmail(actionCodeSettings),
          message: translations.authentication.logIn.waitingDialogMessage,
        );
      } else {
        response = await emailLinkSignIn.sendSignInLinkToEmail(actionCodeSettings);
      }
      if (response != null) {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(
          GoogleAuthProvider.credential(idToken: response.idToken),
        );
        if (userCredential.user != null) {
          return FirebaseAuthenticationStateLoggedIn(user: userCredential.user!);
        }
      }
    } else {
      await FirebaseAuth.instance.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );
    }
    SharedPreferences preferences = await ref.read(sharedPreferencesProvider.future);
    await preferences.setString(_kFirebaseAuthenticationEmailKey, email);
    return FirebaseAuthenticationStateWaitingForConfirmation(email: email);
  }

  @override
  Future<bool> isWaitingForConfirmation(AsyncNotifierProviderRef ref) async {
    SharedPreferences preferences = await ref.read(sharedPreferencesProvider.future);
    return preferences.getString(_kFirebaseAuthenticationEmailKey) != null;
  }

  @override
  Future<bool> cancelConfirmation(AsyncNotifierProviderRef ref) async {
    SharedPreferences preferences = await ref.read(sharedPreferencesProvider.future);
    return await preferences.remove(_kFirebaseAuthenticationEmailKey);
  }

  @override
  Future<FirebaseAuthenticationStateWaitingForConfirmation?> createWaitingForAuthenticationState(AsyncNotifierProviderRef ref) async {
    SharedPreferences preferences = await ref.read(sharedPreferencesProvider.future);
    String? email = preferences.getString(_kFirebaseAuthenticationEmailKey);
    return email == null ? null : FirebaseAuthenticationStateWaitingForConfirmation(email: email);
  }

  @override
  Future<FirebaseAuthenticationState?> confirm(AsyncNotifierProviderRef ref, String? emailLink) async {
    SharedPreferences preferences = await ref.read(sharedPreferencesProvider.future);
    if (emailLink == null || !FirebaseAuth.instance.isSignInWithEmailLink(emailLink)) {
      return null;
    }
    UserCredential userCredential;
    String email = preferences.getString(_kFirebaseAuthenticationEmailKey)!;
    if (currentPlatform == Platform.windows) {
      ValidationObject<OAuth2Response> result = await EmailLinkSignIn(email: email).validateUrl(emailLink);
      if (result is! ValidationSuccess || result.object?.idToken == null) {
        return null;
      }
      userCredential = await FirebaseAuth.instance.signInWithCredential(
        GoogleAuthProvider.credential(idToken: result.object!.idToken),
      );
    } else {
      userCredential = await FirebaseAuth.instance.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );
    }
    if (userCredential.user == null) {
      return null;
    }
    await preferences.remove(_kFirebaseAuthenticationEmailKey);
    return FirebaseAuthenticationStateLoggedIn(user: userCredential.user!);
  }

  @override
  String get providerId => EmailAuthProvider.EMAIL_LINK_SIGN_IN_METHOD;
}

/// The Google authentication provider.
class GoogleAuthenticationProvider extends FirebaseAuthenticationProvider with LinkProvider, OAuth2AuthenticationProvider<GoogleAuthProvider> {
  /// Creates a new Google authentication provider instance.
  const GoogleAuthenticationProvider._()
      : super._(
          availablePlatforms: const [
            Platform.android,
            Platform.iOS,
            Platform.macOS,
            Platform.windows,
          ],
          confirmationNeeded: false,
        );

  @override
  GoogleAuthProvider createAuthProvider() => GoogleAuthProvider();

  @override
  OAuth2SignIn createFallbackAuthProvider() => GoogleSignIn(
        clientId: AppCredentials.googleSignInClientId,
        timeout: fallbackTimeout,
      );

  @override
  AuthCredential createCredential(OAuth2Response response) => GoogleAuthProvider.credential(
        idToken: response.idToken,
        accessToken: response.accessToken,
      );

  @override
  void addScope(GoogleAuthProvider provider, String scope) => provider.addScope(scope);

  @override
  String get providerId => GoogleAuthProvider.PROVIDER_ID;
}

/// The Apple authentication provider.
class AppleAuthenticationProvider extends FirebaseAuthenticationProvider with LinkProvider {
  /// Creates a new Apple authentication provider instance.
  const AppleAuthenticationProvider._()
      : super._(
          availablePlatforms: const [
            Platform.android,
            Platform.iOS,
            Platform.macOS,
          ],
          confirmationNeeded: false,
        );

  @override
  Future<FirebaseAuthenticationState?> _tryTo(
    BuildContext context,
    AsyncNotifierProviderRef ref, {
    required Future<UserCredential> Function(AuthCredential) credentialAction,
    required Future<UserCredential> Function(AuthProvider) providerAction,
  }) async {
    AppleAuthProvider appleProvider = AppleAuthProvider();
    appleProvider.addScope('email');
    // appleProvider.setCustomParameters({
    //   'locale': 'fr',
    // });
    UserCredential userCredential = await providerAction(appleProvider);
    if (userCredential.user == null) {
      return null;
    }
    return FirebaseAuthenticationStateLoggedIn(user: userCredential.user!);
  }

  @override
  String get providerId => AppleAuthProvider.PROVIDER_ID;
}

/// The Microsoft authentication provider.
class MicrosoftAuthenticationProvider extends FirebaseAuthenticationProvider with LinkProvider, OAuth2AuthenticationProvider<MicrosoftAuthProvider> {
  /// Creates a new Microsoft authentication provider instance.
  const MicrosoftAuthenticationProvider._()
      : super._(
          availablePlatforms: const [
            Platform.android,
            Platform.iOS,
            Platform.macOS,
            Platform.windows,
          ],
          confirmationNeeded: false,
        );

  @override
  MicrosoftAuthProvider createAuthProvider() => MicrosoftAuthProvider();

  @override
  OAuth2SignIn createFallbackAuthProvider() => MicrosoftSignIn(
        clientId: AppCredentials.azureSignInClientId,
        timeout: fallbackTimeout,
      );

  @override
  AuthCredential createCredential(OAuth2Response response) => OAuthProvider(MicrosoftAuthProvider.PROVIDER_ID).credential(
        signInMethod: MicrosoftAuthProvider.MICROSOFT_SIGN_IN_METHOD,
        accessToken: response.accessToken,
        idToken: response.idToken,
        rawNonce: response.nonce,
      );

  @override
  void addScope(MicrosoftAuthProvider provider, String scope) => provider.addScope(scope);

  @override
  String get providerId => MicrosoftAuthProvider.PROVIDER_ID;
}

/// The Twitter authentication provider.
class TwitterAuthenticationProvider extends FirebaseAuthenticationProvider with LinkProvider {
  /// Creates a new Twitter authentication provider instance.
  const TwitterAuthenticationProvider._()
      : super._(
          availablePlatforms: const [
            Platform.android,
            Platform.iOS,
            Platform.macOS,
          ],
          confirmationNeeded: false,
        );

  @override
  Future<FirebaseAuthenticationState?> _tryTo(
    BuildContext context,
    AsyncNotifierProviderRef ref, {
    required Future<UserCredential> Function(AuthCredential) credentialAction,
    required Future<UserCredential> Function(AuthProvider) providerAction,
  }) async {
    TwitterAuthProvider twitterAuthProvider = TwitterAuthProvider();
    // appleProvider.setCustomParameters({
    //   'lang': 'fr',
    // });
    UserCredential userCredential = await providerAction(twitterAuthProvider);
    if (userCredential.user == null) {
      return null;
    }
    return FirebaseAuthenticationStateLoggedIn(user: userCredential.user!);
  }

  @override
  String get providerId => TwitterAuthProvider.PROVIDER_ID;
}

/// The Github authentication provider.
class GithubAuthenticationProvider extends FirebaseAuthenticationProvider with LinkProvider, OAuth2AuthenticationProvider<GithubAuthProvider> {
  /// Creates a new Github authentication provider instance.
  const GithubAuthenticationProvider._()
      : super._(
          availablePlatforms: const [
            Platform.android,
            Platform.iOS,
            Platform.macOS,
            Platform.windows,
          ],
          confirmationNeeded: false,
        );

  @override
  GithubAuthProvider createAuthProvider() => GithubAuthProvider();

  @override
  OAuth2SignIn createFallbackAuthProvider() => GithubSignIn(
        clientId: AppCredentials.githubSignInClientId,
      );

  @override
  AuthCredential createCredential(OAuth2Response response) => OAuthProvider(GithubAuthProvider.PROVIDER_ID).credential(
        signInMethod: GithubAuthProvider.GITHUB_SIGN_IN_METHOD,
        accessToken: response.accessToken,
        idToken: '',
      );

  @override
  void addScope(GithubAuthProvider provider, String scope) => provider.addScope(scope);

  @override
  String get providerId => GithubAuthProvider.PROVIDER_ID;
}
