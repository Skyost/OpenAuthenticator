import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/provider.dart';
import 'package:open_authenticator/model/authentication/result.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/widgets/dialog/authentication_provider_picker.dart';
import 'package:open_authenticator/widgets/dialog/confirmation_dialog.dart';
import 'package:open_authenticator/widgets/dialog/waiting_dialog.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';

/// Contains some useful methods for logging and linking the user's current account.
class AccountUtils {
  /// Prompts the user to choose an authentication provider, and use it to login.
  static Future<void> trySignIn(BuildContext context, WidgetRef ref) async {
    FirebaseAuthenticationProvider? provider = await AuthenticationProviderPickerDialog.openDialog(context);
    if (provider == null || !context.mounted) {
      return;
    }
    return await _tryTo(
      context,
      ref,
      provider,
      waitingDialogMessage: translations.authentication.logIn.waitingDialogMessage,
      action: ref.read(firebaseAuthenticationProvider.notifier).trySignIn,
      timeoutMessage: translations.authentication.logIn.error.timeout,
    );
  }

  /// Prompts the user to choose an authentication provider, and use it to link or unlink its current account.
  static Future<void> tryToggleLink(BuildContext context, WidgetRef ref) async {
    FirebaseAuthenticationProvider? provider = await AuthenticationProviderPickerDialog.openDialog(context, link: true);
    if (provider == null || !context.mounted) {
      return;
    }
    bool unlink = ref.read(userAuthenticationProviders).contains(provider);
    if (unlink &&
        !(await ConfirmationDialog.ask(context, title: translations.authentication.unlink.confirmationDialog.title, message: translations.authentication.unlink.confirmationDialog.message))) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    return await _tryTo(
      context,
      ref,
      provider,
      waitingDialogMessage: unlink ? null : translations.authentication.logIn.waitingDialogMessage,
      action: unlink ? ref.read(firebaseAuthenticationProvider.notifier).tryUnlink : ref.read(firebaseAuthenticationProvider.notifier).tryLink,
      timeoutMessage: unlink ? translations.authentication.unlink.error.timeout : translations.authentication.linkErrorTimeout,
    );
  }

  /// Tries to do the specified [action].
  static Future<void> _tryTo(
    BuildContext context,
    WidgetRef ref,
    FirebaseAuthenticationProvider provider, {
    required Future<FirebaseAuthenticationResult> Function(BuildContext, FirebaseAuthenticationProvider) action,
    String? waitingDialogMessage,
    String? timeoutMessage,
  }) async {
    FirebaseAuthenticationResult result;
    try {
      result = await showWaitingDialog(
        context,
        future: action(context, provider),
        message: waitingDialogMessage,
        timeout: provider is OAuth2AuthenticationProvider && provider.shouldFallback ? provider.fallbackTimeout : null,
        timeoutMessage: timeoutMessage,
      );
    } catch (ex, stacktrace) {
      result = FirebaseAuthenticationResultError(ex is Exception ? ex : null);
      if (kDebugMode) {
        print(ex);
        print(stacktrace);
      }
    }
    if (context.mounted) {
      _handleResult(context, ref, result);
    }
  }

  /// Handles the [result].
  static Future<void> _handleResult(BuildContext context, WidgetRef ref, FirebaseAuthenticationResult result) async {
    switch (result) {
      case FirebaseAuthenticationResultSuccess():
        FirebaseAuthenticationState authenticationState = await ref.read(firebaseAuthenticationProvider.future);
        if (!context.mounted) {
          return;
        }
        switch (authenticationState) {
          case FirebaseAuthenticationStateLoggedOut():
            SnackBarIcon.showErrorSnackBar(context, text: translations.authentication.logIn.error.generic);
            break;
          case FirebaseAuthenticationStateWaitingForConfirmation():
            SnackBarIcon.showSuccessSnackBar(context, text: translations.authentication.logIn.successNeedConfirmation);
            break;
          case FirebaseAuthenticationStateLoggedIn():
            SnackBarIcon.showSuccessSnackBar(context, text: translations.authentication.logIn.success);
            break;
        }
        break;
      case FirebaseAuthenticationResultErrorAccountExistsWithDifferentCredential():
        showAdaptiveDialog(
          context: context,
          builder: (context) => AlertDialog.adaptive(
            title: Text(translations.authentication.logIn.error.accountExistsWithDifferentCredentialsDialog.title),
            scrollable: true,
            content: Text(translations.authentication.logIn.error.accountExistsWithDifferentCredentialsDialog.message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  trySignIn(context, ref);
                },
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
              ),
            ],
          ),
        );
        break;
      case FirebaseAuthenticationResultErrorInvalidCredential():
        SnackBarIcon.showErrorSnackBar(context, text: translations.authentication.logIn.error.invalidCredential);
        break;
      case FirebaseAuthenticationResultErrorOperationNotAllowed():
        SnackBarIcon.showErrorSnackBar(context, text: translations.authentication.logIn.error.operationNotAllowed);
        break;
      case FirebaseAuthenticationResultErrorUserDisabled():
        SnackBarIcon.showErrorSnackBar(context, text: translations.authentication.logIn.error.userDisabled);
        break;
      case FirebaseAuthenticationResultFirebaseError(:final exception):
        SnackBarIcon.showErrorSnackBar(context, text: translations.authentication.logIn.error.firebaseException(exception: exception));
        break;
      case FirebaseAuthenticationResultError(:final exception):
        SnackBarIcon.showErrorSnackBar(context, text: translations.authentication.logIn.error.exception(exception: exception as Object));
        break;
    }
  }
}
