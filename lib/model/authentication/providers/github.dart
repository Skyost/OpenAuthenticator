import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/validation/sign_in/github.dart';
import 'package:open_authenticator/utils/validation/sign_in/oauth2.dart';

/// The Github authentication provider.
final githubAuthenticationProvider = NotifierProvider<GithubAuthenticationProvider, FirebaseAuthenticationState>(GithubAuthenticationProvider.new);

/// The provider that allows to sign-in using Github.
class GithubAuthenticationProvider extends FirebaseAuthenticationProvider with LinkProvider, OAuth2AuthenticationProvider<GithubAuthProvider> {
  /// Creates a new Github authentication provider instance.
  GithubAuthenticationProvider()
      : super(
          availablePlatforms: const [
            Platform.android,
            Platform.iOS,
            Platform.macOS,
            Platform.windows,
          ],
        );

  @override
  GithubAuthProvider createAuthProvider() => GithubAuthProvider();

  @override
  OAuth2SignIn createFallbackAuthProvider() => GithubSignIn(
        clientId: AppCredentials.githubSignInClientId,
      );

  @override
  AuthCredential createCredential(OAuth2Response response) => OAuthProvider(GithubAuthProvider.PROVIDER_ID).credential(
        signInMethod: GithubAuthProvider.GITHUB_SIGN_IN_METHOD,
        accessToken: response.accessToken,
        idToken: '',
      );

  @override
  void addScope(GithubAuthProvider provider, String scope) => provider.addScope(scope);

  @override
  String get providerId => GithubAuthProvider.PROVIDER_ID;
}
