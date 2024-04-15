import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';
import 'package:open_authenticator/utils/platform.dart';

/// The Apple authentication provider.
final appleAuthenticationProvider = NotifierProvider<AppleAuthenticationProvider, FirebaseAuthenticationState>(AppleAuthenticationProvider.new);

/// The provider that allows to sign-in using Apple.
class AppleAuthenticationProvider extends FirebaseAuthenticationProvider with LinkProvider {
  /// Creates a new Apple authentication provider instance.
  AppleAuthenticationProvider()
      : super(
          availablePlatforms: const [
            Platform.android,
            Platform.iOS,
            Platform.macOS,
          ],
        );

  @override
  AppleAuthMethod createDefaultAuthMethod(BuildContext context) => AppleAuthMethod.defaultMethod(
      scopes: ['email'],
      customParameters: {
        'locale': TranslationProvider.of(context).flutterLocale.languageCode,
      },
    );

  @override
  String get providerId => AppleAuthMethod.providerId;
}
