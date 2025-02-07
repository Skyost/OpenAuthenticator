import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/app_unlock/method.dart';
import 'package:open_authenticator/model/settings/app_unlock_method.dart';
import 'package:open_authenticator/utils/result.dart';

/// The app unlock state state provider.
final appLockStateProvider = AsyncNotifierProvider<AppLockStateNotifier, AppLockState>(AppLockStateNotifier.new);

/// Allows to get and set the app unlocked state.
class AppLockStateNotifier extends AsyncNotifier<AppLockState> {
  @override
  FutureOr<AppLockState> build() async {
    AppUnlockMethod unlockMethod = await ref.watch(appUnlockMethodSettingsEntryProvider.future);
    return state.valueOrNull ?? unlockMethod.defaultAppLockState;
  }

  /// Tries to unlock the app.
  Future<Result> unlock(BuildContext context) async {
    if ((await future) == AppLockState.unlockChallengedStarted || !context.mounted) {
      return ResultCancelled();
    }
    state = AsyncData(AppLockState.unlockChallengedStarted);
    Result result = await ref.read(appUnlockMethodSettingsEntryProvider.notifier).unlockWithCurrentMethod(context, UnlockReason.openApp);
    state = AsyncData(result is ResultSuccess ? AppLockState.unlocked : AppLockState.locked);
    return result;
  }
}
