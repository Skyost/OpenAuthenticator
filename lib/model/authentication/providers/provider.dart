import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/authentication/providers/apple.dart';
import 'package:open_authenticator/model/authentication/providers/email_link.dart';
import 'package:open_authenticator/model/authentication/providers/github.dart';
import 'package:open_authenticator/model/authentication/providers/google.dart';
import 'package:open_authenticator/model/authentication/providers/microsoft.dart';
import 'package:open_authenticator/model/authentication/providers/result.dart';
import 'package:open_authenticator/model/authentication/providers/twitter.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/validation/server.dart';
import 'package:open_authenticator/utils/validation/sign_in/oauth2.dart';

/// Contains all the user authentication providers.
final userAuthenticationProviders = NotifierProvider<UserAuthenticationProviders, List<FirebaseAuthenticationProvider>>(UserAuthenticationProviders.new);

/// The class that handles the listening of authentication providers.
class UserAuthenticationProviders extends Notifier<List<FirebaseAuthenticationProvider>> {
  @override
  List<FirebaseAuthenticationProvider> build() {
    List<FirebaseAuthenticationProvider> providers = [
      ref.watch(emailLinkAuthenticationProvider.notifier),
      ref.watch(googleAuthenticationProvider.notifier),
      ref.watch(appleAuthenticationProvider.notifier),
      ref.watch(microsoftAuthenticationProvider.notifier),
      ref.watch(twitterAuthenticationProvider.notifier),
      ref.watch(githubAuthenticationProvider.notifier),
    ];
    return providers.where((provider) => provider.state is FirebaseAuthenticationStateLoggedIn).toList();
  }

  /// Contains all available authentication providers.
  List<FirebaseAuthenticationProvider> get availableProviders => [
        ref.read(emailLinkAuthenticationProvider.notifier),
        ref.read(googleAuthenticationProvider.notifier),
        ref.read(appleAuthenticationProvider.notifier),
        ref.read(microsoftAuthenticationProvider.notifier),
        ref.read(twitterAuthenticationProvider.notifier),
        ref.read(githubAuthenticationProvider.notifier),
      ].where((provider) => provider.isAvailable).toList();
}

/// Allows to configure Firebase authentication provider.
abstract class FirebaseAuthenticationProvider extends Notifier<FirebaseAuthenticationState> {
  /// The platforms on which this provider is available.
  final List<Platform> availablePlatforms;

  /// Creates a new Firebase authentication provider instance.
  FirebaseAuthenticationProvider({
    required this.availablePlatforms,
  });

  @override
  FirebaseAuthenticationState build() {
    StreamSubscription subscription = FirebaseAuth.instance.userChanges().listen((user) => state = _getState(user));
    ref.onDispose(subscription.cancel);
    return _getState();
  }

  /// Returns whether this provider is linked to the user.
  FirebaseAuthenticationState _getState([User? user]) {
    user ??= FirebaseAuth.instance.currentUser;
    if (user != null) {
      for (UserInfo userInfo in user.providerData) {
        if (userInfo.providerId == providerId) {
          return FirebaseAuthenticationStateLoggedIn(user: user);
        }
      }
    }
    return FirebaseAuthenticationStateLoggedOut();
  }

  /// Returns whether this provider is available for the current platform.
  bool get isAvailable => availablePlatforms.contains(currentPlatform);

  /// Returns the federated provider id.
  String get providerId;

  /// Log-ins the current user.
  Future<FirebaseAuthenticationResult> signIn(BuildContext context) async {
    try {
      return await trySignIn(context);
    } catch (ex, stacktrace) {
      if (kDebugMode) {
        print(ex);
        print(stacktrace);
      }
      if (ex is Exception) {
        return FirebaseAuthenticationError(ex);
      }
    }
    return FirebaseAuthenticationError();
  }

  /// Tries to log in.
  @protected
  Future<FirebaseAuthenticationResult> trySignIn(BuildContext context);

  /// Whether to show the loading dialog.
  bool get showLoadingDialog => true;
}

/// Allows to confirm a login.
mixin ConfirmationProvider<T> on FirebaseAuthenticationProvider {
  /// Returns whether this provider is waiting for confirmation.
  Future<bool> isWaitingForConfirmation() => Future.value(false);

  /// Confirms the log in, with the given [code], if needed.
  Future<FirebaseAuthenticationResult> confirm(T? code) async {
    try {
      return await tryConfirm(code);
    } catch (ex, stacktrace) {
      if (kDebugMode) {
        print(ex);
        print(stacktrace);
      }
      if (ex is Exception) {
        return FirebaseAuthenticationError(ex);
      }
    }
    return FirebaseAuthenticationError();
  }

  /// Tries to confirm the log in, with the given [code], if needed.
  @protected
  Future<FirebaseAuthenticationResult> tryConfirm(T? code);

  /// Cancels the confirmation.
  Future<bool> cancelConfirmation();
}

/// Allows to link an account.
mixin LinkProvider on FirebaseAuthenticationProvider {
  @override
  @protected
  Future<FirebaseAuthenticationResult> trySignIn(BuildContext context) => tryTo(
        context,
        credentialAction: FirebaseAuth.instance.signInWithCredential,
        providerAction: FirebaseAuth.instance.signInWithProvider,
      );

  /// Links the current provider.
  Future<FirebaseAuthenticationResult> link(BuildContext context) async {
    try {
      return await tryLink(context);
    } catch (ex, stacktrace) {
      if (kDebugMode) {
        print(ex);
        print(stacktrace);
      }
      if (ex is Exception) {
        return FirebaseAuthenticationError(ex);
      }
    }
    return FirebaseAuthenticationError();
  }

  /// Tries to link the current provider.
  @protected
  Future<FirebaseAuthenticationResult> tryLink(BuildContext context) => tryTo(
        context,
        credentialAction: FirebaseAuth.instance.currentUser!.linkWithCredential,
        providerAction: FirebaseAuth.instance.currentUser!.linkWithProvider,
      );

  /// Tries to unlink the current provider.
  Future<FirebaseAuthenticationResult> unlink(BuildContext context) async {
    if (FirebaseAuth.instance.currentUser == null) {
      return FirebaseAuthenticationError();
    }
    User user = await FirebaseAuth.instance.currentUser!.unlink(providerId);
    return FirebaseAuthenticationSuccess(email: user.email);
  }

  /// Tries to do the specified [credentialAction] or [providerAction].
  @protected
  Future<FirebaseAuthenticationResult> tryTo(
    BuildContext context, {
    required Future<UserCredential> Function(AuthCredential) credentialAction,
    required Future<UserCredential> Function(AuthProvider) providerAction,
  });
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
  @protected
  Future<FirebaseAuthenticationResult> tryTo(
    BuildContext context, {
    required Future<UserCredential> Function(AuthCredential) credentialAction,
    required Future<UserCredential> Function(AuthProvider) providerAction,
  }) async {
    UserCredential userCredential;
    OAuth2SignIn fallbackAuthProvider = createFallbackAuthProvider();
    if (shouldFallback) {
      ValidationResult<OAuth2Response> result = await fallbackAuthProvider.signIn(context);
      switch(result) {
        case ValidationSuccess(:final object):
          userCredential = await credentialAction(createCredential(object));
          break;
        case ValidationCancelled(:final timedOut):
          return FirebaseAuthenticationCancelled(timedOut: timedOut);
        case ValidationError(:final exception):
          return FirebaseAuthenticationError(exception);
      }
    } else {
      T authProvider = createAuthProvider();
      for (String scope in fallbackAuthProvider.scopes) {
        addScope(authProvider, scope);
      }
      userCredential = await providerAction(authProvider);
    }
    if (userCredential.user == null) {
      return FirebaseAuthenticationError();
    }
    return FirebaseAuthenticationSuccess(email: userCredential.user!.email);
  }

  /// Calls [provider.addScope], if possible.
  void addScope(T provider, String scope);
}
