import 'package:open_authenticator/utils/platform.dart';

/// Whether the current platform is supported by Firebase.
bool isFirebaseSupported = {
  Platform.android,
  Platform.iOS,
  Platform.macOS,
  Platform.windows,
}.contains(currentPlatform);