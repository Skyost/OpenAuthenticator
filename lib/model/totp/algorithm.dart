import 'package:open_authenticator/utils/utils.dart';
import 'package:totp/totp.dart' as totp_lib;

/// Allows to avoid conflicts with [totp_lib.Algorithm].
enum Algorithm {
  /// The SHA1 algorithm.
  sha1(totp_lib.Algorithm.sha1),

  /// The SHA256 algorithm.
  sha256(totp_lib.Algorithm.sha256),

  /// The SHA512 algorithm.
  sha512(totp_lib.Algorithm.sha512);

  /// The corresponding [totp_lib.Algorithm] enum entry.
  final totp_lib.Algorithm mapsTo;

  /// Creates a new algorithm instance.
  const Algorithm(this.mapsTo);

  /// Tries to convert the given [string] to an [Algorithm].
  static Algorithm? fromString(String string) => Algorithm.values.firstWhereOrNull((algorithm) => algorithm.name.toLowerCase() == string);
}
