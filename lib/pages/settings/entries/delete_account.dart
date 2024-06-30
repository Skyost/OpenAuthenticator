import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/pages/settings/page.dart';
import 'package:open_authenticator/utils/account.dart';
import 'package:open_authenticator/widgets/dialog/confirmation_dialog.dart';

/// Allows to delete the user account.
class DeleteAccountSettingsEntryWidget extends ConsumerWidget with RequiresAuthenticationProvider {
  /// Creates a new delete account settings entry widget instance.
  const DeleteAccountSettingsEntryWidget({
    super.key,
  });

  @override
  Widget buildWidgetWithAuthenticationProviders(BuildContext context, WidgetRef ref) => ListTile(
        leading: const Icon(
          Icons.person_off,
          color: Colors.red,
        ),
        title: Text(
          translations.settings.synchronization.deleteAccount.title,
          style: const TextStyle(color: Colors.red),
        ),
        subtitle: Text(
          translations.settings.synchronization.deleteAccount.subtitle,
          style: const TextStyle(color: Colors.red),
        ),
        onTap: () async {
          bool confirm = await ConfirmationDialog.ask(
            context,
            title: translations.authentication.deleteConfirmationDialog.title,
            message: translations.authentication.deleteConfirmationDialog.message,
          );
          if (!confirm || !context.mounted) {
            return;
          }
          await AccountUtils.tryDeleteAccount(context, ref);
        },
      );
}
