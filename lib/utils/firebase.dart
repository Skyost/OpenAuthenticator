import 'package:flutter/foundation.dart';
import 'package:open_authenticator/utils/platform.dart';

/// Whether the current platform is supported by Firebase.
bool isFirebaseSupported = {
  Platform.android,
  Platform.iOS,
  Platform.macOS,
  Platform.windows,
}.contains(currentPlatform);

/// Whether the current platform is supported by Firebase Crashlytics.
bool isCrashlyticsSupported = {
  Platform.android,
  Platform.iOS,
  Platform.macOS,
}.contains(currentPlatform);

/// Whether Crashlytics should be enabled.
bool isCrashlyticsEnabled = !kDebugMode && isCrashlyticsSupported;
