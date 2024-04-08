import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/pages/settings/page.dart';
import 'package:open_authenticator/utils/account.dart';
import 'package:open_authenticator/utils/storage_migration.dart';
import 'package:open_authenticator/widgets/dialog/confirmation_dialog.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';
import 'package:open_authenticator/widgets/dialog/waiting_dialog.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';

/// Allows the user to login or logout from the app.
class AccountLoginSettingsEntryWidget extends ConsumerWidget with RequiresAuthenticationProvider {
  /// Creates a new account login settings entry widget instance.
  const AccountLoginSettingsEntryWidget({
    super.key,
  });

  @override
  Widget buildWidgetWithAuthenticationProviders(BuildContext context, WidgetRef ref) {
    FirebaseAuthenticationState? state = ref.watch(firebaseAuthenticationProvider).valueOrNull;
    switch (state) {
      case FirebaseAuthenticationStateLoggedOut():
      case null:
        return _LogInListTile(enabled: state != null);
      case FirebaseAuthenticationStateWaitingForConfirmation(:final email):
        return _ConfirmEmailListTile(email: email);
      case FirebaseAuthenticationStateLoggedIn(:final user):
        return _LogoutListTile(email: user.email!);
    }
  }
}

/// The login list tile.
class _LogInListTile extends ConsumerWidget {
  /// Whether the tile is enabled.
  final bool enabled;

  /// Creates a new log in list tile instance.
  const _LogInListTile({
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
        leading: const Icon(Icons.login),
        title: Text(translations.settings.synchronization.accountLogin.logIn.title),
        subtitle: Text(translations.settings.synchronization.accountLogin.logIn.subtitle),
        onTap: () => AccountUtils.trySignIn(context, ref),
      );
}

/// The confirm email list tile.
class _ConfirmEmailListTile extends ConsumerWidget {
  /// The user email.
  final String email;

  /// Creates a new logout list tile instance.
  const _ConfirmEmailListTile({
    required this.email,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
        leading: const Icon(Icons.email),
        title: Text(translations.settings.synchronization.accountLogin.confirmEmail.title),
        subtitle: Text.rich(
          translations.settings.synchronization.accountLogin.confirmEmail.subtitle(
            email: TextSpan(
              text: email,
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

  Future<void> _tryCancelConfirmation(BuildContext context, WidgetRef ref) async {
    bool confirmation = await ConfirmationDialog.ask(
      context,
      title: translations.settings.synchronization.accountLogin.confirmEmail.confirmActionPickerDialog.cancelConfirmation.validationDialog.title,
      message: translations.settings.synchronization.accountLogin.confirmEmail.confirmActionPickerDialog.cancelConfirmation.validationDialog.message,
    );
    if (!confirmation || !context.mounted) {
      return;
    }
    bool result = await showWaitingOverlay(
      context,
      future: ref.read(firebaseAuthenticationProvider.notifier).tryCancelConfirmation(),
      message: translations.settings.synchronization.accountLogin.confirmEmail.waitingDialogMessage,
    );
    if (!context.mounted) {
      return;
    }
    if (result) {
      SnackBarIcon.showSuccessSnackBar(context, text: translations.settings.synchronization.accountLogin.confirmEmail.confirmActionPickerDialog.cancelConfirmation.success);
      return;
    }
    SnackBarIcon.showErrorSnackBar(context, text: translations.settings.synchronization.accountLogin.confirmEmail.confirmActionPickerDialog.cancelConfirmation.error);
  }

  /// Tries to confirm the user. He has to enter the link manually.
  Future<void> _tryConfirm(BuildContext context, WidgetRef ref) async {
    String? emailLink = await TextInputDialog.prompt(
      context,
      title: translations.settings.synchronization.accountLogin.confirmEmail.linkDialog.title,
      message: translations.settings.synchronization.accountLogin.confirmEmail.linkDialog.message,
      keyboardType: TextInputType.url,
    );
    if (emailLink == null || !context.mounted) {
      return;
    }
    bool result = await showWaitingOverlay(
      context,
      future: ref.read(firebaseAuthenticationProvider.notifier).tryConfirm(emailLink),
      message: translations.settings.synchronization.accountLogin.confirmEmail.waitingDialogMessage,
    );
    if (!result) {
      if (context.mounted) {
        SnackBarIcon.showErrorSnackBar(context, text: translations.settings.synchronization.accountLogin.confirmEmail.error);
      }
      return;
    }
    FirebaseAuthenticationState authenticationState = await ref.read(firebaseAuthenticationProvider.future);
    if (!context.mounted) {
      return;
    }
    switch (authenticationState) {
      case FirebaseAuthenticationStateLoggedOut():
      case FirebaseAuthenticationStateWaitingForConfirmation():
        SnackBarIcon.showErrorSnackBar(context, text: translations.settings.synchronization.accountLogin.confirmEmail.error);
        break;
      case FirebaseAuthenticationStateLoggedIn():
        SnackBarIcon.showSuccessSnackBar(context, text: translations.settings.synchronization.accountLogin.confirmEmail.success);
        break;
      default:
        break;
    }
  }
}

/// Picks for a confirmation action.
class _ConfirmActionPickerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AlertDialog.adaptive(
        title: Text(translations.settings.synchronization.accountLogin.confirmEmail.confirmActionPickerDialog.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check),
              title: Text(translations.settings.synchronization.accountLogin.confirmEmail.confirmActionPickerDialog.confirm.title),
              subtitle: Text(translations.settings.synchronization.accountLogin.confirmEmail.confirmActionPickerDialog.confirm.subtitle),
              onTap: () => Navigator.pop(context, _ConfirmAction.tryConfirm),
            ),
            ListTile(
              leading: const Icon(Icons.clear),
              title: Text(translations.settings.synchronization.accountLogin.confirmEmail.confirmActionPickerDialog.cancelConfirmation.title),
              subtitle: Text(translations.settings.synchronization.accountLogin.confirmEmail.confirmActionPickerDialog.cancelConfirmation.subtitle),
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

/// The logout list tile.
class _LogoutListTile extends ConsumerWidget {
  /// The user email.
  final String email;

  /// Creates a new logout list tile instance.
  const _LogoutListTile({
    required this.email,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
        leading: const Icon(Icons.logout),
        title: Text(translations.settings.synchronization.accountLogin.logOut.title),
        subtitle: Text.rich(
          translations.settings.synchronization.accountLogin.logOut.subtitle(
            email: TextSpan(
              text: email,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ),
        onTap: () => StorageMigrationUtils.changeStorageType(context, ref, StorageType.local, logout: true),
      );
}
