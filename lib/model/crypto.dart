import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/app_unlock/method.dart';
import 'package:open_authenticator/model/settings/app_unlock_method.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/utils/argon2/base.dart';
import 'package:open_authenticator/utils/argon2/parameters.dart';
import 'package:open_authenticator/utils/utils.dart';
import 'package:simple_secure_storage/simple_secure_storage.dart';
import 'package:webcrypto/webcrypto.dart';

/// The crypto store provider.
final cryptoStoreProvider = AsyncNotifierProvider<StoredCryptoStore, CryptoStore?>(StoredCryptoStore.new);

/// Allows to get and set the crypto store.
class StoredCryptoStore extends AsyncNotifier<CryptoStore?> {
  /// The password derived key storage key.
  static const String _kPasswordDerivedKeyKey = 'passwordDerivedKey';

  /// The password derived key storage key.
  static const String _kPasswordDerivedKeySaltKey = 'passwordDerivedKeySalt';

  @override
  FutureOr<CryptoStore?> build() async {
    if (!await SimpleSecureStorage.has(_kPasswordDerivedKeyKey) || !await SimpleSecureStorage.has(_kPasswordDerivedKeySaltKey)) {
      return null;
    }
    return CryptoStore(
      key: await AesGcmSecretKey.importRawKey(base64.decode((await SimpleSecureStorage.read(_kPasswordDerivedKeyKey))!)),
      salt: (await readSaltFromLocalStorage())!,
    );
  }

  /// Deletes the current crypto store from the local storage.
  Future<void> deleteFromLocalStorage({bool deleteSalt = false}) async {
    await SimpleSecureStorage.delete(_kPasswordDerivedKeyKey);
    if (deleteSalt) {
      await SimpleSecureStorage.delete(_kPasswordDerivedKeySaltKey);
    }
  }

  /// Uses the [cryptoStore] as [state].
  void use(CryptoStore cryptoStore) => state = AsyncData(cryptoStore);

  /// Saves the [cryptoStore] on disk and use it as [state].
  Future<void> saveAndUse(CryptoStore cryptoStore, {bool checkSettings = true}) async {
    await _saveOnLocalStorage(cryptoStore, checkSettings: checkSettings);
    use(cryptoStore);
  }

  /// Saves the current [state] on disk.
  Future<bool> saveCurrentOnLocalStorage({bool checkSettings = true}) async {
    CryptoStore? cryptoStore = await future;
    if (cryptoStore == null) {
      return false;
    }
    await _saveOnLocalStorage(cryptoStore, checkSettings: checkSettings);
    return true;
  }

  /// Saves the [cryptoStore] on disk.
  Future<void> _saveOnLocalStorage(CryptoStore cryptoStore, {bool checkSettings = true}) async {
    await saveSaltToLocalStorage(cryptoStore.salt);
    if (checkSettings && (await ref.read(appUnlockMethodSettingsEntryProvider.future)) is MasterPasswordAppUnlockMethod) {
      return;
    }
    await SimpleSecureStorage.write(_kPasswordDerivedKeyKey, base64.encode(await cryptoStore.key.exportRawKey()));
  }

  /// Checks if the given password is valid.
  /// Will check if there is no TOTP if `trueIfTotpEmpty` is set to `true`.
  Future<bool> checkPasswordValidity(String password, {bool trueIfTotpEmpty = true}) async {
    if (trueIfTotpEmpty) {
      List<Totp> totps = await ref.read(totpRepositoryProvider.future);
      if (totps.isEmpty) {
        return true;
      }
    }
    CryptoStore? cryptoStore = await future;
    return cryptoStore != null && await cryptoStore.checkPasswordValidity(password);
  }

  /// Reads the salt (if stored) from the secure storage.
  static Future<Uint8List?> readSaltFromLocalStorage() async {
    String? value = await SimpleSecureStorage.read(_kPasswordDerivedKeySaltKey);
    if (value == null) {
      return null;
    }
    return base64.decode(value);
  }

  /// Writes the salt to the secure storage.
  static Future<void> saveSaltToLocalStorage(Uint8List salt) async => await SimpleSecureStorage.write(_kPasswordDerivedKeySaltKey, base64.encode(salt));
}

/// Allows to encrypt some data according to a key.
class CryptoStore {
  /// The key length.
  static const int _keyLength = 256 ~/ 8;

  /// The initialization vector length.
  static const int _initializationVectorLength = 96 ~/ 8;

  /// The salt length.
  static const int _saltLength = _keyLength;

  /// The key instance.
  final AesGcmSecretKey key;

  /// The salt.
  final Uint8List salt;

  /// Creates a new crypto store instance.
  const CryptoStore({
    required this.key,
    required this.salt,
  });

  /// Creates a [CryptoStore] from the given [password].
  static Future<CryptoStore?> fromPassword(
    String password, {
    Uint8List? salt,
  }) async {
    (Uint8List, Uint8List) data = await _deriveKey(password, salt: salt);
    return CryptoStore(
      key: await AesGcmSecretKey.importRawKey(data.$1),
      salt: data.$2,
    );
  }

  /// Generates a derived key from the given [password] and save it to the device secure storage.
  /// Also returns the salt that has been used.
  static Future<(Uint8List, Uint8List)> _deriveKey(
    String password, {
    Uint8List? salt,
  }) async {
    if (salt == null) {
      salt = Uint8List(_saltLength);
      fillRandomBytes(salt);
    }
    Argon2BytesGenerator argon2 = Argon2BytesGenerator();
    argon2.init(Argon2Parameters(Argon2Parameters.argon2ID, salt));
    Uint8List key = Uint8List(_keyLength);
    argon2.generateBytesFromString(password, key);
    return (key, salt);
  }

  /// Encrypts the given text.
  Future<Uint8List?> encrypt(String text) async {
    Uint8List initializationVector = Uint8List(_initializationVectorLength);
    fillRandomBytes(initializationVector);
    Uint8List data = utf8.encode(text);
    return Uint8List.fromList([
      ...initializationVector,
      ...await key.encryptBytes(data, initializationVector),
    ]);
  }

  /// Decrypts the given bytes.
  /// Returns `null` if not possible.
  Future<String?> decrypt(Uint8List encryptedData) async {
    try {
      Uint8List initializationVector = encryptedData.sublist(0, _initializationVectorLength);
      Uint8List encryptedBytes = encryptedData.sublist(_initializationVectorLength);
      return utf8.decode(await key.decryptBytes(encryptedBytes, initializationVector));
    } catch (ex, stacktrace) {
      handleException(ex, stacktrace);
    }
    return null;
  }

  /// Checks if the given password is valid.
  Future<bool> checkPasswordValidity(String password) async {
    (Uint8List, Uint8List) data = await _deriveKey(password, salt: salt);
    return memEquals(data.$1, await key.exportRawKey());
  }

  /// Checks if the given [encryptedData] could be decrypted using [decrypt].
  /// There seems to be no better way of doing this.
  /// The authentication tag doesn't seems to be accessible, BUT it should be checked
  /// before any decryption. So, if the validation fails, then the decryption exits immediately.
  /// The caveat is, if it works, then the whole data has to be proceeded.
  Future<bool> canDecrypt(Uint8List encryptedData) async => await decrypt(encryptedData) != null;
}
