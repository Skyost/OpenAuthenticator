import 'dart:async';

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
import 'package:open_authenticator/utils/shared_preferences_with_prefix.dart';
import 'package:open_authenticator/utils/validation/sign_in/email.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// The email link authentication state provider.
final emailLinkConfirmationStateProvider = AsyncNotifierProvider<EmailLinkConfirmationStateNotifier, String?>(EmailLinkConfirmationStateNotifier.new);

/// The email link confirmation state notifier.
class EmailLinkConfirmationStateNotifier extends AsyncNotifier<String?> {
  /// The preferences key where the email is temporally stored.
  static const String _kFirebaseAuthenticationEmailKey = 'firebaseAuthenticationEmail';

  @override
  FutureOr<String?> build() async {
    SharedPreferencesWithPrefix preferences = await ref.read(sharedPreferencesProvider.future);
    return preferences.getString(_kFirebaseAuthenticationEmailKey);
  }

  /// Marks the [email] for confirmation.
  Future<void> markNeedsConfirmation(String email) async {
    if ((await future) != null) {
      return;
    }
    SharedPreferencesWithPrefix preferences = await ref.read(sharedPreferencesProvider.future);
    await preferences.setString(_kFirebaseAuthenticationEmailKey, email);
    state = AsyncData(email);
  }

  /// Cancels the confirmation.
  Future<Result> cancelConfirmation() async {
    try {
      SharedPreferencesWithPrefix preferences = await ref.read(sharedPreferencesProvider.future);
      await preferences.remove(_kFirebaseAuthenticationEmailKey);
      state = AsyncData(null);
      return const ResultSuccess();
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }

  /// Confirms the log in with the given [emailLink].
  Future<Result<AuthenticationObject>> confirm(BuildContext context, String emailLink) async {
    try {
      SharedPreferencesWithPrefix preferences = await ref.read(sharedPreferencesProvider.future);
      String email = preferences.getString(_kFirebaseAuthenticationEmailKey)!;
      EmailLinkAuthMethod method;
      if (currentPlatform == Platform.windows) {
        Result<EmailSignInResponse> result = await EmailSignIn(email: email).validateUrl(emailLink);
        if (result is! ResultSuccess) {
          return result.to((result) => null);
        }
        EmailSignInResponse response = (result as ResultSuccess<EmailSignInResponse>).value;
        method = EmailLinkAuthMethod.rest(
          email: response.email,
          oobCode: response.oobCode,
        );
      } else {
        method = EmailLinkAuthMethod.defaultMethod(
          email: email,
          emailLink: emailLink,
        );
      }
      if (!context.mounted) {
        return const ResultCancelled();
      }
      SignInResult signInResult = await showWaitingOverlay(
        context,
        future: FirebaseAuth.instance.signInWith(method),
      );
      await preferences.remove(_kFirebaseAuthenticationEmailKey);
      state = AsyncData(null);
      return ResultSuccess(
        value: AuthenticationObject(
          email: signInResult.email,
        ),
      );
    } catch (ex, stacktrace) {
      return ResultError(
        exception: FirebaseAuthenticationException(ex),
        stacktrace: stacktrace,
      );
    }
  }
}

/// The email link authentication state provider.
final emailLinkAuthenticationStateProvider = NotifierProvider<FirebaseAuthenticationStateNotifier, FirebaseAuthenticationState>(
  () => FirebaseAuthenticationStateNotifier(EmailLinkAuthenticationProvider()),
);

/// The provider that allows to sign-in using an email link.
class EmailLinkAuthenticationProvider extends FirebaseAuthenticationProvider with LinkProvider {
  /// Creates a new email link authentication provider instance.
  const EmailLinkAuthenticationProvider()
      : super(
          availablePlatforms: const [
            Platform.android,
            Platform.iOS,
            Platform.macOS,
            Platform.windows,
          ],
        );

  @override
  bool get showLoadingDialog => false;

  @override
  Future<Result<EmailLinkAuthenticationObject>> trySignIn(BuildContext context) async {
    String? email = await TextInputDialog.prompt(
      context,
      title: translations.authentication.emailDialog.title,
      message: translations.authentication.emailDialog.message,
      validator: TextInputDialog.validateEmail,
      keyboardType: TextInputType.emailAddress,
    );
    if (email == null || !context.mounted) {
      return const ResultCancelled();
    }
    return await _tryAuthenticate(context, email);
  }

  @override
  Future<Result<EmailLinkAuthenticationObject>> tryReAuthenticate(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw _ReAuthenticateException(message: 'User must be logged in before re-authenticating.');
    }
    if (!context.mounted) {
      return const ResultCancelled();
    }
    String? email;
    if (user.email == null) {
      email = await TextInputDialog.prompt(
        context,
        title: translations.authentication.emailDialog.title,
        message: translations.authentication.emailDialog.message,
        validator: TextInputDialog.validateEmail,
        keyboardType: TextInputType.emailAddress,
      );
    }
    if (email == null || !context.mounted) {
      return const ResultCancelled();
    }
    return await _tryAuthenticate(context, email);
  }

  /// Tries to authenticate the user with the given [email].
  Future<Result<EmailLinkAuthenticationObject>> _tryAuthenticate(BuildContext context, String email) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    ActionCodeSettings actionCodeSettings = ActionCodeSettings(
      url: App.firebaseLoginUrl,
      handleCodeInApp: true,
      androidPackageName: packageInfo.packageName,
      iOSBundleId: packageInfo.packageName,
    );
    if (!context.mounted) {
      return const ResultCancelled();
    }
    if (currentPlatform == Platform.windows || currentPlatform == Platform.macOS) {
      EmailSignIn emailLinkSignIn = EmailSignIn(email: email);
      Result<EmailSignInResponse> result = await showWaitingOverlay(
        context,
        future: emailLinkSignIn.sendLinkToEmailAndWaitForConfirmation(),
        message: translations.authentication.logIn.waitingConfirmationMessage,
        timeout: emailLinkSignIn.timeout,
      );
      if (!context.mounted) {
        return const ResultCancelled();
      }
      switch (result) {
        case ResultSuccess(:final value):
          SignInResult result = await showWaitingOverlay(
            context,
            future: FirebaseAuth.instance.signInWith(
              currentPlatform == Platform.windows
                  ? EmailLinkAuthMethod.rest(
                      email: value.email,
                      oobCode: value.oobCode,
                    )
                  : EmailLinkAuthMethod.defaultMethod(
                      email: email,
                      emailLink: value.uri.toString(),
                    ),
            ),
          );
          return ResultSuccess(
            value: EmailLinkAuthenticationObject(
              email: result.email ?? value.email,
            ),
          );
        default:
          return result.to((result) => null);
      }
    } else {
      await showWaitingOverlay(
        context,
        future: EmailLinkAuthMethodDefault.sendSignInLink(email, actionCodeSettings),
      );
    }
    return ResultSuccess(
      value: EmailLinkAuthenticationObject(
        email: email,
        needValidation: true,
      ),
    );
  }

  @override
  String get providerId => EmailLinkAuthMethod.providerId;

  @override
  Future<Result<AuthenticationObject>> tryLink(BuildContext context) async => await tryReAuthenticate(context);
}

/// An email link authentication object.
class EmailLinkAuthenticationObject extends AuthenticationObject {
  /// Whether the email needs validation.
  final bool needValidation;

  /// Creates a new email link authentication object instance.
  const EmailLinkAuthenticationObject({
    required String super.email,
    this.needValidation = false,
  });

  @override
  String get email => super.email!;
}

/// Triggered when an error occurs while re-authenticating the user.
class _ReAuthenticateException implements Exception {
  /// The error message.
  final String message;

  /// Creates a new re-authentication exception instance.
  const _ReAuthenticateException({
    required this.message,
  });

  @override
  String toString() => message;
}
