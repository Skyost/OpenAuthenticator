import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/authentication/state.dart';

/// The Firebase authenticate state provider.
final firebaseAuthenticationProvider = NotifierProvider<FirebaseAuthentication, FirebaseAuthenticationState>(FirebaseAuthentication.new);

/// Allows to get and set the Firebase authentication state.
class FirebaseAuthentication extends Notifier<FirebaseAuthenticationState> {
  @override
  FirebaseAuthenticationState build() {
    StreamSubscription<User?> subscription = FirebaseAuth.instance.userChanges().listen((user) => state = _getState(user: FirebaseAuth.instance.currentUser));
    ref.onDispose(subscription.cancel);
    return _getState(user: FirebaseAuth.instance.currentUser);
  }

  /// Returns the state that corresponds to the [user] instance.
  FirebaseAuthenticationState _getState({User? user}) => user == null ? FirebaseAuthenticationStateLoggedOut() : FirebaseAuthenticationStateLoggedIn(user: user);

  /// Logouts the user.
  Future<void> logout() => FirebaseAuth.instance.signOut();
}
