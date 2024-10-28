import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/backup.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/dialog/confirmation_dialog.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';
import 'package:open_authenticator/widgets/list/expand_list_tile.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';
import 'package:share_plus/share_plus.dart';

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
        showDialog(
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
  /// The list global key.
  late GlobalKey listKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    DateFormat formatter = DateFormat(_RestoreBackupDialog.kDateFormat);
    AsyncValue<List<Backup>> backups = ref.watch(backupStoreProvider);
    Widget content;
    switch (backups) {
      case AsyncData(:final value):
        content = SizedBox(
          width: MediaQuery.of(context).size.width,
          child: ListView(
            key: listKey,
            shrinkWrap: true,
            children: [
              for (Backup backup in value)
                ExpandListTile(
                  title: Text(
                    formatter.format(backup.dateTime),
                  ),
                  children: createBackupActions(backup),
                ),
            ],
          ),
        );
        break;
      case AsyncError(:final error):
        content = Center(
          child: Text(translations.error.generic.withException(exception: error)),
        );
        break;
      default:
        content = const CenteredCircularProgressIndicator();
        break;
    }
    return AlertDialog(
      title: Text(translations.settings.backups.manageBackups.backupsDialogTitle),
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

  /// Creates the buttons to interact with a given [backup].
  List<Widget> createBackupActions(Backup backup) => [
        ListTile(
          dense: true,
          onTap: () => restoreBackup(backup),
          title: Text(translations.settings.backups.manageBackups.button.restore),
          leading: const Icon(Icons.upload),
        ),
        ListTile(
          dense: true,
          onTap: () => exportBackup(backup),
          title: Text(translations.settings.backups.manageBackups.button.export),
          leading: const Icon(Icons.share),
        ),
        ListTile(
          dense: true,
          onTap: () => deleteBackup(backup),
          title: Text(translations.settings.backups.manageBackups.button.delete),
          leading: const Icon(Icons.delete),
        ),
      ];

  /// Asks the user for the given [backup] restoring.
  Future<void> restoreBackup(Backup backup) async {
    String? password = await TextInputDialog.prompt(
      context,
      title: translations.settings.backups.manageBackups.restoreBackupPasswordDialog.title,
      message: translations.settings.backups.manageBackups.restoreBackupPasswordDialog.message,
      password: true,
    );
    if (password == null || !mounted) {
      return;
    }
    Result result = await showWaitingOverlay(
      context,
      future: backup.restore(password),
    );
    if (mounted) {
      context.showSnackBarForResult(result);
      Navigator.pop(context);
    }
  }

  /// Asks the user for the given [backup] export.
  Future<void> exportBackup(Backup backup) async {
    RenderBox? box = listKey.currentContext?.findRenderObject() as RenderBox?;
    File file = await backup.getBackupPath();
    await Share.shareXFiles(
      [
        XFile(
          file.path,
          mimeType: 'application/json',
        ),
      ],
      subject: translations.settings.backups.manageBackups.exportBackupDialog.subject,
      text: translations.settings.backups.manageBackups.exportBackupDialog.text,
      sharePositionOrigin: box == null ? Rect.zero : (box.localToGlobal(Offset.zero) & box.size),
    );
  }

  /// Asks the user for the given [backup] deletion.
  Future<void> deleteBackup(Backup backup) async {
    bool result = await ConfirmationDialog.ask(
      context,
      title: translations.settings.backups.manageBackups.deleteBackupConfirmationDialog.title,
      message: translations.settings.backups.manageBackups.deleteBackupConfirmationDialog.message,
    );
    if (!result) {
      return;
    }
    Result deleteResult = await backup.delete();
    if (mounted) {
      context.showSnackBarForResult(deleteResult);
      if (deleteResult is ResultSuccess) {
        await closeIfNoRemainingBackup();
      }
    }
  }

  /// Closes this dialog if there is no remaining backup.
  Future<void> closeIfNoRemainingBackup() async {
    List<Backup> backups = await ref.read(backupStoreProvider.future);
    if (backups.isEmpty && mounted) {
      Navigator.pop(context);
    }
  }
}
