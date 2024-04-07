import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/backup.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/dialog/confirmation_dialog.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';
import 'package:open_authenticator/widgets/dialog/waiting_dialog.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';

/// Allows the user to restore a backup.
class ManageBackupSettingsEntryWidget extends ConsumerWidget {
  /// Creates a new manage backup settings entry widget instance.
  const ManageBackupSettingsEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<Backup>> backups = ref.watch(backupStoreProvider);
    int backupCount = backups.valueOrNull?.length ?? 0;
    return ListTile(
      leading: const Icon(Icons.access_time),
      title: Text(translations.settings.backups.manageBackups.title),
      subtitle: Text(translations.settings.backups.manageBackups.subtitle(n: backupCount)),
      enabled: backups.hasValue && backupCount > 0,
      onTap: () {
        showAdaptiveDialog(
          context: context,
          builder: (context) => _RestoreBackupDialog(),
        );
      },
    );
  }
}

/// The dialog that allows to restore a backup.
class _RestoreBackupDialog extends ConsumerStatefulWidget {
  /// The date format to use inside the dialog.
  static const String kDateFormat = 'yyyy-MM-dd HH:mm:ss';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RestoreBackupDialogState();
}

/// The restore backup dialog state.
class _RestoreBackupDialogState extends ConsumerState<_RestoreBackupDialog> {
  @override
  Widget build(BuildContext context) {
    DateFormat formatter = DateFormat(_RestoreBackupDialog.kDateFormat);
    AsyncValue<List<Backup>> backups = ref.watch(backupStoreProvider);
    Widget content;
    switch (backups) {
      case AsyncData(:final value):
        content = ListView(
          shrinkWrap: true,
          children: [
            for (Backup backup in value)
              ListTile(
                title: Text(formatter.format(backup.dateTime)),
                onLongPress: currentPlatform.isDesktop ? null : () => deleteBackup(backup),
                trailing: currentPlatform.isDesktop
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          createRestoreButton(backup),
                          IconButton(
                            onPressed: () => deleteBackup(backup),
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      )
                    : createRestoreButton(backup),
              ),
          ],
        );
        break;
      case AsyncError():
        content = Center(
          child: Text(translations.settings.backups.manageBackups.backupsDialog.errorLoadingBackups),
        );
        break;
      default:
        content = const CenteredCircularProgressIndicator();
        break;
    }
    return AlertDialog.adaptive(
      title: Text(translations.settings.backups.manageBackups.backupsDialog.title),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: content,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
    );
  }

  /// Creates the button that allows to restore the given [backup].
  Widget createRestoreButton(Backup backup) => IconButton(
        onPressed: () async {
          String? password = await TextInputDialog.prompt(
            context,
            title: translations.settings.backups.manageBackups.restoreBackup.passwordDialog.title,
            message: translations.settings.backups.manageBackups.restoreBackup.passwordDialog.message,
            password: true,
          );
          if (password == null || !mounted) {
            return;
          }
          bool result = await showWaitingOverlay(
            context,
            future: backup.restore(password),
          );
          if (!mounted) {
            return;
          }
          if (result) {
            SnackBarIcon.showSuccessSnackBar(context, text: translations.settings.backups.manageBackups.restoreBackup.success);
          } else {
            SnackBarIcon.showErrorSnackBar(context, text: translations.settings.backups.manageBackups.restoreBackup.error);
          }
          Navigator.pop(context);
        },
        icon: const Icon(Icons.upload),
      );

  /// Asks the user for the given [backup] deletion.
  void deleteBackup(Backup backup) async {
    bool result = await ConfirmationDialog.ask(
      context,
      title: translations.settings.backups.manageBackups.deleteBackup.confirmationDialog.title,
      message: translations.settings.backups.manageBackups.deleteBackup.confirmationDialog.message,
    );
    if (!result) {
      return;
    }
    result = await backup.delete();
    if (!context.mounted) {
      return;
    }
    if (result) {
      SnackBarIcon.showSuccessSnackBar(context, text: translations.settings.backups.manageBackups.deleteBackup.success);
    } else {
      SnackBarIcon.showErrorSnackBar(context, text: translations.settings.backups.manageBackups.deleteBackup.error);
    }
  }
}
