import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/model/settings/entry.dart';
import 'package:open_authenticator/utils/firebase_auth/default.dart';
import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/utils/validation/sign_in/email_link.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';
import 'package:open_authenticator/widgets/dialog/waiting_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The email link authentication provider.
final emailLinkAuthenticationProvider = NotifierProvider<EmailLinkAuthenticationProvider, FirebaseAuthenticationState>(EmailLinkAuthenticationProvider.new);

/// The provider that allows to sign-in using an email link.
class EmailLinkAuthenticationProvider extends FirebaseAuthenticationProvider with ConfirmationProvider<String> {
  /// The preferences key where the email is temporally stored.
  static const String _kFirebaseAuthenticationEmailKey = 'firebaseAuthenticationEmail';

  /// Creates a new email link authentication provider instance.
  EmailLinkAuthenticationProvider()
      : super(
          availablePlatforms: const [
            Platform.android,
            Platform.iOS,
            Platform.macOS,
            Platform.windows,
          ],
        );

  @override
  bool get showLoadingDialog => currentPlatform != Platform.windows;

  @override
  Future<Result<String>> trySignIn(BuildContext context) async {
    String? email = await TextInputDialog.prompt(
      context,
      title: translations.authentication.emailDialog.title,
      message: translations.authentication.emailDialog.message,
      validator: TextInputDialog.validateEmail,
      keyboardType: TextInputType.emailAddress,
    );
    if (email == null) {
      return const ResultCancelled();
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    ActionCodeSettings actionCodeSettings = ActionCodeSettings(
      url: App.firebaseLoginUrl,
      handleCodeInApp: true,
      androidPackageName: packageInfo.packageName,
      iOSBundleId: packageInfo.packageName,
    );
    if (currentPlatform == Platform.windows) {
      EmailLinkSignIn emailLinkSignIn = EmailLinkSignIn(email: email);
      Result<EmailLinkSignInResponse> result;
      if (context.mounted) {
        result = await showWaitingOverlay(
          context,
          future: emailLinkSignIn.sendSignInLinkToEmailAndWaitForConfirmation(),
          message: translations.authentication.logIn.waitingConfirmationMessage,
          timeout: emailLinkSignIn.timeout,
        );
      } else {
        result = await emailLinkSignIn.sendSignInLinkToEmailAndWaitForConfirmation();
      }
      switch (result) {
        case ResultSuccess(:final value):
          SignInResult result = await FirebaseAuth.instance.signInWith(
            EmailLinkAuthMethod.rest(
              email: value.email,
              oobCode: value.oobCode,
            ),
          );
          return ResultSuccess(value: result.email);
        default:
          return result.to((result) => null);
      }
    } else {
      EmailLinkAuthMethodDefault.sendSignInLink(email, actionCodeSettings);
    }
    SharedPreferences preferences = await ref.read(sharedPreferencesProvider.future);
    bool result = await preferences.setString(_kFirebaseAuthenticationEmailKey, email);
    if (result) {
      ref.invalidateSelf();
    }
    return ResultSuccess(value: email);
  }

  /// Reads the email to confirm from preferences.
  Future<String?> readEmailToConfirmFromPreferences() async {
    SharedPreferences preferences = await ref.read(sharedPreferencesProvider.future);
    return preferences.getString(_kFirebaseAuthenticationEmailKey);
  }

  @override
  Future<bool> isWaitingForConfirmation() async => (await readEmailToConfirmFromPreferences()) != null;

  @override
  Future<Result> cancelConfirmation() async {
    try {
      SharedPreferences preferences = await ref.read(sharedPreferencesProvider.future);
      bool result = await preferences.remove(_kFirebaseAuthenticationEmailKey);
      if (result) {
        ref.invalidateSelf();
      }
      return const ResultSuccess();
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }

  @override
  Future<Result<String>> tryConfirm(String? emailLink) async {
    SharedPreferences preferences = await ref.read(sharedPreferencesProvider.future);
    if (emailLink == null) {
      return ResultError();
    }
    SignInResult signInResult;
    String email = preferences.getString(_kFirebaseAuthenticationEmailKey)!;
    if (currentPlatform == Platform.windows) {
      Result<EmailLinkSignInResponse> result = await EmailLinkSignIn(email: email).validateUrl(emailLink);
      switch (result) {
        case ResultSuccess(:final value):
          signInResult = await FirebaseAuth.instance.signInWith(
            EmailLinkAuthMethod.rest(
              email: value.email,
              oobCode: value.oobCode,
            ),
          );
          break;
        default:
          return result.to((result) => null);
      }
    } else {
      signInResult = await FirebaseAuth.instance.signInWith(
        EmailLinkAuthMethod.defaultMethod(
          email: email,
          emailLink: emailLink,
        ),
      );
    }
    bool result = await preferences.remove(_kFirebaseAuthenticationEmailKey);
    if (result) {
      ref.invalidateSelf();
    }
    return ResultSuccess(value: signInResult.email);
  }

  @override
  String get providerId => EmailLinkAuthMethod.providerId;
}
