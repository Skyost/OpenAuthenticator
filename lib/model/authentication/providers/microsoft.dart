import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/validation/sign_in/microsoft.dart';
import 'package:open_authenticator/utils/validation/sign_in/oauth2.dart';

/// The Microsoft authentication provider.
final microsoftAuthenticationProvider = NotifierProvider<MicrosoftAuthenticationProvider, FirebaseAuthenticationState>(MicrosoftAuthenticationProvider.new);

/// The provider that allows to sign-in using Microsoft.
class MicrosoftAuthenticationProvider extends FirebaseAuthenticationProvider with LinkProvider, OAuth2AuthenticationProvider<MicrosoftAuthProvider> {
  /// Creates a new Microsoft authentication provider instance.
  MicrosoftAuthenticationProvider()
      : super(
          availablePlatforms: const [
            Platform.android,
            Platform.iOS,
            Platform.macOS,
            Platform.windows,
          ],
        );

  @override
  MicrosoftAuthProvider createAuthProvider() {
    MicrosoftAuthProvider microsoftAuthProvider = MicrosoftAuthProvider();
    FirebaseAuthenticationState state = ref.read(firebaseAuthenticationProvider);
    if (state is FirebaseAuthenticationStateLoggedIn && state.user.email != null) {
      microsoftAuthProvider.setCustomParameters({
        'login_hint': state.user.email!,
      });
    }
    return microsoftAuthProvider;
  }

  @override
  OAuth2SignIn createFallbackAuthProvider() => MicrosoftSignIn(
        clientId: AppCredentials.azureSignInClientId,
        timeout: fallbackTimeout,
      );

  @override
  AuthCredential createCredential(OAuth2Response response) => OAuthProvider(MicrosoftAuthProvider.PROVIDER_ID).credential(
        signInMethod: MicrosoftAuthProvider.MICROSOFT_SIGN_IN_METHOD,
        accessToken: response.accessToken,
        idToken: response.idToken,
        rawNonce: response.nonce,
      );

  @override
  void addScope(MicrosoftAuthProvider provider, String scope) => provider.addScope(scope);

  @override
  String get providerId => MicrosoftAuthProvider.PROVIDER_ID;
}
