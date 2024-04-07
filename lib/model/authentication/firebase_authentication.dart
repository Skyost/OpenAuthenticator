import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/authentication/provider.dart';
import 'package:open_authenticator/model/authentication/result.dart';
import 'package:open_authenticator/model/authentication/state.dart';

/// The Firebase authenticate state provider.
final firebaseAuthenticationProvider = AsyncNotifierProvider<FirebaseAuthentication, FirebaseAuthenticationState>(FirebaseAuthentication.new);

/// Allows to get and set the Firebase authentication state.
class FirebaseAuthentication extends AsyncNotifier<FirebaseAuthenticationState> {
  @override
  FutureOr<FirebaseAuthenticationState> build() async {
    StreamSubscription<User?> subscription = FirebaseAuth.instance.userChanges().listen(_reactToUserChanges);
    ref.onDispose(subscription.cancel);
    return await FirebaseAuthenticationState.get(ref);
  }

  /// Reacts to user changes.
  Future<void> _reactToUserChanges(User? user) async {
    state = AsyncData(await FirebaseAuthenticationState.get(ref, user: user));
  }

  /// Tries to log in.
  Future<FirebaseAuthenticationResult> trySignIn(BuildContext context, FirebaseAuthenticationProvider provider) => _tryTo(
        context,
        provider,
        action: provider.trySignIn,
      );

  /// Tries to link the given [provider].
  Future<FirebaseAuthenticationResult> tryLink(BuildContext context, FirebaseAuthenticationProvider provider) => _tryTo(
    context,
    provider,
    action: provider.tryLink,
  );

  /// Tries to unlink the given [provider].
  Future<FirebaseAuthenticationResult> tryUnlink(BuildContext context, FirebaseAuthenticationProvider provider) => _tryTo(
    context,
    provider,
    action: provider.tryUnlink,
  );

  /// Tries to do the specified [action].
  Future<FirebaseAuthenticationResult> _tryTo(
    BuildContext context,
    FirebaseAuthenticationProvider provider, {
    required Future<FirebaseAuthenticationState?> Function(BuildContext, AsyncNotifierProviderRef) action,
  }) async {
    if (!provider.isAvailable) {
      return FirebaseAuthenticationResultError(Exception('${provider.runtimeType} is not available on this platform.'));
    }
    try {
      FirebaseAuthenticationState? authenticationState = await action(context, ref);
      if (authenticationState != null) {
        state = AsyncData(authenticationState);
        return FirebaseAuthenticationResultSuccess();
      }
    } catch (ex, stacktrace) {
      if (kDebugMode) {
        print(ex);
        print(stacktrace);
      }
      if (ex is Exception) {
        return FirebaseAuthenticationResultError(ex);
      }
    }
    return FirebaseAuthenticationResultError();
  }

  /// Tries to confirm the log in.
  Future<bool> tryConfirm(String? code, {FirebaseAuthenticationProvider? provider}) async {
    List<FirebaseAuthenticationProvider> providers = provider == null ? FirebaseAuthenticationProvider.availableProviders : [provider];
    try {
      for (FirebaseAuthenticationProvider provider in providers) {
        if (!provider.isAvailable || !(await provider.isWaitingForConfirmation(ref))) {
          continue;
        }
        FirebaseAuthenticationState? authenticationState = await provider.confirm(ref, code);
        if (authenticationState != null) {
          state = AsyncData(authenticationState);
          return true;
        }
        return false;
      }
    } catch (ex, stacktrace) {
      if (kDebugMode) {
        print(ex);
        print(stacktrace);
      }
    }
    return false;
  }

  /// Logouts the user.
  Future<void> logout() => FirebaseAuth.instance.signOut();
}
