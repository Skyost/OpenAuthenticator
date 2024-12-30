import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/validation/sign_in/microsoft.dart';
import 'package:open_authenticator/utils/validation/sign_in/oauth2.dart';

/// The Microsoft authentication provider.
final microsoftAuthenticationProvider = Provider<MicrosoftAuthenticationProvider>((ref) {
  FirebaseAuthenticationState authenticationState = ref.watch(firebaseAuthenticationProvider);
  return MicrosoftAuthenticationProvider(
    loginHint: authenticationState is FirebaseAuthenticationStateLoggedIn ? authenticationState.user.email : null,
  );
});

/// The Microsoft authentication state provider.
final microsoftAuthenticationStateProvider = NotifierProvider<FirebaseAuthenticationProviderNotifier, FirebaseAuthenticationState>(
  () => FirebaseAuthenticationProviderNotifier(microsoftAuthenticationProvider),
);

/// The provider that allows to sign-in using Microsoft.
class MicrosoftAuthenticationProvider extends FirebaseAuthenticationProvider with LinkProvider, FallbackAuthenticationProvider<MicrosoftSignIn> {
  /// The login hint.
  final String? loginHint;

  /// Creates a new Microsoft authentication provider instance.
  const MicrosoftAuthenticationProvider({
    this.loginHint,
  }) : super(
          availablePlatforms: const [
            Platform.android,
            Platform.iOS,
            // Platform.windows, See: https://firebase.google.com/docs/auth/cpp/microsoft-oauth#expandable-2.
          ],
        );

  @override
  String get providerId => MicrosoftAuthMethod.providerId;

  @override
  MicrosoftAuthMethod createDefaultAuthMethod(BuildContext context, {List<String> scopes = const []}) {
    Map<String, String> customParameters = {};
    if (loginHint != null) {
      customParameters['login_hint'] = loginHint!;
    }
    return MicrosoftAuthMethod.defaultMethod(
      scopes: scopes,
      customParameters: customParameters,
    );
  }

  @override
  MicrosoftAuthMethod createRestAuthMethod(BuildContext context, OAuth2Response response) => MicrosoftAuthMethod.rest(
        accessToken: response.accessToken,
        idToken: response.idToken,
        nonce: response.nonce,
      );

  @override
  MicrosoftSignIn createFallbackAuthProvider() => MicrosoftSignIn(
        clientId: AppCredentials.azureSignInClientId,
        timeout: fallbackTimeout,
      );
}
