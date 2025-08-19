import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/validation/sign_in/google.dart';
import 'package:open_authenticator/utils/validation/sign_in/oauth2.dart';

/// The Google authentication state provider.
final googleAuthenticationStateProvider = NotifierProvider<FirebaseAuthenticationStateNotifier, FirebaseAuthenticationState>(
  () => FirebaseAuthenticationStateNotifier(const GoogleAuthenticationProvider()),
);

/// The provider that allows to sign in using Google.
class GoogleAuthenticationProvider extends FallbackAuthenticationProvider<GoogleSignIn> {
  /// Creates a new Google authentication provider instance.
  const GoogleAuthenticationProvider()
      : super(
          availablePlatforms: const [
            Platform.android,
            Platform.iOS,
            Platform.windows,
          ],
        );

  @override
  String get providerId => GoogleAuthMethod.providerId;

  @override
  GoogleAuthMethod createDefaultAuthMethod({List<String> scopes = const []}) {
    String? loginHint = FirebaseAuth.instance.currentUser?.email;
    return GoogleAuthMethod.defaultMethod(
      scopes: scopes,
      customParameters: {
        if (loginHint != null) 'login_hint': loginHint,
      },
    );
  }

  @override
  GoogleAuthMethod createRestAuthMethod(OAuth2Response response) => GoogleAuthMethod.rest(
        idToken: response.idToken,
        accessToken: response.accessToken,
      );

  @override
  GoogleSignIn createFallbackAuthProvider() => GoogleSignIn(
        clientId: AppCredentials.googleSignInClientId,
        timeout: fallbackTimeout,
      );
}
