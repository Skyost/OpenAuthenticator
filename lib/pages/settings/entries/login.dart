import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/pages/settings/page.dart';
import 'package:open_authenticator/utils/account.dart';
import 'package:open_authenticator/utils/storage_migration.dart';
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
          String? emailLink = await TextInputDialog.prompt(
            context,
            title: translations.settings.synchronization.accountLogin.confirmEmail.linkDialog.title,
            message: translations.settings.synchronization.accountLogin.confirmEmail.linkDialog.message,
            keyboardType: TextInputType.url,
          );
          if (emailLink == null || !context.mounted) {
            return;
          }
          bool result = await showWaitingDialog(
            context,
            future: ref.read(firebaseAuthenticationProvider.notifier).tryConfirm(emailLink),
            message: translations.settings.synchronization.accountLogin.confirmEmail.waitingDialogMessage,
          );
          if (!result) {
            return;
          }
          FirebaseAuthenticationState authenticationState = await ref.read(firebaseAuthenticationProvider.future);
          if (!context.mounted) {
            return;
          }
          switch (authenticationState) {
            case FirebaseAuthenticationStateLoggedOut():
            case FirebaseAuthenticationStateWaitingForConfirmation():
              SnackBarIcon.showSuccessSnackBar(context, text: translations.settings.synchronization.accountLogin.confirmEmail.error);
              break;
            case FirebaseAuthenticationStateLoggedIn():
              SnackBarIcon.showSuccessSnackBar(context, text: translations.settings.synchronization.accountLogin.confirmEmail.success);
              break;
            default:
              break;
          }
        },
      );
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
