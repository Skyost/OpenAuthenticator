import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';
import 'package:open_authenticator/utils/platform.dart';

/// The Twitter authentication provider.
final twitterAuthenticationProvider = NotifierProvider<TwitterAuthenticationProvider, FirebaseAuthenticationState>(TwitterAuthenticationProvider.new);

/// The provider that allows to sign-in using Twitter.
class TwitterAuthenticationProvider extends FirebaseAuthenticationProvider with LinkProvider {
  /// Creates a new Twitter authentication provider instance.
  TwitterAuthenticationProvider()
      : super(
          availablePlatforms: const [
            Platform.android,
            Platform.iOS,
            Platform.macOS,
          ],
        );

  @override
  TwitterAuthMethod createDefaultAuthMethod(BuildContext context) => TwitterAuthMethod.defaultMethod(
    customParameters: {
      'lang': TranslationProvider.of(context).flutterLocale.languageCode,
    },
  );

  @override
  String get providerId => TwitterAuthMethod.providerId;
}
