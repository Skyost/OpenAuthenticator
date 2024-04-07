import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/authentication/provider.dart';

/// The authentication state (logged out / logged in / waiting for confirmation).
sealed class FirebaseAuthenticationState {
  /// Returns the state that corresponds to what's stored in the shared preferences, and to the current user.
  static Future<FirebaseAuthenticationState> get(AsyncNotifierProviderRef ref, {User? user}) async {
    user ??= FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseAuthenticationStateLoggedIn(user: user);
    }

    for (FirebaseAuthenticationProvider provider in FirebaseAuthenticationProvider.availableProviders) {
      if (provider.isAvailable && await provider.isWaitingForConfirmation(ref)) {
        FirebaseAuthenticationStateWaitingForConfirmation? state = await provider.createWaitingForAuthenticationState(ref);
        if (state != null) {
          return state;
        }
      }
    }

    return FirebaseAuthenticationStateLoggedOut();
  }
}

/// When the user is logged out.
class FirebaseAuthenticationStateLoggedOut extends FirebaseAuthenticationState {}

/// When the user is not yet logged in, but a confirmation email has been sent.
class FirebaseAuthenticationStateWaitingForConfirmation extends FirebaseAuthenticationState {
  /// The email, stored in preferences.
  final String email;

  /// Creates a new waiting for confirmation state instance.
  FirebaseAuthenticationStateWaitingForConfirmation({
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
