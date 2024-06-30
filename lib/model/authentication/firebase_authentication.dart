import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/model/storage/online.dart';
import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';
import 'package:open_authenticator/utils/result.dart';

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
  Future<Result> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      return const ResultSuccess();
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }

  /// Deletes the user.
  Future<Result> deleteUser() async {
    try {
      OnlineStorage onlineStorage = await ref.read(onlineStorageProvider.future);
      await onlineStorage.clearTotps();
      await onlineStorage.deleteSecretsSalt();
      await FirebaseAuth.instance.currentUser?.delete();
      return const ResultSuccess();
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }
}
