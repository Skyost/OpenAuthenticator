import 'package:flutter/foundation.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/totp/algorithm.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:totp/totp.dart' as totp_lib;
import 'package:uuid/uuid.dart';

/// Represents a TOTP, in its decrypted state.
class DecryptedTotp extends Totp {
  /// The decrypted secret.
  final String decryptedSecret;

  /// Creates a new decrypted TOTP instance.
  const DecryptedTotp({
    required super.secret,
    required super.encryptionSalt,
    required super.uuid,
    required super.label,
    super.issuer,
    super.algorithm,
    super.digits,
    super.validity,
    super.imageUrl,
    required this.decryptedSecret,
  });

  /// Creates a new decrypted TOTP instance.
  DecryptedTotp.fromTotp({
    required Totp totp,
    required String decryptedSecret,
  }) : this(
    secret: totp.secret,
    encryptionSalt: totp.encryptionSalt,
    uuid: totp.uuid,
    label: totp.label,
    issuer: totp.issuer,
    algorithm: totp.algorithm,
    digits: totp.digits,
    validity: totp.validity,
    imageUrl: totp.imageUrl,
    decryptedSecret: decryptedSecret,
  );

  /// Returns the [totp_lib.Totp] instance.
  totp_lib.Totp get generator =>
      totp_lib.Totp(
        secret: decryptedSecret.codeUnits,
        algorithm: (algorithm ?? Totp.kDefaultAlgorithm).mapsTo,
        digits: digits ?? Totp.kDefaultDigits,
        period: validity ?? Totp.kDefaultValidity,
      );

  @override
  List<Object?> get props => [...super.props, decryptedSecret];

  @override
  Future<Totp> decrypt(CryptoStore? cryptoStore) => Future.value(this);

  /// Manually creates a [DecryptedTotp].
  static Future<DecryptedTotp?> create({
    required CryptoStore? cryptoStore,
    required String decryptedSecret,
    required String label,
    String? issuer,
    Algorithm? algorithm,
    int? digits,
    int? validity,
    String? imageUrl,
  }) async {
    Uint8List? data = await cryptoStore?.encrypt(decryptedSecret);
    if (data == null) {
      return null;
    }
    return DecryptedTotp(
      secret: data,
      encryptionSalt: cryptoStore!.salt,
      decryptedSecret: decryptedSecret,
      uuid: const Uuid().v4(),
      label: label,
      issuer: issuer,
      algorithm: algorithm,
      digits: digits,
      validity: validity,
      imageUrl: imageUrl,
    );
  }

  /// Creates a new TOTP instance from the scanned QR code properties.
  static Future<DecryptedTotp?> fromUri(Uri uri, CryptoStore? cryptoStore) async {
    if (!uri.isScheme('otpauth') || uri.host != 'totp' || !uri.queryParameters.containsKey('secret')) {
      return null;
    }
    String label = Uri.decodeFull(uri.path);
    if (label.startsWith('/')) {
      label = label.substring(1);
    }
    return create(
      cryptoStore: cryptoStore,
      decryptedSecret: Uri.decodeFull(uri.queryParameters[Totp.kSecretKey]!),
      label: label,
      issuer: uri.queryParameters[Totp.kIssuerKey],
      algorithm: uri.queryParameters.containsKey(Totp.kAlgorithmKey) ? Algorithm.fromString(uri.queryParameters[Totp.kAlgorithmKey]!) : null,
      digits: uri.queryParameters.containsKey(Totp.kDigitsKey) ? int.tryParse(uri.queryParameters[Totp.kDigitsKey]!) : null,
      validity: uri.queryParameters.containsKey(Totp.kValidityKey) ? int.tryParse(uri.queryParameters[Totp.kValidityKey]!) : null,
    );
  }

  /// Returns the URI associated to this TOTP instance.
  Uri get uri =>
      toUri(
        decryptedSecret: decryptedSecret,
        label: label ?? uuid,
        issuer: issuer,
        algorithm: algorithm,
        digits: digits,
        validity: validity,
      );

  /// Converts the given TOTP parameters to an URI.
  static Uri toUri({
    required String decryptedSecret,
    required String label,
    String? issuer,
    Algorithm? algorithm,
    int? digits,
    int? validity,
  }) {
    Map<String, dynamic> queryParameters = {};
    queryParameters[Totp.kSecretKey] = decryptedSecret;
    if (issuer != null) {
      queryParameters[Totp.kIssuerKey] = issuer;
    }
    if (algorithm != null) {
      queryParameters[Totp.kAlgorithmKey] = algorithm.name.toLowerCase();
    }
    if (digits != null) {
      queryParameters[Totp.kDigitsKey] = digits.toString();
    }
    if (validity != null) {
      queryParameters[Totp.kValidityKey] = validity.toString();
    }
    return Uri(
      scheme: 'otpauth',
      host: 'totp',
      path: Uri.encodeComponent(label),
      queryParameters: queryParameters,
    );
  }

  @override
  DecryptedTotp copyWith({
    Uint8List? secret,
    Uint8List? encryptionSalt,
    String? uuid,
    String? label,
    String? issuer,
    Algorithm? algorithm,
    int? digits,
    int? validity,
    String? imageUrl,
    String? decryptedSecret,
  }) => DecryptedTotp(
    secret: secret ?? this.secret,
    encryptionSalt: encryptionSalt ?? this.encryptionSalt,
    uuid: uuid ?? this.uuid,
    label: label ?? this.label,
    issuer: issuer ?? this.issuer,
    algorithm: algorithm ?? this.algorithm,
    digits: digits ?? this.digits,
    validity: validity ?? this.validity,
    imageUrl: imageUrl ?? this.imageUrl,
    decryptedSecret: decryptedSecret ?? this.decryptedSecret,
  );
}

/// Allows to check if the TOTP instance is decrypted.
extension IsDecrypted on Totp {
  /// Returns whether the current TOTP instance is a decrypted secret.
  bool get isDecrypted => this is DecryptedTotp;
}
