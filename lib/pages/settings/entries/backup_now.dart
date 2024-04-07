import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/backup.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';
import 'package:open_authenticator/widgets/dialog/waiting_dialog.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';

/// Allows the user to backup everything now.
class BackupNowSettingsEntryWidget extends ConsumerWidget {
  /// Creates a new backup now settings entry widget instance.
  const BackupNowSettingsEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    BackupStore backupStore = ref.watch(backupStoreProvider.notifier);
    return ListTile(
      leading: const Icon(Icons.save),
      title: Text(translations.settings.backups.backupNow.title),
      subtitle: Text(translations.settings.backups.backupNow.subtitle),
      onTap: () async {
        String? password = await TextInputDialog.prompt(
          context,
          title: translations.settings.backups.backupNow.passwordDialog.title,
          message: translations.settings.backups.backupNow.passwordDialog.message,
          password: true,
        );
        if (password == null || !context.mounted) {
          return;
        }
        Backup? result = await showWaitingDialog(
          context,
          future: backupStore.doBackup(password),
        );
        if (!context.mounted) {
          return;
        }
        if (result == null) {
          SnackBarIcon.showErrorSnackBar(context, text: translations.settings.backups.backupNow.error);
        } else {
          SnackBarIcon.showSuccessSnackBar(context, text: translations.settings.backups.backupNow.success);
        }
      },
    );
  }
}
