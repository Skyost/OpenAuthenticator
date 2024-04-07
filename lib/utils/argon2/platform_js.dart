import 'package:open_authenticator/utils/argon2/platform.dart';

class Argon2PlatformJS extends Argon2Platform {
  static final Argon2PlatformJS instance = Argon2PlatformJS();

  const Argon2PlatformJS();

  @override
  String get platform => 'JS';

  @override
  bool get isNative => true;
}

Argon2Platform getArgon2Platform() => Argon2PlatformJS.instance;
