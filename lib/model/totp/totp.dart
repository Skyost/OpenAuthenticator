import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/totp/algorithm.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';

/// Represents a TOTP in its encrypted state.
class Totp extends Equatable implements Comparable<Totp> {
  /// The secret key.
  static const String kSecretKey = 'secret';

  /// The encryption salt.
  static const String kEncryptionSalt = 'encryptionSalt';

  /// The UUID key.
  static const String kUuidKey = 'uuid';

  /// The label key.
  static const String kLabelKey = 'label';

  /// The issuer key.
  static const String kIssuerKey = 'issuer';

  /// The algorithm key.
  static const String kAlgorithmKey = 'algorithm';

  /// The digits key.
  static const String kDigitsKey = 'digits';

  /// The validity key.
  static const String kValidityKey = 'validity';

  /// The image URL key.
  static const String kImageUrlKey = 'imageUrl';

  /// The default algorithm to use.
  static const Algorithm kDefaultAlgorithm = Algorithm.sha1;

  /// The default digits to use.
  static const int kDefaultDigits = 6;

  /// The default validity to use.
  static const int kDefaultValidity = 30;

  /// The encrypted data.
  final Uint8List secret;

  /// The TOTP UUID.
  final String uuid;

  /// The label.
  final String label;

  /// The issuer.
  final String? issuer;

  /// The algorithm.
  final Algorithm? algorithm;

  /// The digit count.
  final int? digits;

  /// The validity period.
  final int? validity;

  /// The image URL.
  final String? imageUrl;

  /// Creates a new TOTP instance.
  const Totp({
    required this.secret,
    required this.uuid,
    required this.label,
    this.issuer,
    this.algorithm,
    this.digits,
    this.validity,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [secret, uuid, label, issuer, algorithm, digits, validity, imageUrl];

  /// Tries to decrypt the current TOTP [secret].
  /// Returns the current instance if failed.
  Future<Totp> decrypt(CryptoStore? cryptoStore) async {
    String? decryptedData = await cryptoStore?.decrypt(secret);
    if (decryptedData == null) {
      return this;
    }
    return DecryptedTotp.fromTotp(totp: this, decryptedSecret: decryptedData);
  }

  @override
  int compareTo(Totp other) => label.compareTo(other.label);

  /// Changes the encryption key of the current TOTP.
  Future<DecryptedTotp?> changeEncryptionKey(CryptoStore previousCryptoStore, CryptoStore newCryptoStore) async {
    Totp result = await decrypt(previousCryptoStore);
    return result.isDecrypted
        ? DecryptedTotp(
            decryptedSecret: (result as DecryptedTotp).decryptedSecret,
            secret: (await newCryptoStore.encrypt(result.decryptedSecret))!,
            uuid: result.uuid,
            label: result.label,
            issuer: result.issuer,
            algorithm: result.algorithm,
            digits: result.digits,
            validity: result.validity,
            imageUrl: result.imageUrl,
          )
        : null;
  }
}
