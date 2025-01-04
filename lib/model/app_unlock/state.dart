import 'dart:async';

import 'package:flutter/cupertino.dart';
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
    AppUnlockMethod unlockMethod = await ref.read(appUnlockMethodSettingsEntryProvider.future);
    return unlockMethod.defaultState;
  }

  /// Tries to unlock the app.
  Future<Result> unlock(BuildContext context, {UnlockReason unlockReason = UnlockReason.openApp}) async {
    state = AsyncData(AppLockState.unlockChallengedStarted);
    Result result = await ref.read(appUnlockMethodSettingsEntryProvider.notifier).unlockWithCurrentMethod(context, unlockReason);
    state = AsyncData(result is ResultSuccess ? AppLockState.unlocked : AppLockState.locked);
    return result;
  }
}
