import 'package:firebase_auth/firebase_auth.dart';

/// The authentication state (logged out / logged in).
sealed class FirebaseAuthenticationState {}

/// When the user is logged out.
class FirebaseAuthenticationStateLoggedOut extends FirebaseAuthenticationState {}

/// When the user is fully logged in.
class FirebaseAuthenticationStateLoggedIn extends FirebaseAuthenticationState {
  /// The user instance.
  final User user;

  /// Creates a new logged in state instance.
  FirebaseAuthenticationStateLoggedIn({
    required this.user,
  });
}
