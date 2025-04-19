import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_authenticator/utils/local_authentication/local_authentication.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';

/// A LocalAuthentication implementation that uses method channel.
class LocalAuthenticationMethodChannel extends LocalAuthentication {
  /// The method channel.
  final MethodChannel _methodChannel = const MethodChannel('app.openauthenticator.localauth');

  @override
  Future<bool> authenticate(BuildContext context, String reason) async {
    String? realName = await _methodChannel.invokeMethod<String>('localAuth.getRealName');
    String? avatarPath = await _methodChannel.invokeMethod<String>('localAuth.getAvatarPath');
    bool isValid = false;
    while (!isValid) {
      if (!context.mounted) {
        return false;
      }
      String? password = await TextInputDialog.prompt(
        context,
        title: 'Authentication required',
        message: reason,
        children: [
          if (avatarPath != null)
            Image.file(
              File(avatarPath),
              width: 64,
              height: 64,
            ),
          if (avatarPath != null && realName != null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                realName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
        ],
        password: true,
      );
      if (password == null) {
        return false;
      }
      isValid = await _methodChannel.invokeMethod<bool>('localAuth.checkPassword', {'password': password}) == true;
    }
    return true;
  }

  @override
  Future<bool> isSupported() async => (await _methodChannel.invokeMethod<bool>('localAuth.isDeviceSupported')) == true;
}
