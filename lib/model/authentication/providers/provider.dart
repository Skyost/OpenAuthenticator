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
import 'package:open_authenticator/utils/validation/sign_in/oauth2.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';

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
  Future<Result<String>> signIn(BuildContext context) async {
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
  Future<Result<String>> trySignIn(BuildContext context);

  /// Re-authenticates the current user.
  Future<Result<String>> reAuthenticate(BuildContext context) async {
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
  Future<Result<String>> tryReAuthenticate(BuildContext context);

  /// Whether to show the loading dialog.
  bool get showLoadingDialog => true;

  /// Whether this provider should be trusted for a first login.
  bool get isTrusted => true;
}

/// Allows to confirm a login.
mixin ConfirmationProvider<T> on FirebaseAuthenticationProvider {
  /// Returns whether this provider is waiting for confirmation.
  Future<bool> isWaitingForConfirmation() => Future.value(false);

  /// Confirms the log in, with the given [code], if needed.
  Future<Result<String>> confirm(BuildContext context, T? code) async {
    try {
      return await tryConfirm(context, code);
    } catch (ex, stacktrace) {
      return ResultError(
        exception: FirebaseAuthenticationException(ex),
        stacktrace: stacktrace,
      );
    }
  }

  /// Tries to confirm the log in, with the given [code], if needed.
  @protected
  Future<Result<String>> tryConfirm(BuildContext context, T? code);

  /// Cancels the confirmation.
  Future<Result> cancelConfirmation();
}

/// Allows to link an account.
mixin LinkProvider on FirebaseAuthenticationProvider {
  /// Links the current provider.
  Future<Result<String>> link(BuildContext context) async {
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
  Future<Result<String>> tryLink(BuildContext context);

  /// Tries to unlink the current provider.
  Future<Result<String>> unlink(BuildContext context) async {
    SignInResult result = await FirebaseAuth.instance.unlinkFrom(providerId);
    return ResultSuccess(value: result.email);
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

  /// Creates the default auth method instance.
  CanLinkTo createDefaultAuthMethod(BuildContext context, {List<String> scopes = const []});

  /// Creates the auth method from the [response].
  CanLinkTo createRestAuthMethod(BuildContext context, OAuth2Response response);

  @override
  @protected
  Future<Result<String>> trySignIn(BuildContext context) => tryTo(
        context,
        action: FirebaseAuth.instance.signInWith,
      );

  @override
  @protected
  Future<Result<String>> tryLink(BuildContext context) async {
    if (!FirebaseAuth.instance.isLoggedIn) {
      return const ResultCancelled();
    }
    return await tryTo(
      context,
      action: FirebaseAuth.instance.currentUser!.linkTo,
    );
  }

  @override
  Future<Result<String>> tryReAuthenticate(BuildContext context) async {
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
  Future<Result<String>> tryTo(
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
    return ResultSuccess(value: actionResult.email);
  }
}

/// Thrown when there is an error authenticating the user.
sealed class FirebaseAuthenticationException implements Exception {
  /// The exception.
  final Object? exception;

  /// Creates a new Firebase authentication result error instance.
  FirebaseAuthenticationException._(this.exception);

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
