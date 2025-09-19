import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/validation/sign_in/oauth2.dart';
import 'package:open_authenticator/utils/validation/sign_in/twitter.dart';

/// The Twitter authentication state provider.
final twitterAuthenticationStateProvider = NotifierProvider<FirebaseAuthenticationStateNotifier, FirebaseAuthenticationState>(
  () => FirebaseAuthenticationStateNotifier(const TwitterAuthenticationProvider()),
);

/// The provider that allows to sign in using Twitter.
class TwitterAuthenticationProvider extends FallbackAuthenticationProvider<TwitterSignIn> {
  /// Creates a new Twitter authentication provider instance.
  const TwitterAuthenticationProvider()
    : super(
        availablePlatforms: const [
          Platform.android,
          Platform.iOS,
          // Platform.windows, // See: https://github.com/firebase/flutterfire/discussions/9398.
        ],
      );

  @override
  String get providerId => TwitterAuthMethod.providerId;

  @override
  TwitterAuthMethod createDefaultAuthMethod({List<String> scopes = const []}) => TwitterAuthMethod.defaultMethod(
    customParameters: {
      'lang': translations.$meta.locale.languageCode,
    },
  );

  @override
  TwitterAuthMethod createRestAuthMethod(OAuth2Response response) => TwitterAuthMethod.rest(
    accessToken: response.accessToken,
  );

  @override
  TwitterSignIn createFallbackAuthProvider() => TwitterSignIn(
    clientId: AppCredentials.twitterSignInClientId,
    timeout: fallbackTimeout,
  );

  @override
  bool get isTrusted => false;
}
