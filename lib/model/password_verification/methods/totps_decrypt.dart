import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/password_verification/methods/method.dart';
import 'package:open_authenticator/model/totp/repository.dart';

/// The provider instance.
final totpsDecryptVerificationMethodProvider = AsyncNotifierProvider.autoDispose<TotpsDecryptVerificationMethod, bool>(TotpsDecryptVerificationMethod.new);

/// Allows to verify the master password by trying to decrypt all TOTPs.
class TotpsDecryptVerificationMethod extends PasswordVerificationMethod {
  @override
  FutureOr<bool> build() => Future.value(true);

  @override
  Future<bool> verify(String password) async {
    CryptoStore cryptoStore = await CryptoStore.fromPassword(password, (await Salt.readFromLocalStorage())!);
    return await ref.read(totpRepositoryProvider.notifier).tryDecryptAll(cryptoStore);
  }

  @override
  bool get isSure => false;
}
