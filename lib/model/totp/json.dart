import 'dart:typed_data';

import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/totp/algorithm.dart';
import 'package:open_authenticator/model/totp/totp.dart';

/// Gives some useful properties for serializing TOTPs.
extension JsonTotp on Totp {
  /// Creates a new TOTP from the specified JSON data.
  static Totp? fromJson(Map<String, dynamic> data) {
    EncryptedData? encryptedData = JsonEncryptedData.fromJson(data);
    if (encryptedData == null || data[Totp.kUuidKey] is! String) {
      return null;
    }
    return Totp(
      uuid: data[Totp.kUuidKey],
      encryptedData: encryptedData,
      algorithm: data[Totp.kAlgorithmKey] is! String ? null : Algorithm.fromString(data[Totp.kAlgorithmKey]),
      digits: data[Totp.kDigitsKey] is! int ? null : data[Totp.kDigitsKey],
      validity: data[Totp.kValidityKey] is! int ? null : data[Totp.kValidityKey],
    );
  }

  /// Converts this TOTP to a JSON compatible map.
  Map<String, dynamic> toJson() => {
    Totp.kUuidKey: uuid,
    ...encryptedData.toJson(),
    if (algorithm != null) Totp.kAlgorithmKey: algorithm!.name,
    if (digits != null) Totp.kDigitsKey: digits,
    if (validity != null) Totp.kValidityKey: validity,
  };
}

/// Gives some useful properties for serializing encrypted data.
extension JsonEncryptedData on EncryptedData {
  /// Creates a new encrypted data from the specified JSON data.
  static EncryptedData? fromJson(Map<String, dynamic> data) {
    if (data[Totp.kSecretKey] is! List || data[Totp.kEncryptionSaltKey] is! List) {
      return null;
    }
    return EncryptedData(
      encryptedSecret: Uint8List.fromList((data[Totp.kSecretKey] as List).cast<int>()),
      encryptedLabel: data[Totp.kLabelKey] is! List ? null : Uint8List.fromList((data[Totp.kLabelKey] as List).cast<int>()),
      encryptedIssuer: data[Totp.kIssuerKey] is! List ? null : Uint8List.fromList((data[Totp.kIssuerKey] as List).cast<int>()),
      encryptedImageUrl: data[Totp.kImageUrlKey] is! List ? null : Uint8List.fromList((data[Totp.kImageUrlKey] as List).cast<int>()),
      encryptionSalt: Salt.fromRawValue(value: Uint8List.fromList((data[Totp.kEncryptionSaltKey] as List).cast<int>())),
    );
  }

  /// Converts this encrypted data to a JSON compatible map.
  Map<String, dynamic> toJson() => {
    Totp.kSecretKey: encryptedSecret,
    if (encryptedLabel != null) Totp.kLabelKey: encryptedLabel,
    if (encryptedIssuer != null) Totp.kIssuerKey: encryptedIssuer,
    if (encryptedImageUrl != null) Totp.kImageUrlKey: encryptedImageUrl,
    Totp.kEncryptionSaltKey: encryptionSalt.value,
  };
}
