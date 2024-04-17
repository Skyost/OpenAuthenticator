import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/validation/sign_in/apple.dart';
import 'package:open_authenticator/utils/validation/sign_in/oauth2.dart';

/// The Apple authentication provider.
final appleAuthenticationProvider = NotifierProvider<AppleAuthenticationProvider, FirebaseAuthenticationState>(AppleAuthenticationProvider.new);

/// The provider that allows to sign-in using Apple.
class AppleAuthenticationProvider extends FirebaseAuthenticationProvider with LinkProvider, FallbackAuthenticationProvider<AppleSignIn> {
  /// Creates a new Apple authentication provider instance.
  AppleAuthenticationProvider()
      : super(
          availablePlatforms: const [
            Platform.android,
            Platform.iOS,
            Platform.macOS,
            Platform.windows,
          ],
        );

  @override
  String get providerId => AppleAuthMethod.providerId;

  @override
  AppleAuthMethod createDefaultAuthMethod(BuildContext context, {List<String> scopes = const []}) => AppleAuthMethod.defaultMethod(
      scopes: scopes,
      customParameters: {
        'locale': TranslationProvider.of(context).flutterLocale.languageCode,
      },
    );

  @override
  AppleAuthMethod createRestAuthMethod(BuildContext context, OAuth2Response response) => AppleAuthMethod.rest(
    idToken: response.idToken,
    nonce: response.nonce,
  );

  @override
  AppleSignIn createFallbackAuthProvider() => AppleSignIn(
    clientId: 'app.openauthenticator.service',
  );
}
