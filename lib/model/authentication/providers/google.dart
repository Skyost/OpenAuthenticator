import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/validation/sign_in/google.dart';
import 'package:open_authenticator/utils/validation/sign_in/oauth2.dart';

/// The Google authentication provider.
final googleAuthenticationProvider = NotifierProvider<GoogleAuthenticationProvider, FirebaseAuthenticationState>(GoogleAuthenticationProvider.new);

/// The provider that allows to sign-in using Google.
class GoogleAuthenticationProvider extends FirebaseAuthenticationProvider with LinkProvider, OAuth2AuthenticationProvider<GoogleAuthProvider> {
  /// Creates a new Google authentication provider instance.
  GoogleAuthenticationProvider()
      : super(
          availablePlatforms: const [
            Platform.android,
            Platform.iOS,
            Platform.macOS,
            Platform.windows,
          ],
        );

  @override
  GoogleAuthProvider createAuthProvider() {
    GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
    FirebaseAuthenticationState state = ref.read(firebaseAuthenticationProvider);
    if (state is FirebaseAuthenticationStateLoggedIn && state.user.email != null) {
      googleAuthProvider.setCustomParameters({
        'login_hint': state.user.email,
      });
    }
    return googleAuthProvider;
  }

  @override
  OAuth2SignIn createFallbackAuthProvider() => GoogleSignIn(
        clientId: AppCredentials.googleSignInClientId,
        timeout: fallbackTimeout,
      );

  @override
  AuthCredential createCredential(OAuth2Response response) => GoogleAuthProvider.credential(
        idToken: response.idToken,
        accessToken: response.accessToken,
      );

  @override
  void addScope(GoogleAuthProvider provider, String scope) => provider.addScope(scope);

  @override
  String get providerId => GoogleAuthProvider.PROVIDER_ID;
}
