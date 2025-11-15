import 'package:firebase_app_check/firebase_app_check.dart' as firebase_app_check;
import 'package:flutter/foundation.dart';
import 'package:open_authenticator/utils/firebase_app_check/firebase_app_check.dart';

/// The default Firebase AppCheck implementation.
class FirebaseAppCheckDefault extends FirebaseAppCheck {
  @override
  Future<void> activate() async => await firebase_app_check.FirebaseAppCheck.instance.activate(
    providerAndroid: kDebugMode ? const firebase_app_check.AndroidDebugProvider() : const firebase_app_check.AndroidPlayIntegrityProvider(),
    providerApple: kDebugMode ? const firebase_app_check.AppleDeviceCheckProvider() : const firebase_app_check.AppleAppAttestWithDeviceCheckFallbackProvider(),
  );
}
