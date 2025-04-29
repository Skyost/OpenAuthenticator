import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/backup.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/dialog/app_dialog.dart';
import 'package:open_authenticator/widgets/dialog/confirmation_dialog.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';
import 'package:open_authenticator/widgets/list/expand_list_tile.dart';
import 'package:open_authenticator/widgets/list/list_tile_padding.dart';
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
      enabled: backups.hasValue,
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
  late GlobalKey shareActionKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    DateFormat formatter = DateFormat(_RestoreBackupDialog.kDateFormat);
    AsyncValue<List<Backup>> backups = ref.watch(backupStoreProvider);
    List<Widget> children;
    switch (backups) {
      case AsyncData(:final value):
        children = [
          if (value.isEmpty)
            ListTilePadding(
              key: shareActionKey,
              top: 20,
              bottom: 20,
              child: Text(
                translations.settings.backups.manageBackups.subtitle(n: 0),
                textAlign: TextAlign.center,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          for (Backup backup in value)
            ExpandListTile(
              title: Text(
                formatter.format(backup.dateTime),
              ),
              children: createBackupActions(backup),
            ),
        ];
        break;
      case AsyncError(:final error):
        children = [
          Center(
            child: Text(translations.error.generic.withException(exception: error)),
          ),
        ];
        break;
      default:
        children = [
          const CenteredCircularProgressIndicator(),
        ];
        break;
    }
    return AppDialog(
      title: Text(translations.settings.backups.manageBackups.backupsDialogTitle),
      actions: [
        TextButton(
          onPressed: importBackup,
          child: Text(translations.settings.backups.manageBackups.button.import),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
      children: children,
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
          onTap: () => shareBackup(backup),
          title: Text(translations.settings.backups.manageBackups.button.share),
          leading: const Icon(Icons.share),
        ),
        ListTile(
          dense: true,
          onTap: () => exportBackup(backup),
          title: Text(translations.settings.backups.manageBackups.button.export),
          leading: const Icon(Icons.import_export),
        ),
        ListTile(
          dense: true,
          onTap: () => deleteBackup(backup),
          title: Text(translations.settings.backups.manageBackups.button.delete),
          leading: const Icon(Icons.delete),
        ),
      ];

  /// Allows to import a backup.
  Future<void> importBackup() async {
    Result result = ResultCancelled();
    try {
      FilePickerResult? filePickerResult = await showWaitingOverlay(
        context,
        future: (() async {
          Directory directory = await BackupStore.getBackupsDirectory(create: true);
          return FilePicker.platform.pickFiles(
            dialogTitle: translations.settings.backups.manageBackups.importBackupDialogTitle,
            initialDirectory: directory.path,
            type: FileType.custom,
            allowedExtensions: ['bak'],
            lockParentWindow: true,
          );
        })(),
      );
      String? backupFilePath = filePickerResult?.files.firstOrNull?.path;
      if (backupFilePath == null || !mounted) {
        return;
      }
      result = await showWaitingOverlay(
        context,
        future: ref.read(backupStoreProvider.notifier).import(File(backupFilePath)),
      );
    } catch (ex, stacktrace) {
      result = ResultError(exception: ex, stacktrace: stacktrace);
    } finally {
      if (mounted) {
        context.showSnackBarForResult(result);
      }
    }
  }

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

  /// Asks the user for the given [backup] share.
  Future<ShareResult> shareBackup(Backup backup) async {
    RenderBox? box = shareActionKey.currentContext?.findRenderObject() as RenderBox?;
    File file = await backup.getBackupPath();
    return await SharePlus.instance.share(
      ShareParams(
        subject: translations.settings.backups.manageBackups.shareBackupDialog.subject,
        text: translations.settings.backups.manageBackups.shareBackupDialog.text,
        sharePositionOrigin: box == null ? Rect.zero : (box.localToGlobal(Offset.zero) & box.size),
        files: [
          XFile(
            file.path,
            mimeType: 'application/json',
          ),
        ],
      ),
    );
  }

  /// Asks the user for the given [backup] export.
  Future<void> exportBackup(Backup backup) async {
    Result result = ResultCancelled();
    try {
      String? outputFilePath = await showWaitingOverlay(
        context,
        future: (() async {
          Directory directory = await BackupStore.getBackupsDirectory(create: true);
          return FilePicker.platform.saveFile(
            dialogTitle: translations.settings.backups.manageBackups.exportBackupDialogTitle,
            initialDirectory: directory.path,
            fileName: backup.filename,
            bytes: Uint8List(0),
            type: FileType.custom,
            allowedExtensions: ['bak'],
            lockParentWindow: true,
          );
        })(),
      );
      if (outputFilePath == null) {
        return;
      }
      File backupFile = await backup.getBackupPath();
      backupFile.copySync(outputFilePath);
      result = ResultSuccess();
    } catch (ex, stacktrace) {
      result = ResultError(exception: ex, stacktrace: stacktrace);
    } finally {
      if (mounted) {
        context.showSnackBarForResult(result);
      }
    }
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
    }
  }
}
