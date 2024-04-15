import 'dart:async';

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
import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/validation/server.dart';
import 'package:open_authenticator/utils/validation/sign_in/oauth2.dart';

/// Contains all the user authentication providers.
final userAuthenticationProviders = NotifierProvider<UserAuthenticationProviders, List<FirebaseAuthenticationProvider>>(UserAuthenticationProviders.new);

/// The class that handles the listening of authentication providers.
class UserAuthenticationProviders extends Notifier<List<FirebaseAuthenticationProvider>> {
  @override
  List<FirebaseAuthenticationProvider> build() {
    List<NotifierProvider<FirebaseAuthenticationProvider, FirebaseAuthenticationState>> providers = [
      emailLinkAuthenticationProvider,
      googleAuthenticationProvider,
      appleAuthenticationProvider,
      microsoftAuthenticationProvider,
      twitterAuthenticationProvider,
      githubAuthenticationProvider,
    ];
    List<FirebaseAuthenticationProvider> result = [];
    for (NotifierProvider<FirebaseAuthenticationProvider, FirebaseAuthenticationState> provider in providers) {
      FirebaseAuthenticationState state = ref.watch(provider);
      if (state is FirebaseAuthenticationStateLoggedIn) {
        result.add(ref.read(provider.notifier));
      }
    }
    return result;
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
    StreamSubscription subscription = FirebaseAuth.instance.userChanges.listen((user) => state = _getState(user));
    ref.onDispose(subscription.cancel);
    return _getState();
  }

  /// Returns whether this provider is linked to the user.
  FirebaseAuthenticationState _getState([User? user]) {
    user ??= FirebaseAuth.instance.currentUser;
    if (user != null) {
      for (String provider in user.providers) {
        if (provider == providerId) {
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
        action: FirebaseAuth.instance.signInWith,
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
        action: FirebaseAuth.instance.linkTo,
      );

  /// Tries to unlink the current provider.
  Future<FirebaseAuthenticationResult> unlink(BuildContext context) async {
    SignInResult result = await FirebaseAuth.instance.unlinkFrom(providerId);
    return FirebaseAuthenticationSuccess(email: result.email);
  }

  /// Creates the default auth method instance.
  CanLinkTo createDefaultAuthMethod(BuildContext context);

  /// Tries to do the specified [credentialAction] or [providerAction].
  @protected
  Future<FirebaseAuthenticationResult> tryTo(
    BuildContext context, {
    required Future<SignInResult> Function(CanLinkTo) action,
  }) async {
    SignInResult result = await action(createDefaultAuthMethod(context));
    return FirebaseAuthenticationSuccess(email: result.email);
  }
}

/// Allows to authenticate using an OAuth2 provider.
mixin FallbackAuthenticationProvider<T extends OAuth2SignIn> on LinkProvider {
  /// Creates the fallback auth provider.
  T createFallbackAuthProvider();

  /// The fallback provider timeout.
  Duration? get fallbackTimeout => T is OAuth2SignInServer ? const Duration(minutes: 5) : null;

  /// Whether we should use a [T] instead of directly calling `method.signIn`.
  bool get shouldFallback => currentPlatform == Platform.windows || currentPlatform == Platform.linux;

  @override
  CanLinkTo createDefaultAuthMethod(BuildContext context, {List<String> scopes = const []});

  /// Creates the auth method from the [response].
  CanLinkTo createRestAuthMethod(BuildContext context, OAuth2Response response);

  @override
  @protected
  Future<FirebaseAuthenticationResult> tryTo(
    BuildContext context, {
    required Future<SignInResult> Function(CanLinkTo) action,
  }) async {
    SignInResult actionResult;
    OAuth2SignIn fallbackAuthProvider = createFallbackAuthProvider();
    if (shouldFallback) {
      ValidationResult<OAuth2Response> result = await fallbackAuthProvider.signIn(context);
      if (!context.mounted) {
        return FirebaseAuthenticationCancelled();
      }
      switch (result) {
        case ValidationSuccess(:final object):
          actionResult = await action(createRestAuthMethod(context, object));
          break;
        case ValidationCancelled(:final timedOut):
          return FirebaseAuthenticationCancelled(timedOut: timedOut);
        case ValidationError(:final exception):
          return FirebaseAuthenticationError(exception);
      }
    } else {
      actionResult = await action(createDefaultAuthMethod(context, scopes: fallbackAuthProvider.scopes));
    }
    return FirebaseAuthenticationSuccess(email: actionResult.email);
  }
}
