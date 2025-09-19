import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/validation/sign_in/apple.dart';
import 'package:open_authenticator/utils/validation/sign_in/oauth2.dart';

/// The Apple authentication state provider.
final appleAuthenticationStateProvider = NotifierProvider<FirebaseAuthenticationStateNotifier, FirebaseAuthenticationState>(
  () => FirebaseAuthenticationStateNotifier(const AppleAuthenticationProvider()),
);

/// The provider that allows to sign in using Apple.
class AppleAuthenticationProvider extends FallbackAuthenticationProvider<AppleSignIn> {
  /// Creates a new Apple authentication provider instance.
  const AppleAuthenticationProvider()
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
  AppleAuthMethod createDefaultAuthMethod({List<String> scopes = const []}) => AppleAuthMethod.defaultMethod(
    scopes: scopes,
    customParameters: {
      'locale': translations.$meta.locale.languageCode,
    },
  );

  @override
  AppleAuthMethod createRestAuthMethod(OAuth2Response response) => AppleAuthMethod.rest(
    idToken: response.idToken,
    nonce: response.nonce,
  );

  @override
  AppleSignIn createFallbackAuthProvider() => AppleSignIn(
    clientId: 'app.openauthenticator.service',
  );
}
