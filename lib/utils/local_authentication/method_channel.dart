import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/utils/local_authentication/local_authentication.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';

/// A LocalAuthentication implementation that uses method channel.
class LocalAuthenticationMethodChannel extends LocalAuthentication {
  /// The method channel.
  final MethodChannel _methodChannel = const MethodChannel('app.openauthenticator.localauth');

  @override
  Future<bool> authenticate(BuildContext context, String _) async => await _methodChannel.invokeMethod<bool>('localAuth.authenticate') == true;

  @override
  Future<bool> isSupported() async => (await _methodChannel.invokeMethod<bool>('localAuth.isDeviceSupported')) == true;
}
