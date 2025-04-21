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
  Future<bool> authenticate(BuildContext context, String reason) async {
    String? realName = await _methodChannel.invokeMethod<String>('localAuth.getRealName');
    String? avatarPath = await _methodChannel.invokeMethod<String>('localAuth.getAvatarPath');
    File? avatarFile = avatarPath == null ? null : File(avatarPath!);
    if (avatarFile != null && !avatarFile!.existsSync()) {
      avatarFile = null;
    }

    String? password;
    bool isValid = false;
    while (!isValid) {
      if (!context.mounted) {
        return isValid;
      }
      password = await TextInputDialog.prompt(
        context,
        title: translations.localAuth.methodChannel.title,
        message: reason,
        initialValue: password,
        validator: password == null ? null : ((input) => input == password ? translations.localAuth.methodChannel.wrongPassword : null),
        children: [
          if (avatarFile != null)
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 20, bottom: 10),
                child: CircleAvatar(
                  backgroundImage: FileImage(avatarFile),
                  radius: 50,
                ),
              ),
            ),
          if (avatarPath != null && realName != null)
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                realName,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
        ],
        password: true,
      );
      if (password == null) {
        break;
      }
      isValid = await _methodChannel.invokeMethod<bool>('localAuth.authenticate', {'password': password}) == true;
    }
    return isValid;
  }

  @override
  Future<bool> isSupported() async => (await _methodChannel.invokeMethod<bool>('localAuth.isDeviceSupported')) == true;
}
