import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/password_verification/methods/method.dart';
import 'package:simple_secure_storage/simple_secure_storage.dart';
import 'package:webcrypto/webcrypto.dart';

/// The provider instance.
final passwordSignatureVerificationMethodProvider =
    AsyncNotifierProvider.autoDispose<PasswordSignatureVerificationMethodNotifier, PasswordSignatureVerificationMethod>(PasswordSignatureVerificationMethodNotifier.new);

/// Allows to verify the master password using the saved password signature.
class PasswordSignatureVerificationMethodNotifier extends AutoDisposeAsyncNotifier<PasswordSignatureVerificationMethod> {
  /// The password signature.
  static const String _kPasswordSignatureKey = 'passwordSignature';

  @override
  FutureOr<PasswordSignatureVerificationMethod> build() async => PasswordSignatureVerificationMethod(
        passwordSignature: await SimpleSecureStorage.read(_kPasswordSignatureKey),
      );

  /// Enables the password signature verification method.
  Future<bool> enable(String? password) async {
    Salt? salt = await Salt.readFromLocalStorage();
    if (password == null || salt == null) {
      return false;
    }
    HmacSecretKey hmacSecretKey = await CryptoStore.createHmacKey(password, salt);
    String passwordSignature = base64.encode(await hmacSecretKey.signBytes(utf8.encode(password)));
    await SimpleSecureStorage.write(_kPasswordSignatureKey, passwordSignature);
    state = AsyncData(PasswordSignatureVerificationMethod(passwordSignature: passwordSignature));
    return true;
  }

  /// Disables the password signature verification method.
  Future<void> disable() async {
    await SimpleSecureStorage.delete(_kPasswordSignatureKey);
    state = const AsyncData(PasswordSignatureVerificationMethod(passwordSignature: null));
  }
}

/// Allows to verify the master password using the saved password signature.
class PasswordSignatureVerificationMethod with PasswordVerificationMethod {
  /// The password signature.
  final String? passwordSignature;

  const PasswordSignatureVerificationMethod({
    this.passwordSignature,
  });

  @override
  bool get enabled => passwordSignature != null;

  @override
  Future<bool> verify(String password) async {
    if (!(await super.verify(password))) {
      return false;
    }
    Salt? salt = await Salt.readFromLocalStorage();
    if (salt == null) {
      return false;
    }
    Uint8List decodedSignature = base64.decode(passwordSignature!);
    HmacSecretKey hmacSecretKey = await CryptoStore.createHmacKey(password, salt);
    return await hmacSecretKey.verifyBytes(decodedSignature, utf8.encode(password));
  }
}
