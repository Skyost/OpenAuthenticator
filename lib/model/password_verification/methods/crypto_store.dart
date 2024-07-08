import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/password_verification/methods/method.dart';

/// The provider instance.
final cryptoStoreVerificationMethodProvider = AsyncNotifierProvider.autoDispose<CryptoStoreVerificationMethod, bool>(CryptoStoreVerificationMethod.new);

/// Allows to verify the master password using the current [CryptoStore].
class CryptoStoreVerificationMethod extends PasswordVerificationMethod {
  @override
  FutureOr<bool> build() async {
    CryptoStore? cryptoStore = await ref.watch(cryptoStoreProvider.future);
    return cryptoStore != null;
  }

  @override
  Future<bool> verify(String password) async {
    CryptoStore? cryptoStore = await ref.read(cryptoStoreProvider.future);
    return cryptoStore != null && await cryptoStore.checkPasswordValidity(password);
  }
}
