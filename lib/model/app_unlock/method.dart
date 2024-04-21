import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/storage/storage.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';

/// Allows to unlock the app.
sealed class AppUnlockMethod {
  /// Tries to unlock the app.
  /// [context] is required so that we can interact with the user.
  Future<bool> tryUnlock(BuildContext context, AsyncNotifierProviderRef ref, UnlockReason reason);

  /// Triggered when this method has been chosen has the app unlock method.
  /// [unlockResult] is the result of the [tryUnlock] call.
  Future<void> onMethodChosen(AsyncNotifierProviderRef ref) => Future.value();

  /// Triggered when a new method will be used for app unlocking.
  Future<void> onMethodChanged(AsyncNotifierProviderRef ref) => Future.value();
}

/// Local authentication.
class LocalAuthenticationAppUnlockMethod extends AppUnlockMethod {
  @override
  Future<bool> tryUnlock(BuildContext context, AsyncNotifierProviderRef ref, UnlockReason reason) async {
    String message = translations.appUnlock.localAuthentication[reason.name] ?? 'Authenticate to access the app.';
    LocalAuthentication auth = LocalAuthentication();
    return !(await auth.isDeviceSupported()) || await auth.authenticate(localizedReason: message);
  }
}

/// Enter master password.
class MasterPasswordAppUnlockMethod extends AppUnlockMethod {
  @override
  Future<bool> tryUnlock(BuildContext context, AsyncNotifierProviderRef ref, UnlockReason reason) async {
    if (reason != UnlockReason.openApp) {
      List<Totp> totps = await ref.read(totpRepositoryProvider.future);
      if (totps.isEmpty) {
        return true;
      }
    }
    if (!context.mounted) {
      return false;
    }
    String? password = await MasterPasswordInputDialog.prompt(
      context,
      message: translations.appUnlock.masterPasswordDialogMessage,
    );
    if (password == null) {
      return false;
    }
    if (reason == UnlockReason.openApp) {
      Storage storage = await ref.read(storageProvider.future);
      CryptoStore? cryptoStore = await CryptoStore.fromPassword(password, salt: await storage.readSecretsSalt());
      if (cryptoStore == null) {
        return false;
      }
      if (!await ref.read(totpRepositoryProvider.notifier).tryDecryptAll(cryptoStore)) {
        return false;
      }
      ref.read(cryptoStoreProvider.notifier).use(cryptoStore);
    } else {
      CryptoStore? currentCryptoStore = await ref.read(cryptoStoreProvider.future);
      if (currentCryptoStore == null || !(await currentCryptoStore.checkPasswordValidity(password))) {
        return false;
      }
    }
    return true;
  }

  @override
  Future<void> onMethodChosen(AsyncNotifierProviderRef ref) async => await ref.read(cryptoStoreProvider.notifier).deleteFromLocalStorage();

  @override
  Future<void> onMethodChanged(AsyncNotifierProviderRef ref) async => await ref.read(cryptoStoreProvider.notifier).saveCurrentOnLocalStorage(checkSettings: false);
}

/// No unlock.
class NoneAppUnlockMethod extends AppUnlockMethod {
  @override
  Future<bool> tryUnlock(BuildContext context, AsyncNotifierProviderRef ref, UnlockReason reason) => Future.value(true);
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
