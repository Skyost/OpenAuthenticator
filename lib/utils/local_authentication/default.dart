import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart' as local_auth;
// ignore: depend_on_referenced_packages
import 'package:local_auth_android/local_auth_android.dart';
// ignore: depend_on_referenced_packages
import 'package:local_auth_darwin/local_auth_darwin.dart';
// ignore: depend_on_referenced_packages
import 'package:local_auth_windows/local_auth_windows.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/app_unlock/reason.dart';
import 'package:open_authenticator/utils/local_authentication/local_authentication.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:window_manager/window_manager.dart';

/// Uses Flutter's LocalAuthentication implementation.
class LocalAuthenticationDefault extends LocalAuthentication {
  /// The [local_auth.LocalAuthentication] instance.
  final local_auth.LocalAuthentication _localAuthentication;

  /// Creates a new default local authentication instance.
  LocalAuthenticationDefault() : _localAuthentication = local_auth.LocalAuthentication();

  @override
  Future<bool> authenticate(BuildContext context, UnlockReason reason) async {
    String cancelButton = MaterialLocalizations.of(context).cancelButtonLabel;
    if (currentPlatform.isDesktop) {
      await windowManager.ensureInitialized();
      await windowManager.focus();
      await windowManager.setAlwaysOnTop(true);
    }
    bool result = await _localAuthentication.authenticate(
      localizedReason: translations.appUnlock.localAuthentication[reason.name] ?? 'Authenticate to access the app.',
      authMessages: [
        IOSAuthMessages(
          lockOut: translations.localAuth.ios.lockOut,
          goToSettingsButton: translations.localAuth.common.goToSettings,
          goToSettingsDescription: translations.localAuth.ios.goToSettingsDescription,
          cancelButton: cancelButton,
        ),
        AndroidAuthMessages(
          biometricHint: translations.localAuth.android.biometricHint,
          biometricNotRecognized: translations.localAuth.android.biometricNotRecognized,
          biometricRequiredTitle: translations.localAuth.android.biometricRequiredTitle,
          biometricSuccess: translations.error.noError,
          cancelButton: cancelButton,
          deviceCredentialsRequiredTitle: translations.localAuth.android.deviceCredentialsRequiredTitle,
          deviceCredentialsSetupDescription: translations.localAuth.android.deviceCredentialsSetupDescription,
          goToSettingsButton: translations.localAuth.common.goToSettings,
          goToSettingsDescription: translations.localAuth.android.goToSettingsDescription,
          signInTitle: translations.localAuth.android.signInTitle,
        ),
        const WindowsAuthMessages(),
      ],
    );
    if (currentPlatform.isDesktop) {
      if (currentPlatform == Platform.macOS || currentPlatform == Platform.windows) {
        // See https://github.com/flutter/flutter/issues/122322.
        await windowManager.blur();
        await windowManager.focus();
      }
      await windowManager.setAlwaysOnTop(false);
    }
    return result;
  }

  @override
  Future<bool> isSupported() => _localAuthentication.isDeviceSupported();
}
