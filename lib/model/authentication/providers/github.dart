import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/validation/sign_in/github.dart';
import 'package:open_authenticator/utils/validation/sign_in/oauth2.dart';

/// The Github authentication state provider.
final githubAuthenticationStateProvider = NotifierProvider<FirebaseAuthenticationStateNotifier, FirebaseAuthenticationState>(
  () => FirebaseAuthenticationStateNotifier(GithubAuthenticationProvider()),
);

/// The provider that allows to sign-in using Github.
class GithubAuthenticationProvider extends FallbackAuthenticationProvider<GithubSignIn> {
  /// Creates a new Github authentication provider instance.
  const GithubAuthenticationProvider()
      : super(
          availablePlatforms: const [
            Platform.android,
            Platform.iOS,
            Platform.windows,
          ],
        );

  @override
  String get providerId => GithubAuthMethod.providerId;

  @override
  GithubAuthMethod createDefaultAuthMethod(BuildContext context, {List<String> scopes = const []}) => GithubAuthMethod.defaultMethod(
        scopes: scopes,
      );

  @override
  GithubAuthMethod createRestAuthMethod(BuildContext context, OAuth2Response response) => GithubAuthMethod.rest(
        accessToken: response.accessToken,
      );

  @override
  GithubSignIn createFallbackAuthProvider() => GithubSignIn(
        clientId: AppCredentials.githubSignInClientId,
      );

  @override
  bool get showLoadingDialog => false;

  @override
  bool get isTrusted => false;
}
