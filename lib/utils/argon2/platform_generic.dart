import 'package:open_authenticator/utils/argon2/platform.dart';

class Argon2PlatformGeneric extends Argon2Platform {
  static final Argon2PlatformGeneric instance = Argon2PlatformGeneric();

  const Argon2PlatformGeneric();

  @override
  bool get isNative => false;

  @override
  String get platform => 'generic';
}

Argon2Platform getArgon2Platform() => Argon2PlatformGeneric.instance;
