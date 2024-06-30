import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/dialog/authentication_provider_picker.dart';
import 'package:open_authenticator/widgets/dialog/confirmation_dialog.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';

/// Contains some useful methods for logging and linking the user's current account.
class AccountUtils {
  /// Prompts the user to choose an authentication provider, and use it to login.
  static Future<void> trySignIn(BuildContext context, WidgetRef ref) async {
    FirebaseAuthenticationProvider? provider = await AuthenticationProviderPickerDialog.openDialog(context);
    if (provider == null || !context.mounted) {
      return;
    }
    await _tryTo(
      context,
      ref,
      provider,
      waitingDialogMessage: translations.authentication.logIn.waitingLoginMessage,
      action: (context, provider) => provider.signIn(context),
      timeoutMessage: translations.error.timeout.authentication,
      needConfirmation: provider is ConfirmationProvider,
    );
  }

  /// Prompts the user to choose an authentication provider, and use it to link or unlink its current account.
  static Future<void> tryToggleLink(BuildContext context, WidgetRef ref) async {
    LinkProvider? provider = await AuthenticationProviderPickerDialog.openDialog(context, dialogMode: DialogMode.link) as LinkProvider?;
    if (provider == null || !context.mounted) {
      return;
    }
    bool unlink = ref.read(userAuthenticationProviders).contains(provider);
    if (unlink &&
        !(await ConfirmationDialog.ask(
          context,
          title: translations.authentication.unlinkConfirmationDialog.title,
          message: translations.authentication.unlinkConfirmationDialog.message,
        ))) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    await _tryTo<LinkProvider>(
      context,
      ref,
      provider,
      waitingDialogMessage: unlink ? null : translations.authentication.logIn.waitingLoginMessage,
      action: unlink ? ((context, provider) => provider.unlink(context)) : ((context, provider) => provider.link(context)),
      timeoutMessage: unlink ? translations.error.timeout.unlink : translations.error.timeout.authentication,
    );
  }

  /// Prompts the user to choose an authentication provider, use it to re-authenticate and delete its account.
  static Future<void> tryDeleteAccount(BuildContext context, WidgetRef ref) async {
    FirebaseAuthenticationProvider? provider = await AuthenticationProviderPickerDialog.openDialog(context, dialogMode: DialogMode.reAuthenticate);
    if (provider == null || !context.mounted) {
      return;
    }
    Result<String> result = await _tryTo(
      context,
      ref,
      provider,
      waitingDialogMessage: translations.authentication.logIn.waitingLoginMessage,
      action: (context, provider) => provider.reAuthenticate(context),
      timeoutMessage: translations.error.timeout.authentication,
      needConfirmation: provider is ConfirmationProvider,
    );
    if (result is! ResultSuccess<String>) {
      return;
    }
    Result deleteResult = await ref.read(firebaseAuthenticationProvider.notifier).deleteUser();
    if (context.mounted) {
      context.showSnackBarForResult(deleteResult, retryIfError: true);
    }
  }

  /// Tries to do the specified [action].
  static Future<Result<String>> _tryTo<T extends FirebaseAuthenticationProvider>(
    BuildContext context,
    WidgetRef ref,
    T provider, {
    required Future<Result<String>> Function(BuildContext, T) action,
    String? waitingDialogMessage,
    String? timeoutMessage,
    bool needConfirmation = false,
  }) async {
    Result<String> result;
    if (provider.showLoadingDialog) {
      result = await showWaitingOverlay(
        context,
        future: action(context, provider),
        message: waitingDialogMessage,
        timeout: provider is FallbackAuthenticationProvider && provider.shouldFallback ? provider.fallbackTimeout : null,
        timeoutMessage: timeoutMessage,
      );
    } else {
      result = await action(context, provider);
    }
    if (context.mounted) {
      handleAuthenticationResult(
        context,
        ref,
        provider,
        result,
        needConfirmation: needConfirmation,
        handleDifferentCredentialError: true,
      );
    }
    return result;
  }

  /// Handles the [result].
  static Future<void> handleAuthenticationResult(
    BuildContext context,
    WidgetRef ref,
    FirebaseAuthenticationProvider provider,
    Result<String> result, {
    bool needConfirmation = false,
    bool handleDifferentCredentialError = false,
  }) async {
    switch (result) {
      case ResultSuccess():
        context.showSnackBarForResult(
          result,
          retryIfError: true,
          successMessage: needConfirmation ? translations.authentication.logIn.successNeedConfirmation : null,
        );
        break;
      case ResultCancelled(:final timedOut):
        if (timedOut) {
          showAdaptiveDialog(
            context: context,
            builder: (context) => AlertDialog.adaptive(
              scrollable: true,
              content: Text(translations.error.timeout.authentication),
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
      case ResultError(:final exception):
        if (exception is! FirebaseAuthenticationException) {
          if (exception == null) {
            context.showSnackBarForResult(result, retryIfError: true);
          } else {
            SnackBarIcon.showErrorSnackBar(context, text: translations.error.authentication.firebaseException(exception: exception));
          }
          break;
        }
        switch (exception) {
          case FirebaseAuthenticationErrorAccountExistsWithDifferentCredential():
            if (handleDifferentCredentialError) {
              showAdaptiveDialog(
                context: context,
                builder: (context) => AlertDialog.adaptive(
                  title: Text(translations.error.authentication.accountExistsWithDifferentCredentialsDialog.title),
                  scrollable: true,
                  content: Text(translations.error.authentication.accountExistsWithDifferentCredentialsDialog.message),
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
              SnackBarIcon.showErrorSnackBar(context, text: translations.error.authentication.accountExistsWithDifferentCredentialsDialog.message);
            }
            break;
          case FirebaseAuthenticationErrorInvalidCredential():
            SnackBarIcon.showErrorSnackBar(context, text: translations.error.authentication.invalidCredential);
            break;
          case FirebaseAuthenticationErrorOperationNotAllowed():
            SnackBarIcon.showErrorSnackBar(context, text: translations.error.authentication.operationNotAllowed);
            break;
          case FirebaseAuthenticationErrorUserDisabled():
            SnackBarIcon.showErrorSnackBar(context, text: translations.error.authentication.userDisabled);
            break;
          case FirebaseAuthenticationFirebaseError(:final exception):
            SnackBarIcon.showErrorSnackBar(context, text: translations.error.authentication.firebaseException(exception: exception));
            break;
          case FirebaseAuthenticationGenericError(:final exception):
            if (exception == null) {
              SnackBarIcon.showErrorSnackBar(context, text: translations.error.generic.tryAgain);
            } else {
              SnackBarIcon.showErrorSnackBar(context, text: translations.error.authentication.firebaseException(exception: exception));
            }
            break;
        }
        break;
    }
  }
}
