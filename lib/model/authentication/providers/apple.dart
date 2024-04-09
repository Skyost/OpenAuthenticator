import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/providers/result.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/utils/platform.dart';

/// The Apple authentication provider.
final appleAuthenticationProvider = NotifierProvider<AppleAuthenticationProvider, FirebaseAuthenticationState>(AppleAuthenticationProvider.new);

/// The provider that allows to sign-in using Apple.
class AppleAuthenticationProvider extends FirebaseAuthenticationProvider with LinkProvider {
  /// Creates a new Apple authentication provider instance.
  AppleAuthenticationProvider()
      : super(
          availablePlatforms: const [
            Platform.android,
            Platform.iOS,
            Platform.macOS,
          ],
        );

  @override
  @protected
  Future<FirebaseAuthenticationResult> tryTo(
    BuildContext context, {
    required Future<UserCredential> Function(AuthCredential) credentialAction,
    required Future<UserCredential> Function(AuthProvider) providerAction,
  }) async {
    AppleAuthProvider appleProvider = AppleAuthProvider();
    appleProvider.addScope('email');
    appleProvider.setCustomParameters({
      'locale': TranslationProvider.of(context).flutterLocale.languageCode,
    });
    UserCredential userCredential = await providerAction(appleProvider);
    if (userCredential.user == null) {
      return FirebaseAuthenticationError();
    }
    return FirebaseAuthenticationSuccess(email: userCredential.user!.email);
  }

  @override
  String get providerId => AppleAuthProvider.PROVIDER_ID;
}
