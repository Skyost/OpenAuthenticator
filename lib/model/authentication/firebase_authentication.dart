import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';
import 'package:open_authenticator/utils/result.dart';

/// The Firebase authenticate state provider.
final firebaseAuthenticationProvider = NotifierProvider<FirebaseAuthentication, FirebaseAuthenticationState>(FirebaseAuthentication.new);

/// Allows to get and set the Firebase authentication state.
class FirebaseAuthentication extends Notifier<FirebaseAuthenticationState> {
  @override
  FirebaseAuthenticationState build() {
    StreamSubscription<User?> subscription = FirebaseAuth.instance.userChanges.listen((user) => state = _getState(user: user));
    ref.onDispose(subscription.cancel);
    return _getState();
  }

  /// Returns the state that corresponds to the [user] instance.
  FirebaseAuthenticationState _getState({User? user}) {
    user ??= FirebaseAuth.instance.currentUser;
    if (user == null) {
      return FirebaseAuthenticationStateLoggedOut();
    }
    return user.emailVerified ? FirebaseAuthenticationStateLoggedIn(user: user) : FirebaseAuthenticationStateEmailNeedsVerification(email: user.email);
  }

  /// Sends a verification email.
  Future<Result> sendVerificationEmail() async {
    try {
      if (state is! FirebaseAuthenticationStateEmailNeedsVerification) {
        return const ResultCancelled();
      }
      await FirebaseAuth.instance.sendVerificationEmail();
      return const ResultSuccess();
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }

  /// Verifies the user's email.
  Future<Result<String>> verifyEmail(String oobCode) async {
    try {
      if (state is! FirebaseAuthenticationStateEmailNeedsVerification) {
        return const ResultCancelled();
      }
      bool result = await FirebaseAuth.instance.currentUser!.verifyEmail(oobCode);
      if (!result) {
        throw Exception('Unable to verify account.');
      }
      return ResultSuccess(value: FirebaseAuth.instance.currentUser!.email);
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }

  /// Refreshes the current user.
  Future<Result> refreshUser() async {
    try {
      if (state is FirebaseAuthenticationStateLoggedOut) {
        return const ResultCancelled();
      }
      await FirebaseAuth.instance.currentUser!.reload();
      return const ResultSuccess();
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }

  /// Logouts the user.
  Future<Result> logout() async {
    try {
      if (state is FirebaseAuthenticationStateLoggedOut) {
        return const ResultCancelled();
      }
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
      if (state is FirebaseAuthenticationStateLoggedOut) {
        return const ResultCancelled();
      }
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
