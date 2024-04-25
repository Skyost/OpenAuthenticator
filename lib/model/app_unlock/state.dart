import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/app_unlock/method.dart';
import 'package:open_authenticator/model/settings/app_unlock_method.dart';
import 'package:open_authenticator/utils/result.dart';

/// The app unlock state state provider.
final appUnlockStateProvider = AsyncNotifierProvider<AppUnlockState, bool>(AppUnlockState.new);

/// Allows to get and set the app unlocked state.
class AppUnlockState extends AsyncNotifier<bool> {
  @override
  FutureOr<bool> build() => future;

  /// Tries to unlock the app.
  Future<Result> unlock(BuildContext context, {UnlockReason unlockReason = UnlockReason.openApp}) async {
    try {
      AppUnlockMethod unlockMethod = await ref.read(appUnlockMethodSettingsEntryProvider.future);
      if (!context.mounted) {
        return const ResultCancelled();
      }
      Result result = await unlockMethod.tryUnlock(context, ref, unlockReason);
      state = AsyncData(result is ResultSuccess ? true : false);
      return result;
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }
}
