import 'dart:convert';
import 'dart:math';

import 'package:webcrypto/webcrypto.dart';

/// A pair of ([codeVerifier], [codeChallenge]) that can be used with PKCE (Proof Key for Code Exchange).
/// Kudos to https://github.com/nrubin29/pkce_dart.
class PkcePair {
  /// The code verifier.
  final String codeVerifier;

  /// The code challenge, computed as base64Url(sha256([codeVerifier])) with
  /// padding removed as per the spec.
  final String codeChallenge;

  /// Creates a new PKCE pair instance.
  const PkcePair._(this.codeVerifier, this.codeChallenge);

  /// Generates a [PkcePair].
  ///
  /// [length] is the length used to generate the [codeVerifier]. It must be between 32 and 96, inclusive, which corresponds to a [codeVerifier] of length between 43 and 128, inclusive.
  /// The spec recommends a length of 32.
  static Future<PkcePair> generate({int length = 32}) async {
    if (length < 32 || length > 96) {
      throw ArgumentError.value(length, 'length', 'The length must be between 32 and 96, inclusive.');
    }

    Random random = Random.secure();
    String verifier = base64UrlEncode(List.generate(length, (_) => random.nextInt(256))).split('=')[0];
    String challenge = base64UrlEncode(await Hash.sha256.digestBytes(ascii.encode(verifier))).split('=')[0];

    return PkcePair._(verifier, challenge);
  }
}
