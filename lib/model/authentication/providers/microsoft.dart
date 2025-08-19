import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/validation/sign_in/microsoft.dart';
import 'package:open_authenticator/utils/validation/sign_in/oauth2.dart';

/// The Microsoft authentication state provider.
final microsoftAuthenticationStateProvider = NotifierProvider<FirebaseAuthenticationStateNotifier, FirebaseAuthenticationState>(
  () => FirebaseAuthenticationStateNotifier(const MicrosoftAuthenticationProvider()),
);

/// The provider that allows to sign in using Microsoft.
class MicrosoftAuthenticationProvider extends FallbackAuthenticationProvider<MicrosoftSignIn> {
  /// Creates a new Microsoft authentication provider instance.
  const MicrosoftAuthenticationProvider()
      : super(
          availablePlatforms: const [
            Platform.android,
            Platform.iOS,
            // Platform.windows, See: https://firebase.google.com/docs/auth/cpp/microsoft-oauth#expandable-2.
          ],
        );

  @override
  String get providerId => MicrosoftAuthMethod.providerId;

  @override
  MicrosoftAuthMethod createDefaultAuthMethod({List<String> scopes = const []}) {
    String? loginHint = FirebaseAuth.instance.currentUser?.email;
    return MicrosoftAuthMethod.defaultMethod(
      scopes: scopes,
      customParameters: {
        if (loginHint != null) 'login_hint': loginHint,
      },
    );
  }

  @override
  MicrosoftAuthMethod createRestAuthMethod(OAuth2Response response) => MicrosoftAuthMethod.rest(
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
