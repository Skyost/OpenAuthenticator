import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';

/// The authentication state (logged out / logged in).
/// The state should be provider independent.
sealed class FirebaseAuthenticationState {}

/// When the user is logged out.
class FirebaseAuthenticationStateLoggedOut extends FirebaseAuthenticationState {}

/// When the email needs to be verified.
class FirebaseAuthenticationStateEmailNeedsVerification extends FirebaseAuthenticationState {
  /// The email.
  final String email;

  /// Creates a new email needs verification state instance.
  FirebaseAuthenticationStateEmailNeedsVerification({
    required this.email,
  });
}

/// When the user is fully logged in.
class FirebaseAuthenticationStateLoggedIn extends FirebaseAuthenticationState {
  /// The user instance.
  final User user;

  /// Creates a new logged in state instance.
  FirebaseAuthenticationStateLoggedIn({
    required this.user,
  });
}
