import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:open_authenticator/utils/firebase_app_check/firebase_app_check.dart';
import 'package:open_authenticator/utils/platform.dart';

/// A Firebase AppCheck implementation that uses method channel.
class FirebaseAppCheckMethodChannel extends FirebaseAppCheck {
  /// The AppCheck URL to use.
  static final Uri _appCheckUrl = Uri.https('vercel.openauthenticator.app', '/api/app-check/');

  /// The method channel.
  /// This allow us to link our auth implementation to the Firebase C++ SDK.
  final MethodChannel _methodChannel = const MethodChannel('app.openauthenticator.appcheck');

  @override
  Future<void> activate() async {
    _methodChannel.setMethodCallHandler(_handlePlatformCall);
    String debugToken = '';
    if (kDebugMode) {
      debugToken = const String.fromEnvironment('APP_CHECK_DEBUG_TOKEN', defaultValue: '');
    }
    await _methodChannel.invokeMethod(
      'appCheck.activate',
      {
        if (debugToken.isNotEmpty) 'debugToken': debugToken,
      },
    );
  }

  /// Handles platform calls.
  Future _handlePlatformCall(MethodCall call) async {
    switch (call.method) {
      case 'appCheck.requestToken':
        String? publisher = call.arguments['publisher'];
        http.Response response = await http.get(
          _appCheckUrl,
          headers: {
            'app-platform': currentPlatform.name.toLowerCase(),
            if (publisher != null) 'app-publisher': publisher,
          },
        );
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success']) {
          return data['object'];
        }
        throw Exception('Invalid response (${response.statusCode}) : ${response.body}.');
      default:
        throw UnimplementedError();
    }
  }
}
