import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:open_authenticator/utils/platform.dart';

/// Allows to check whether Firebase Crashlytics should be enabled for the current platform.
extension PlatformFirebaseCrashlytics on FirebaseCrashlytics {
  /// Contains the supported platforms for Firebase Crashlytics.
  Set<Platform> get supportedPlatforms => {
        Platform.android,
        Platform.iOS,
        Platform.macOS,
      };

  /// Returns whether Firebase Crashlytics should be enabled for the current platform.
  bool get shouldEnable => !kDebugMode && supportedPlatforms.contains(currentPlatform);
}
