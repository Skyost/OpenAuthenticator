import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/app_unlock/method.dart';
import 'package:open_authenticator/model/settings/app_unlock_method.dart';

/// The app unlock state state provider.
final appUnlockStateProvider = AsyncNotifierProvider<AppUnlockState, bool>(AppUnlockState.new);

/// Allows to get and set the app unlock state.
class AppUnlockState extends AsyncNotifier<bool> {
  @override
  FutureOr<bool> build() => Future.value(false);

  /// Tries to unlock the app.
  Future<bool> tryUnlock(
    BuildContext context, {
    UnlockReason unlockReason = UnlockReason.openApp
  }) async {
    if (await future) {
      return true;
    }
    AppUnlockMethod unlockMethod = await ref.read(appUnlockMethodSettingsEntryProvider.future);
    if (context.mounted && await unlockMethod.tryUnlock(context, ref, unlockReason)) {
      state = const AsyncData(true);
      return true;
    }
    return false;
  }
}
