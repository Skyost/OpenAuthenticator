import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/providers/email_link.dart';
import 'package:open_authenticator/pages/settings/page.dart';
import 'package:open_authenticator/utils/account.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/dialog/confirmation_dialog.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';

/// Allows the user to confirm its email from the app.
class ConfirmEmailSettingsEntryWidget extends ConsumerWidget with RequiresAuthenticationProvider {
  /// Creates a new confirm email settings entry widget instance.
  const ConfirmEmailSettingsEntryWidget({
    super.key,
  });

  @override
  Widget buildWidgetWithAuthenticationProviders(BuildContext context, WidgetRef ref) {
    ref.watch(emailLinkAuthenticationProvider);
    return FutureBuilder(
      future: ref.read(emailLinkAuthenticationProvider.notifier).readEmailToConfirmFromPreferences(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const SizedBox.shrink();
        }
        return ListTile(
          leading: const Icon(Icons.email),
          title: Text(translations.settings.synchronization.confirmEmail.title),
          subtitle: Text.rich(
            translations.settings.synchronization.confirmEmail.subtitle(
              email: TextSpan(
                text: snapshot.data,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ),
          onTap: () async {
            _ConfirmAction? confirmAction = await _ConfirmActionPickerDialog.openDialog(context);
            if (confirmAction == null || !context.mounted) {
              return;
            }
            switch (confirmAction) {
              case _ConfirmAction.tryConfirm:
                _tryConfirm(context, ref);
                break;
              case _ConfirmAction.cancelConfirmation:
                _tryCancelConfirmation(context, ref);
                break;
            }
          },
        );
      },
    );
  }

  /// Tries to cancel the confirmation.
  Future<void> _tryCancelConfirmation(BuildContext context, WidgetRef ref) async {
    bool confirmation = await ConfirmationDialog.ask(
      context,
      title: translations.settings.synchronization.confirmEmail.confirmActionPickerDialog.cancelConfirmation.validationDialog.title,
      message: translations.settings.synchronization.confirmEmail.confirmActionPickerDialog.cancelConfirmation.validationDialog.message,
    );
    if (!confirmation || !context.mounted) {
      return;
    }
    Result result = await showWaitingOverlay(
      context,
      future: ref.read(emailLinkAuthenticationProvider.notifier).cancelConfirmation(),
      message: translations.settings.synchronization.confirmEmail.waitingDialogMessage,
    );
    if (context.mounted) {
      context.showSnackBarForResult(result, retryIfError: true);
    }
  }

  /// Tries to confirm the user. He has to enter the link manually.
  Future<void> _tryConfirm(BuildContext context, WidgetRef ref) async {
    String? emailLink = await TextInputDialog.prompt(
      context,
      title: translations.settings.synchronization.confirmEmail.linkDialog.title,
      message: translations.settings.synchronization.confirmEmail.linkDialog.message,
      keyboardType: TextInputType.url,
    );
    if (emailLink == null || !context.mounted) {
      return;
    }
    EmailLinkAuthenticationProvider emailAuthenticationProvider = ref.read(emailLinkAuthenticationProvider.notifier);
    Result<String> result = await showWaitingOverlay(
      context,
      future: emailAuthenticationProvider.confirm(emailLink),
      message: translations.settings.synchronization.confirmEmail.waitingDialogMessage,
    );
    if (!context.mounted) {
      return;
    }
    AccountUtils.handleAuthenticationResult(context, ref, emailAuthenticationProvider, result);
  }
}

/// Picks for a confirmation action.
class _ConfirmActionPickerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AlertDialog.adaptive(
        title: Text(translations.settings.synchronization.confirmEmail.confirmActionPickerDialog.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check),
              title: Text(translations.settings.synchronization.confirmEmail.confirmActionPickerDialog.confirm.title),
              subtitle: Text(translations.settings.synchronization.confirmEmail.confirmActionPickerDialog.confirm.subtitle),
              onTap: () => Navigator.pop(context, _ConfirmAction.tryConfirm),
            ),
            ListTile(
              leading: const Icon(Icons.clear),
              title: Text(translations.settings.synchronization.confirmEmail.confirmActionPickerDialog.cancelConfirmation.title),
              subtitle: Text(translations.settings.synchronization.confirmEmail.confirmActionPickerDialog.cancelConfirmation.subtitle),
              onTap: () => Navigator.pop(context, _ConfirmAction.cancelConfirmation),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
        ],
        scrollable: true,
      );

  /// Opens the dialog.
  static Future<_ConfirmAction?> openDialog(BuildContext context) => showAdaptiveDialog<_ConfirmAction>(
        context: context,
        builder: (context) => _ConfirmActionPickerDialog(),
      );
}

/// A [_ConfirmActionPickerDialog] result.
enum _ConfirmAction {
  /// Tries to confirm the account.
  tryConfirm,

  /// Cancels the confirmation.
  cancelConfirmation;
}
