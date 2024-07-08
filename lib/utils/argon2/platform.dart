import 'package:open_authenticator/utils/argon2/platform_generic.dart'
    if (dart.library.io) 'package:open_authenticator/utils/argon2/platform_io.dart'
    if (dart.library.js) 'package:open_authenticator/utils/argon2/platform_js.dart';

abstract class Argon2Platform {
  static Argon2Platform get instance => getArgon2Platform();

  const Argon2Platform();

  String get platform;

  bool get isNative;
}
