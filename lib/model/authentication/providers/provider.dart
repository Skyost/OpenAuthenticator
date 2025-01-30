import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/authentication/providers/apple.dart';
import 'package:open_authenticator/model/authentication/providers/email_link.dart';
import 'package:open_authenticator/model/authentication/providers/github.dart';
import 'package:open_authenticator/model/authentication/providers/google.dart';
import 'package:open_authenticator/model/authentication/providers/microsoft.dart';
import 'package:open_authenticator/model/authentication/providers/twitter.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/utils/utils.dart';
import 'package:open_authenticator/utils/validation/sign_in/oauth2.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';

/// Contains all the user authentication providers.
final userAuthenticationProviders = Provider<Map<FirebaseAuthenticationProvider, FirebaseAuthenticationState>>((ref) {
  List<NotifierProvider<FirebaseAuthenticationStateNotifier, FirebaseAuthenticationState>> providers = [
    emailLinkAuthenticationStateProvider,
    googleAuthenticationStateProvider,
    appleAuthenticationStateProvider,
    microsoftAuthenticationStateProvider,
    twitterAuthenticationStateProvider,
    githubAuthenticationStateProvider,
  ];
  Map<FirebaseAuthenticationProvider, FirebaseAuthenticationState> result = {};
  for (NotifierProvider<FirebaseAuthenticationStateNotifier, FirebaseAuthenticationState> provider in providers) {
    FirebaseAuthenticationProvider authenticationProvider = ref.read(provider.notifier)._authenticationProvider;
    result[authenticationProvider] = ref.watch(provider);
  }
  return result;
});

/// Contains various useful fields and methods to use with [userAuthenticationProviders].
extension AuthenticationProvidersUtils on Map<FirebaseAuthenticationProvider, FirebaseAuthenticationState> {
  /// Contains all authentication providers where the user is logged in.
  List<FirebaseAuthenticationProvider> get loggedInProviders => [
        for (MapEntry<FirebaseAuthenticationProvider, FirebaseAuthenticationState> entry in entries)
          if (entry.value is FirebaseAuthenticationStateLoggedIn) entry.key,
      ];

  /// Contains all available authentication providers.
  List<FirebaseAuthenticationProvider> get availableProviders => [
        for (MapEntry<FirebaseAuthenticationProvider, FirebaseAuthenticationState> entry in entries)
          if (entry.key.isAvailable) entry.key,
      ];
}

/// A Firebase authentication state notifier.
class FirebaseAuthenticationStateNotifier<T extends FirebaseAuthenticationProvider> extends Notifier<FirebaseAuthenticationState> {
  /// The authentication provider instance.
  final T _authenticationProvider;

  /// Creates a new Firebase authentication state notifier instance.
  FirebaseAuthenticationStateNotifier(this._authenticationProvider);

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
        if (provider == _authenticationProvider.providerId) {
          return FirebaseAuthenticationStateLoggedIn(user: user);
        }
      }
    }
    return FirebaseAuthenticationStateLoggedOut();
  }
}

/// A Firebase authentication provider.
abstract class FirebaseAuthenticationProvider {
  /// The platforms on which this provider is available.
  final List<Platform> availablePlatforms;

  /// Creates a new Firebase authentication provider instance.
  const FirebaseAuthenticationProvider({
    required this.availablePlatforms,
  });

  /// Returns whether this provider is available for the current platform.
  bool get isAvailable => availablePlatforms.contains(currentPlatform);

  /// Returns the federated provider id.
  String get providerId;

  /// Log-ins the current user.
  Future<Result<AuthenticationObject>> signIn(BuildContext context) async {
    try {
      return await trySignIn(context);
    } catch (ex, stacktrace) {
      return ResultError(
        exception: FirebaseAuthenticationException(ex),
        stacktrace: stacktrace,
      );
    }
  }

  /// Tries to log-in.
  @protected
  Future<Result<AuthenticationObject>> trySignIn(BuildContext context);

  /// Re-authenticates the current user.
  Future<Result<AuthenticationObject>> reAuthenticate(BuildContext context) async {
    try {
      return await tryReAuthenticate(context);
    } catch (ex, stacktrace) {
      return ResultError(
        exception: FirebaseAuthenticationException(ex),
        stacktrace: stacktrace,
      );
    }
  }

  /// Tries to re-authenticate.
  @protected
  Future<Result<AuthenticationObject>> tryReAuthenticate(BuildContext context);

  /// Whether to show the loading dialog.
  bool get showLoadingDialog => true;

  /// Whether this provider should be trusted for a first login.
  bool get isTrusted => true;
}

/// Allows to link an account.
mixin LinkProvider on FirebaseAuthenticationProvider {
  /// Links the current provider.
  Future<Result<AuthenticationObject>> link(BuildContext context) async {
    try {
      return await tryLink(context);
    } catch (ex, stacktrace) {
      return ResultError(
        exception: FirebaseAuthenticationException(ex),
        stacktrace: stacktrace,
      );
    }
  }

  /// Tries to link the current provider.
  @protected
  Future<Result<AuthenticationObject>> tryLink(BuildContext context);

  /// Tries to unlink the current provider.
  Future<Result<AuthenticationObject>> unlink(BuildContext context) async {
    SignInResult result = await FirebaseAuth.instance.unlinkFrom(providerId);
    return ResultSuccess(
      value: AuthenticationObject(
        email: result.email,
      ),
    );
  }
}

/// Allows to authenticate using an OAuth2 provider.
mixin FallbackAuthenticationProvider<T extends OAuth2SignIn> on LinkProvider {
  /// Creates the fallback auth provider.
  T createFallbackAuthProvider();

  /// The fallback provider timeout.
  Duration? get fallbackTimeout => isSubtype<T, OAuth2SignInServer>() ? const Duration(minutes: 5) : null;

  /// Whether we should use a [T] instead of directly calling `method.signIn`.
  bool get shouldFallback => currentPlatform == Platform.windows || currentPlatform == Platform.linux;

  /// Creates the default auth method instance.
  CanLinkTo createDefaultAuthMethod(BuildContext context, {List<String> scopes = const []});

  /// Creates the auth method from the [response].
  CanLinkTo createRestAuthMethod(BuildContext context, OAuth2Response response);

  @override
  @protected
  Future<Result<AuthenticationObject>> trySignIn(BuildContext context) => tryTo(
        context,
        action: FirebaseAuth.instance.signInWith,
      );

  @override
  @protected
  Future<Result<AuthenticationObject>> tryLink(BuildContext context) async {
    if (!FirebaseAuth.instance.isLoggedIn) {
      return const ResultCancelled();
    }
    return await tryTo(
      context,
      action: FirebaseAuth.instance.currentUser!.linkTo,
    );
  }

  @override
  Future<Result<AuthenticationObject>> tryReAuthenticate(BuildContext context) async {
    if (!FirebaseAuth.instance.isLoggedIn) {
      return const ResultCancelled();
    }
    return await tryTo(
      context,
      action: FirebaseAuth.instance.currentUser!.reAuthenticateWith,
    );
  }

  /// Tries to do the specified [action].
  @protected
  Future<Result<AuthenticationObject>> tryTo(
    BuildContext context, {
    required Future<SignInResult> Function(CanLinkTo) action,
  }) async {
    SignInResult actionResult;
    OAuth2SignIn fallbackAuthProvider = createFallbackAuthProvider();
    if (shouldFallback) {
      Result<OAuth2Response> result = await fallbackAuthProvider.signIn(context);
      if (!context.mounted) {
        return const ResultCancelled();
      }
      switch (result) {
        case ResultSuccess(:final value):
          actionResult = await showWaitingOverlay(
            context,
            future: action(createRestAuthMethod(context, value)),
          );
          break;
        case ResultCancelled():
          return ResultCancelled.fromAnother(result);
        case ResultError(:final exception, :final stacktrace):
          return ResultError(
            exception: FirebaseAuthenticationException(exception),
            stacktrace: stacktrace,
          );
      }
    } else {
      actionResult = await showWaitingOverlay(
        context,
        future: action(createDefaultAuthMethod(context, scopes: fallbackAuthProvider.scopes)),
      );
    }
    return ResultSuccess(
      value: AuthenticationObject(
        email: actionResult.email,
      ),
    );
  }
}

/// Returned by authentication methods.
class AuthenticationObject {
  /// The email.
  final String? email;

  /// Creates a new authentication object instance.
  const AuthenticationObject({
    this.email,
  });
}

/// Thrown when there is an error authenticating the user.
sealed class FirebaseAuthenticationException implements Exception {
  /// The exception.
  final Object? exception;

  /// Creates a new Firebase authentication result error instance.
  const FirebaseAuthenticationException._(this.exception);

  /// Creates a new error instance from the given [exception].
  factory FirebaseAuthenticationException([Object? exception]) {
    if (exception is! FirebaseAuthException) {
      return FirebaseAuthenticationGenericError._(exception);
    }
    switch (exception.code) {
      case FirebaseAuthenticationErrorAccountExistsWithDifferentCredential.code:
        return FirebaseAuthenticationErrorAccountExistsWithDifferentCredential._(exception);
      case FirebaseAuthenticationErrorInvalidCredential.code:
        return FirebaseAuthenticationErrorInvalidCredential._(exception);
      case FirebaseAuthenticationErrorOperationNotAllowed.code:
        return FirebaseAuthenticationErrorOperationNotAllowed._(exception);
      case FirebaseAuthenticationErrorUserDisabled.code:
        return FirebaseAuthenticationErrorUserDisabled._(exception);
      default:
        return FirebaseAuthenticationFirebaseError._(exception);
    }
  }
}

/// Returned when there is an error.
class FirebaseAuthenticationGenericError extends FirebaseAuthenticationException {
  /// Creates a new Firebase authentication genetic error instance.
  FirebaseAuthenticationGenericError._(super.exception) : super._();
}

/// Returned when there is a Firebase error.
class FirebaseAuthenticationFirebaseError extends FirebaseAuthenticationException {
  /// Creates a new Firebase authentication Firebase error instance.
  FirebaseAuthenticationFirebaseError._(FirebaseAuthException super.exception) : super._();

  @override
  FirebaseAuthException get exception => super.exception as FirebaseAuthException;
}

/// Returned when "account-exists-with-different-credential" has been triggered.
class FirebaseAuthenticationErrorAccountExistsWithDifferentCredential extends FirebaseAuthenticationFirebaseError {
  /// The error code.
  static const String code = 'account-exists-with-different-credentials';

  /// Creates a new Firebase authentication result error "account-exists-with-different-credential" instance.
  FirebaseAuthenticationErrorAccountExistsWithDifferentCredential._(super.exception) : super._();
}

/// Returned when "invalid-credential" has been triggered.
class FirebaseAuthenticationErrorInvalidCredential extends FirebaseAuthenticationFirebaseError {
  /// The error code.
  static const String code = 'invalid-credential';

  /// Creates a new Firebase authentication result error "invalid-credential" instance.
  FirebaseAuthenticationErrorInvalidCredential._(super.exception) : super._();
}

/// Returned when "operation-not-allowed" has been triggered.
class FirebaseAuthenticationErrorOperationNotAllowed extends FirebaseAuthenticationFirebaseError {
  /// The error code.
  static const String code = 'operation-not-allowed';

  /// Creates a new Firebase authentication result error "operation-not-allowed" instance.
  FirebaseAuthenticationErrorOperationNotAllowed._(super.exception) : super._();
}

/// Returned when "user-disabled" has been triggered.
class FirebaseAuthenticationErrorUserDisabled extends FirebaseAuthenticationFirebaseError {
  /// The error code.
  static const String code = 'user-disabled';

  /// Creates a new Firebase authentication result error "user-disabled" instance.
  FirebaseAuthenticationErrorUserDisabled._(super.exception) : super._();
}
