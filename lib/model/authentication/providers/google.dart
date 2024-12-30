import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/validation/sign_in/google.dart';
import 'package:open_authenticator/utils/validation/sign_in/oauth2.dart';

/// The Google authentication provider.
final googleAuthenticationProvider = Provider<GoogleAuthenticationProvider>((ref) {
  FirebaseAuthenticationState authenticationState = ref.watch(firebaseAuthenticationProvider);
  return GoogleAuthenticationProvider(
    loginHint: authenticationState is FirebaseAuthenticationStateLoggedIn ? authenticationState.user.email : null,
  );
});

/// The Google authentication state provider.
final googleAuthenticationStateProvider = NotifierProvider<FirebaseAuthenticationProviderNotifier, FirebaseAuthenticationState>(
  () => FirebaseAuthenticationProviderNotifier(googleAuthenticationProvider),
);

/// The provider that allows to sign-in using Google.
class GoogleAuthenticationProvider extends FirebaseAuthenticationProvider with LinkProvider, FallbackAuthenticationProvider<GoogleSignIn> {
  /// The login hint.
  final String? loginHint;

  /// Creates a new Google authentication provider instance.
  const GoogleAuthenticationProvider({
    this.loginHint,
  }) : super(
          availablePlatforms: const [
            Platform.android,
            Platform.iOS,
            Platform.windows,
          ],
        );

  @override
  String get providerId => GoogleAuthMethod.providerId;

  @override
  GoogleAuthMethod createDefaultAuthMethod(BuildContext context, {List<String> scopes = const []}) {
    Map<String, String> customParameters = {};
    if (loginHint != null) {
      customParameters['login_hint'] = loginHint!;
    }
    return GoogleAuthMethod.defaultMethod(
      scopes: scopes,
      customParameters: customParameters,
    );
  }

  @override
  GoogleAuthMethod createRestAuthMethod(BuildContext context, OAuth2Response response) => GoogleAuthMethod.rest(
        idToken: response.idToken,
        accessToken: response.accessToken,
      );

  @override
  GoogleSignIn createFallbackAuthProvider() => GoogleSignIn(
        clientId: AppCredentials.googleSignInClientId,
        timeout: fallbackTimeout,
      );
}
