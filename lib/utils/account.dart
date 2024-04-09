import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/providers/result.dart';
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
      waitingDialogMessage: translations.authentication.logIn.waitingLoginMessage,
      action: (context, provider) => provider.signIn(context),
      timeoutMessage: translations.authentication.logIn.error.timeoutDialog.message,
    );
  }

  /// Prompts the user to choose an authentication provider, and use it to link or unlink its current account.
  static Future<void> tryToggleLink(BuildContext context, WidgetRef ref) async {
    LinkProvider? provider = await AuthenticationProviderPickerDialog.openDialog(context, link: true) as LinkProvider?;
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
    return await _tryTo<LinkProvider>(
      context,
      ref,
      provider,
      waitingDialogMessage: unlink ? null : translations.authentication.logIn.waitingLoginMessage,
      action: unlink ? ((context, provider) => provider.unlink(context)) : ((context, provider) => provider.link(context)),
      timeoutMessage: unlink ? translations.authentication.unlink.error.timeout : translations.authentication.linkErrorTimeout,
    );
  }

  /// Tries to do the specified [action].
  static Future<void> _tryTo<T extends FirebaseAuthenticationProvider>(
    BuildContext context,
    WidgetRef ref,
    T provider, {
    required Future<FirebaseAuthenticationResult> Function(BuildContext, T) action,
    String? waitingDialogMessage,
    String? timeoutMessage,
  }) async {
    FirebaseAuthenticationResult result;
    try {
      if (provider.showLoadingDialog) {
        result = await showWaitingOverlay(
          context,
          future: action(context, provider),
          message: waitingDialogMessage,
          timeout: provider is OAuth2AuthenticationProvider && provider.shouldFallback ? provider.fallbackTimeout : null,
          timeoutMessage: timeoutMessage,
        );
      } else {
        result = await action(context, provider);
      }
    } catch (ex, stacktrace) {
      result = FirebaseAuthenticationError(ex is Exception ? ex : null);
      if (kDebugMode) {
        print(ex);
        print(stacktrace);
      }
    }
    if (context.mounted) {
      handleAuthenticationResult(
        context,
        ref,
        provider,
        result,
        handleDifferentCredentialError: true,
      );
    }
  }

  /// Handles the [result].
  static Future<void> handleAuthenticationResult(
    BuildContext context,
    WidgetRef ref,
    FirebaseAuthenticationProvider provider,
    FirebaseAuthenticationResult result, {
    bool handleDifferentCredentialError = false,
  }) async {
    switch (result) {
      case FirebaseAuthenticationSuccess():
        if (provider is ConfirmationProvider) {
          SnackBarIcon.showSuccessSnackBar(context, text: translations.authentication.logIn.successNeedConfirmation);
        } else {
          SnackBarIcon.showSuccessSnackBar(context, text: translations.authentication.logIn.success);
        }
        break;
      case FirebaseAuthenticationCancelled(:final timedOut):
        if (timedOut) {
          showAdaptiveDialog(
            context: context,
            builder: (context) => AlertDialog.adaptive(
              title: Text(translations.authentication.logIn.error.timeoutDialog.title),
              scrollable: true,
              content: Text(translations.authentication.logIn.error.timeoutDialog.message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(MaterialLocalizations.of(context).okButtonLabel),
                ),
              ],
            ),
          );
        }
        break;
      case FirebaseAuthenticationErrorAccountExistsWithDifferentCredential():
        if (handleDifferentCredentialError) {
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
        } else {
          SnackBarIcon.showErrorSnackBar(context, text: translations.authentication.logIn.error.accountExistsWithDifferentCredentialsDialog.message);
        }
        break;
      case FirebaseAuthenticationErrorInvalidCredential():
        SnackBarIcon.showErrorSnackBar(context, text: translations.authentication.logIn.error.invalidCredential);
        break;
      case FirebaseAuthenticationErrorOperationNotAllowed():
        SnackBarIcon.showErrorSnackBar(context, text: translations.authentication.logIn.error.operationNotAllowed);
        break;
      case FirebaseAuthenticationErrorUserDisabled():
        SnackBarIcon.showErrorSnackBar(context, text: translations.authentication.logIn.error.userDisabled);
        break;
      case FirebaseAuthenticationFirebaseError(:final exception):
        SnackBarIcon.showErrorSnackBar(context, text: translations.authentication.logIn.error.firebaseException(exception: exception));
        break;
      case FirebaseAuthenticationError(:final exception):
        if (exception == null) {
          SnackBarIcon.showErrorSnackBar(context, text: translations.authentication.logIn.error.generic);
        } else {
          SnackBarIcon.showErrorSnackBar(context, text: translations.authentication.logIn.error.exception(exception: exception as Object));
        }
        break;
    }
  }
}
