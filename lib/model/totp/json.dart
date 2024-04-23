import 'dart:typed_data';

import 'package:open_authenticator/model/totp/algorithm.dart';
import 'package:open_authenticator/model/totp/totp.dart';

/// Gives some useful properties for serializing TOTPs.
extension JsonTotp on Totp {
  /// Creates a new TOTP from the specified JSON data.
  static Totp? fromJson(Map<String, dynamic> data) {
    if (data[Totp.kSecretKey] == null || data[Totp.kEncryptionSalt] == null || data[Totp.kUuidKey] == null) {
      return null;
    }
    return Totp(
      secret: Uint8List.fromList((data[Totp.kSecretKey] as List).cast<int>()),
      encryptionSalt: Uint8List.fromList((data[Totp.kEncryptionSalt] as List).cast<int>()),
      uuid: data[Totp.kUuidKey],
      label: data[Totp.kLabelKey],
      issuer: data[Totp.kIssuerKey],
      algorithm: data.containsKey(Totp.kAlgorithmKey) ? Algorithm.fromString(data[Totp.kAlgorithmKey]) : null,
      digits: data[Totp.kDigitsKey],
      validity: data[Totp.kValidityKey],
      imageUrl: data[Totp.kImageUrlKey],
    );
  }

  /// Converts this TOTP to a JSON compatible map.
  Map<String, dynamic> toJson() => {
    Totp.kSecretKey: secret,
    Totp.kEncryptionSalt: encryptionSalt,
    Totp.kUuidKey: uuid,
    Totp.kLabelKey: label,
    if (issuer != null) Totp.kIssuerKey: issuer,
    if (algorithm != null) Totp.kAlgorithmKey: algorithm!.name,
    if (digits != null) Totp.kDigitsKey: digits,
    if (validity != null) Totp.kValidityKey: validity,
    if (imageUrl != null) Totp.kImageUrlKey: imageUrl,
  };
}
