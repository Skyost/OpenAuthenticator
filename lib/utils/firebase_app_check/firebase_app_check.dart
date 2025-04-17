import 'package:open_authenticator/utils/firebase_app_check/default.dart';
import 'package:open_authenticator/utils/firebase_app_check/method_channel.dart';
import 'package:open_authenticator/utils/platform.dart';

/// Allows to either use FlutterFire's Firebase AppCheck implementation or fallback to the REST API if needed.
abstract class FirebaseAppCheck {
  /// The current [FirebaseAppCheck] instance.
  static FirebaseAppCheck? _instance;

  /// Returns the [FirebaseAuth] instance corresponding to the current platform.
  static FirebaseAppCheck get instance {
    _instance ??= currentPlatform.isMobile || currentPlatform == Platform.macOS ? FirebaseAppCheckDefault() : FirebaseAppCheckMethodChannel();
    return _instance!;
  }

  /// Activates the Firebase App Check service.
  Future<void> activate();
}
