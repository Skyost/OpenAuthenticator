import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/password_verification/methods/method.dart';
import 'package:simple_secure_storage/simple_secure_storage.dart';
import 'package:webcrypto/webcrypto.dart';

/// The provider instance.
final passwordSignatureVerificationMethodProvider = AsyncNotifierProvider.autoDispose<PasswordSignatureVerificationMethod, bool>(PasswordSignatureVerificationMethod.new);

/// Allows to verify the master password using the saved password signature.
class PasswordSignatureVerificationMethod extends PasswordVerificationMethod {
  /// The password signature.
  static const String _kPasswordSignatureKey = 'passwordSignature';

  @override
  FutureOr<bool> build() => SimpleSecureStorage.has(_kPasswordSignatureKey);

  @override
  Future<bool> verify(String password) async {
    String? signature = await SimpleSecureStorage.read(_kPasswordSignatureKey);
    Uint8List decodedSignature = base64.decode(signature!);
    HmacSecretKey hmacSecretKey = await _createHmacKey(password);
    return await hmacSecretKey.verifyBytes(decodedSignature, utf8.encode(password));
  }

  /// Enables this method.
  Future<bool> enable(String? password) async {
    if (password == null) {
      return false;
    }
    HmacSecretKey hmacSecretKey = await _createHmacKey(password);
    await SimpleSecureStorage.write(_kPasswordSignatureKey, base64.encode(await hmacSecretKey.signBytes(utf8.encode(password))));
    state = const AsyncData(true);
    return true;
  }

  /// Enables this method.
  Future<void> disable() async {
    await SimpleSecureStorage.delete(_kPasswordSignatureKey);
    state = const AsyncData(false);
  }

  /// Creates the HMAC key that corresponds to the [password].
  Future<HmacSecretKey> _createHmacKey(String password) async {
    CryptoStore cryptoStore = await CryptoStore.fromPassword(password, (await Salt.readFromLocalStorage())!);
    HmacSecretKey hmacSecretKey = await HmacSecretKey.importRawKey(await cryptoStore.key.exportRawKey(), Hash.sha256);
    return hmacSecretKey;
  }
}