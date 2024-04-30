import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/password_verification/methods/password_signature.dart';
import 'package:open_authenticator/model/password_verification/password_verification.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';

/// Allows to unlock the app.
sealed class AppUnlockMethod {
  /// Tries to unlock the app.
  /// [context] is required so that we can interact with the user.
  Future<Result> tryUnlock(BuildContext context, AsyncNotifierProviderRef ref, UnlockReason reason);

  /// Triggered when this method has been chosen has the app unlock method.
  /// [unlockResult] is the result of the [tryUnlock] call.
  Future<void> onMethodChosen(AsyncNotifierProviderRef ref, { ResultSuccess? enableResult }) => Future.value();

  /// Triggered when a new method will be used for app unlocking.
  Future<void> onMethodChanged(AsyncNotifierProviderRef ref, { ResultSuccess? disableResult }) => Future.value();
}

/// Local authentication.
class LocalAuthenticationAppUnlockMethod extends AppUnlockMethod {
  @override
  Future<Result> tryUnlock(BuildContext context, AsyncNotifierProviderRef ref, UnlockReason reason) async {
    String message = translations.appUnlock.localAuthentication[reason.name] ?? 'Authenticate to access the app.';
    LocalAuthentication auth = LocalAuthentication();
    if (!(await auth.isDeviceSupported())) {
      return ResultError();
    }
    return (await auth.authenticate(localizedReason: message)) ? const ResultSuccess() : const ResultCancelled();
  }

  /// Returns whether this unlock method is supported;
  static Future<bool> isSupported() => LocalAuthentication().isDeviceSupported();
}

/// Enter master password.
class MasterPasswordAppUnlockMethod extends AppUnlockMethod {
  @override
  Future<Result> tryUnlock(BuildContext context, AsyncNotifierProviderRef ref, UnlockReason reason) async {
    if (reason != UnlockReason.openApp) {
      List<Totp> totps = await ref.read(totpRepositoryProvider.future);
      if (totps.isEmpty) {
        return const ResultSuccess();
      }
    }
    if (!context.mounted) {
      return const ResultCancelled();
    }

    String? password = await MasterPasswordInputDialog.prompt(
      context,
      message: translations.appUnlock.masterPasswordDialogMessage,
    );
    if (password == null) {
      return const ResultCancelled();
    }

    Result<bool> passwordCheckResult = await ref.read(passwordVerificationProvider.notifier).isPasswordValid(password);
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
  Future<void> onMethodChosen(AsyncNotifierProviderRef ref, { ResultSuccess? enableResult }) async {
    String? password = enableResult?.valueOrNull;
    if (await ref.read(passwordSignatureVerificationMethodProvider.notifier).enable(password)) {
      await ref.read(cryptoStoreProvider.notifier).deleteFromLocalStorage();
    }
  }

  @override
  Future<void> onMethodChanged(AsyncNotifierProviderRef ref, { ResultSuccess? disableResult }) async {
    await ref.read(passwordSignatureVerificationMethodProvider.notifier).disable();
    await ref.read(cryptoStoreProvider.notifier).saveCurrentOnLocalStorage(checkSettings: false);
  }
}

/// No unlock.
class NoneAppUnlockMethod extends AppUnlockMethod {
  @override
  Future<Result> tryUnlock(BuildContext context, AsyncNotifierProviderRef ref, UnlockReason reason) => Future.value(const ResultSuccess());
}

/// Configures the unlock reason for [UnlockChallenge]s.
enum UnlockReason {
  /// The user tries the unlock challenge for opening the app.
  openApp,

  /// The user tries the unlock challenge for enabling the current method.
  enable,

  /// The user tries the unlock challenge for disabling the current method.
  disable;
}
