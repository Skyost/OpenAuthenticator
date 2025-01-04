import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:local_auth_windows/local_auth_windows.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/password_verification/methods/password_signature.dart';
import 'package:open_authenticator/model/password_verification/password_verification.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';
import 'package:window_manager/window_manager.dart';

/// Allows to unlock the app.
sealed class AppUnlockMethod {
  /// Unlock the app, handling errors.
  /// [context] is required so that we can interact with the user.
  Future<Result> unlock(BuildContext context, Ref ref, UnlockReason reason) async {
    try {
      return await _tryUnlock(context, ref, reason);
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }

  /// Tries to unlock the app.
  /// [context] is required so that we can interact with the user.
  Future<Result> _tryUnlock(BuildContext context, Ref ref, UnlockReason reason);

  /// The default app state.
  AppLockState get defaultState => AppLockState.locked;

  /// Triggered when this method has been chosen has the app unlock method.
  /// [unlockResult] is the result of the [tryUnlock] call.
  Future<void> onMethodChosen(Ref ref, {ResultSuccess? enableResult}) => Future.value();

  /// Triggered when a new method will be used for app unlocking.
  Future<void> onMethodChanged(Ref ref, {ResultSuccess? disableResult}) => Future.value();
}

/// Represents an app state.
enum AppLockState {
  /// If the app is locked, waiting for unlock.
  locked,
  /// If the app has been unlocked.
  unlocked,
  /// If an unlock challenge has started.
  unlockChallengedStarted;
}

/// Local authentication.
class LocalAuthenticationAppUnlockMethod extends AppUnlockMethod {
  @override
  Future<Result> _tryUnlock(BuildContext context, Ref ref, UnlockReason reason) async {
    LocalAuthentication auth = LocalAuthentication();
    if (!(await auth.isDeviceSupported())) {
      return ResultError();
    }
    if (currentPlatform.isDesktop) {
      await windowManager.ensureInitialized();
      await windowManager.focus();
      await windowManager.setAlwaysOnTop(true);
    }
    if (!context.mounted) {
      return const ResultCancelled();
    }
    bool result = await auth.authenticate(
      localizedReason: translations.appUnlock.localAuthentication[reason.name] ?? 'Authenticate to access the app.',
      authMessages: [
        IOSAuthMessages(
          lockOut: translations.localAuth.ios.lockOut,
          goToSettingsButton: translations.localAuth.common.goToSettings,
          goToSettingsDescription: translations.localAuth.ios.goToSettingsDescription,
          cancelButton: MaterialLocalizations.of(context).cancelButtonLabel,
        ),
        AndroidAuthMessages(
          biometricHint: translations.localAuth.android.biometricHint,
          biometricNotRecognized: translations.localAuth.android.biometricNotRecognized,
          biometricRequiredTitle: translations.localAuth.android.biometricRequiredTitle,
          biometricSuccess: translations.error.noError,
          cancelButton: MaterialLocalizations.of(context).cancelButtonLabel,
          deviceCredentialsRequiredTitle: translations.localAuth.android.deviceCredentialsRequiredTitle,
          deviceCredentialsSetupDescription: translations.localAuth.android.deviceCredentialsSetupDescription,
          goToSettingsButton: translations.localAuth.common.goToSettings,
          goToSettingsDescription: translations.localAuth.android.goToSettingsDescription,
          signInTitle: translations.localAuth.android.signInTitle,
        ),
        const WindowsAuthMessages(),
      ],
    );
    if (currentPlatform.isDesktop) {
      if (currentPlatform == Platform.macOS || currentPlatform == Platform.windows) {
        // See https://github.com/flutter/flutter/issues/122322.
        await windowManager.blur();
        await windowManager.focus();
      }
      await windowManager.setAlwaysOnTop(false);
    }
    return result ? const ResultSuccess() : const ResultCancelled();
  }

  /// Returns whether this unlock method is supported;
  static Future<bool> isSupported() => LocalAuthentication().isDeviceSupported();
}

/// Enter master password.
class MasterPasswordAppUnlockMethod extends AppUnlockMethod {
  @override
  Future<Result> _tryUnlock(BuildContext context, Ref ref, UnlockReason reason) async {
    if (reason != UnlockReason.openApp && reason != UnlockReason.sensibleAction) {
      TotpList totps = await ref.read(totpRepositoryProvider.future);
      if (totps.isEmpty) {
        return const ResultSuccess();
      }
    }
    if (!context.mounted) {
      return const ResultCancelled();
    }

    String? password = await MasterPasswordInputDialog.prompt(
      context,
      message: reason == UnlockReason.openApp ? translations.appUnlock.masterPasswordDialogMessage : null,
    );
    if (password == null) {
      return const ResultCancelled();
    }

    Result<bool> passwordCheckResult = await (await ref.read(passwordVerificationProvider.future)).isPasswordValid(password);
    if (passwordCheckResult is! ResultSuccess || !(passwordCheckResult as ResultSuccess<bool>).value) {
      return ResultError();
    }

    if (reason == UnlockReason.openApp) {
      Salt? salt = await Salt.readFromLocalStorage();
      if (salt == null) {
        return ResultError();
      }
      ref.read(cryptoStoreProvider.notifier).use(await CryptoStore.fromPassword(password, salt));
    }

    return ResultSuccess(value: password);
  }

  @override
  Future<void> onMethodChosen(Ref ref, {ResultSuccess? enableResult}) async {
    String? password = enableResult?.valueOrNull;
    if (await ref.read(passwordSignatureVerificationMethodProvider.notifier).enable(password)) {
      await ref.read(cryptoStoreProvider.notifier).deleteFromLocalStorage();
    }
  }

  @override
  Future<void> onMethodChanged(Ref ref, {ResultSuccess? disableResult}) async {
    await ref.read(passwordSignatureVerificationMethodProvider.notifier).disable();
    await ref.read(cryptoStoreProvider.notifier).saveCurrentOnLocalStorage(checkSettings: false);
  }
}

/// No unlock.
class NoneAppUnlockMethod extends AppUnlockMethod {
  @override
  Future<Result> _tryUnlock(BuildContext context, Ref ref, UnlockReason reason) => Future.value(const ResultSuccess());

  @override
  AppLockState get defaultState => AppLockState.unlocked;
}

/// Configures the unlock reason for [UnlockChallenge]s.
enum UnlockReason {
  /// The user tries the unlock challenge for opening the app.
  openApp,

  /// The user tries to do a sensible action.
  sensibleAction,

  /// The user tries the unlock challenge for enabling the current method.
  enable,

  /// The user tries the unlock challenge for disabling the current method.
  disable;
}
