import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/validation/sign_in/oauth2.dart';
import 'package:open_authenticator/utils/validation/sign_in/twitter.dart';

/// The Twitter authentication provider.
final twitterAuthenticationProvider = NotifierProvider<TwitterAuthenticationProvider, FirebaseAuthenticationState>(TwitterAuthenticationProvider.new);

/// The provider that allows to sign-in using Twitter.
class TwitterAuthenticationProvider extends FirebaseAuthenticationProvider with LinkProvider, FallbackAuthenticationProvider<TwitterSignIn> {
  /// Creates a new Twitter authentication provider instance.
  TwitterAuthenticationProvider()
      : super(
          availablePlatforms: const [
            Platform.android,
            Platform.iOS,
            Platform.macOS,
            Platform.windows, // See: https://github.com/firebase/flutterfire/discussions/9398.
          ],
        );

  @override
  String get providerId => TwitterAuthMethod.providerId;

  @override
  TwitterAuthMethod createDefaultAuthMethod(BuildContext context, { List<String> scopes = const [] }) => TwitterAuthMethod.defaultMethod(
    customParameters: {
      'lang': TranslationProvider.of(context).flutterLocale.languageCode,
    },
  );

  @override
  TwitterAuthMethod createRestAuthMethod(BuildContext context, OAuth2Response response) => TwitterAuthMethod.rest(
    accessToken: response.accessToken,
  );

  @override
  TwitterSignIn createFallbackAuthProvider() => TwitterSignIn(
    clientId: AppCredentials.twitterSignInClientId,
    timeout: fallbackTimeout,
  );
}
