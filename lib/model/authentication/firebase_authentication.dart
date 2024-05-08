import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/model/settings/entry.dart';
import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The Firebase authenticate state provider.
final firebaseAuthenticationProvider = NotifierProvider<FirebaseAuthentication, FirebaseAuthenticationState>(FirebaseAuthentication.new);

/// Allows to get and set the Firebase authentication state.
class FirebaseAuthentication extends Notifier<FirebaseAuthenticationState> {
  @override
  FirebaseAuthenticationState build() {
    StreamSubscription<User?> subscription = FirebaseAuth.instance.userChanges.listen((user) => state = _getState(user: FirebaseAuth.instance.currentUser));
    ref.onDispose(subscription.cancel);
    return _getState(user: FirebaseAuth.instance.currentUser);
  }

  /// Returns the state that corresponds to the [user] instance.
  FirebaseAuthenticationState _getState({User? user}) => user == null ? FirebaseAuthenticationStateLoggedOut() : FirebaseAuthenticationStateLoggedIn(user: user);

  /// Logouts the user.
  Future<void> logout() => FirebaseAuth.instance.signOut();
}

/// The Firebase user id provider.
final firebaseUserIdProvider = AsyncNotifierProvider<FirebaseUserId, String?>(FirebaseUserId.new);

/// The Firebase user id notifier.
/// Allows to get the current user id, or to read it from the cache.
class FirebaseUserId extends AsyncNotifier<String?> {
  /// The user id preferences key.
  static const String _kUserIdKey = 'userId';

  @override
  Future<String?> build() async {
    StreamSubscription<User?> subscription = FirebaseAuth.instance.userChanges.listen(_onUserChanged);
    ref.onDispose(subscription.cancel);
    return await _getFromUserOrCache(FirebaseAuth.instance.currentUser);
  }

  /// Triggered when the user has changed.
  Future<void> _onUserChanged(User? user) async {
    SharedPreferences sharedPreferences = await ref.read(sharedPreferencesProvider.future);
    if (user == null) {
      sharedPreferences.remove(_kUserIdKey);
    } else {
      sharedPreferences.setString(_kUserIdKey, user.uid);
    }
    state = AsyncData(user?.uid);
  }

  /// Returns the user id from the current user or from the cache.
  Future<String?> _getFromUserOrCache(User? user) async {
    print(user);
    if (user != null) {
      return user.uid;
    }
    SharedPreferences sharedPreferences = await ref.read(sharedPreferencesProvider.future);
    return sharedPreferences.getString(_kUserIdKey);
  }
}
