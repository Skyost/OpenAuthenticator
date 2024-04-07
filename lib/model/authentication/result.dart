import 'package:firebase_auth/firebase_auth.dart';

/// Returned after [FirebaseAuthentication.trySignIn].
sealed class FirebaseAuthenticationResult {}

/// Returned when the operation is a success.
class FirebaseAuthenticationResultSuccess extends FirebaseAuthenticationResult {}

/// Returned when there is an error.
class FirebaseAuthenticationResultError extends FirebaseAuthenticationResult {
  /// The exception.
  final Exception? exception;

  /// Creates a new Firebase authentication result error instance.
  FirebaseAuthenticationResultError._(this.exception);

  /// Creates a new error instance from the given [exception].
  factory FirebaseAuthenticationResultError([Exception? exception]) {
    if (exception is! FirebaseAuthException) {
      return FirebaseAuthenticationResultError._(exception);
    }
    switch (exception.code) {
      case FirebaseAuthenticationResultErrorAccountExistsWithDifferentCredential.code:
        return FirebaseAuthenticationResultErrorAccountExistsWithDifferentCredential._(exception);
      case FirebaseAuthenticationResultErrorInvalidCredential.code:
        return FirebaseAuthenticationResultErrorInvalidCredential._(exception);
      case FirebaseAuthenticationResultErrorOperationNotAllowed.code:
        return FirebaseAuthenticationResultErrorOperationNotAllowed._(exception);
      case FirebaseAuthenticationResultErrorUserDisabled.code:
        return FirebaseAuthenticationResultErrorUserDisabled._(exception);
      default:
        return FirebaseAuthenticationResultFirebaseError._(exception);
    }
  }
}

/// Returned when there is a Firebase error.
class FirebaseAuthenticationResultFirebaseError extends FirebaseAuthenticationResultError {
  /// Creates a new Firebase authentication result error instance.
  FirebaseAuthenticationResultFirebaseError._(FirebaseAuthException super.exception) : super._();

  @override
  FirebaseAuthException get exception => super.exception as FirebaseAuthException;
}

/// Returned when "account-exists-with-different-credential" has been triggered.
class FirebaseAuthenticationResultErrorAccountExistsWithDifferentCredential extends FirebaseAuthenticationResultFirebaseError {
  /// The error code.
  static const String code = 'account-exists-with-different-credentials';

  /// Creates a new Firebase authentication result error "account-exists-with-different-credential" instance.
  FirebaseAuthenticationResultErrorAccountExistsWithDifferentCredential._(super.exception) : super._();
}

/// Returned when "invalid-credential" has been triggered.
class FirebaseAuthenticationResultErrorInvalidCredential extends FirebaseAuthenticationResultFirebaseError {
  /// The error code.
  static const String code = 'invalid-credential';

  /// Creates a new Firebase authentication result error "invalid-credential" instance.
  FirebaseAuthenticationResultErrorInvalidCredential._(super.exception) : super._();
}

/// Returned when "operation-not-allowed" has been triggered.
class FirebaseAuthenticationResultErrorOperationNotAllowed extends FirebaseAuthenticationResultFirebaseError {
  /// The error code.
  static const String code = 'operation-not-allowed';

  /// Creates a new Firebase authentication result error "operation-not-allowed" instance.
  FirebaseAuthenticationResultErrorOperationNotAllowed._(super.exception) : super._();
}

/// Returned when "user-disabled" has been triggered.
class FirebaseAuthenticationResultErrorUserDisabled extends FirebaseAuthenticationResultFirebaseError {
  /// The error code.
  static const String code = 'user-disabled';

  /// Creates a new Firebase authentication result error "user-disabled" instance.
  FirebaseAuthenticationResultErrorUserDisabled._(super.exception) : super._();
}
