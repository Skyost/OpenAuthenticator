import 'package:firebase_auth/firebase_auth.dart';

/// Returned after [FirebaseAuthentication.trySignIn].
sealed class FirebaseAuthenticationResult {}

/// Returned when the operation is a success.
class FirebaseAuthenticationSuccess extends FirebaseAuthenticationResult {
  /// The logged-in user email.
  final String? email;

  /// Creates a new Firebase authentication result success instance.
  FirebaseAuthenticationSuccess({
    required this.email,
  });
}

/// Returned when the operation has been cancelled.
class FirebaseAuthenticationCancelled extends FirebaseAuthenticationResult {
  /// Whether this is the result of a timeout.
  final bool timedOut;

  /// Creates a new Firebase authentication result cancelled instance.
  FirebaseAuthenticationCancelled({
    this.timedOut = false,
  });
}

/// Returned when there is an error.
class FirebaseAuthenticationError extends FirebaseAuthenticationResult {
  /// The exception.
  final Exception? exception;

  /// Creates a new Firebase authentication result error instance.
  FirebaseAuthenticationError._(this.exception);

  /// Creates a new error instance from the given [exception].
  factory FirebaseAuthenticationError([Exception? exception]) {
    if (exception is! FirebaseAuthException) {
      return FirebaseAuthenticationError._(exception);
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

/// Returned when there is a Firebase error.
class FirebaseAuthenticationFirebaseError extends FirebaseAuthenticationError {
  /// Creates a new Firebase authentication result error instance.
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
