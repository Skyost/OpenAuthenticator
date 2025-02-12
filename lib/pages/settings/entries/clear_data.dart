import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/app_unlock/method.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/backup.dart';
import 'package:open_authenticator/model/settings/app_unlock_method.dart';
import 'package:open_authenticator/model/settings/entry.dart';
import 'package:open_authenticator/model/storage/local.dart';
import 'package:open_authenticator/model/totp/image_cache.dart';
import 'package:open_authenticator/pages/settings/entries/widgets.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/utils/shared_preferences_with_prefix.dart';
import 'package:open_authenticator/widgets/dialog/app_dialog.dart';
import 'package:open_authenticator/widgets/dialog/confirmation_dialog.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';
import 'package:simple_secure_storage/simple_secure_storage.dart';

/// Allows to clear all the app data.
class ClearDataSettingsEntryWidget extends ConsumerWidget {
  /// Creates a new clear data settings entry widget instance.
  const ClearDataSettingsEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => DangerZoneListTile(
        icon: Icons.delete_forever,
        title: translations.settings.dangerZone.clearData.title,
        subtitle: translations.settings.dangerZone.clearData.subtitle,
        onTap: () async {
          bool confirm = await ConfirmationDialog.ask(
            context,
            title: translations.settings.dangerZone.clearData.confirmationDialog.title,
            message: translations.settings.dangerZone.clearData.confirmationDialog.message,
          );
          if (!confirm || !context.mounted) {
            return;
          }

          AppUnlockMethodSettingsEntry appUnlockerMethodsSettingsEntry = ref.read(appUnlockMethodSettingsEntryProvider.notifier);
          Result unlockResult = await appUnlockerMethodsSettingsEntry.unlockWithCurrentMethod(context, UnlockReason.sensibleAction);
          if (unlockResult is! ResultSuccess || !context.mounted) {
            return;
          }

          bool deleteBackups = await ConfirmationDialog.ask(
            context,
            title: translations.settings.dangerZone.clearData.backupDeleteConfirmationDialog.title,
            message: translations.settings.dangerZone.clearData.backupDeleteConfirmationDialog.message,
          );
          if (!deleteBackups || !context.mounted) {
            return;
          }

          await showWaitingOverlay(
            context,
            future: () async {
              Result logoutResult = await ref.read(firebaseAuthenticationProvider.notifier).logout();
              if (!context.mounted) {
                return;
              }
              if (logoutResult is! ResultSuccess) {
                context.showSnackBarForResult(logoutResult, retryIfError: true);
                return;
              }
              await FirebaseFirestore.instance.terminate();
              await FirebaseFirestore.instance.clearPersistence();
              await SimpleSecureStorage.clear();
              TotpImageCacheManager totpImageCacheManager = ref.read(totpImageCacheManagerProvider.notifier);
              await totpImageCacheManager.clearCache();
              SharedPreferencesWithPrefix preferences = await ref.read(sharedPreferencesProvider.future);
              await preferences.clear();
              LocalStorage localStorage = await ref.read(localStorageProvider);
              await localStorage.clearTotps();
              if (deleteBackups) {
                List<Backup> backups = await ref.read(backupStoreProvider.future);
                for (Backup backup in backups) {
                  await backup.delete();
                }
              }
            }(),
          );
          if (!context.mounted) {
            return;
          }
          await _showCloseDialog(context);
          if (_canExitWithConfirmDialog) {
            await _closeApp();
          }
        },
      );

  /// Shows the dialog that indicates the user he has to restart the app.
  Future<void> _showCloseDialog(BuildContext context) async {
    bool canExitWithConfirmDialog = _canExitWithConfirmDialog;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppDialog(
        title: Text(translations.settings.dangerZone.clearData.doneDialog.title),
        displayCloseButton: false,
        actions: canExitWithConfirmDialog
            ? [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(MaterialLocalizations.of(context).continueButtonLabel),
                ),
              ]
            : null,
        children: [
          Text(
            canExitWithConfirmDialog ? translations.settings.dangerZone.clearData.doneDialog.message.appWillClose : translations.settings.dangerZone.clearData.doneDialog.message.closeAppManually,
          ),
        ],
      ),
    );
  }

  /// Whether we can exit following the [_showCloseDialog] method.
  bool get _canExitWithConfirmDialog {
    switch (currentPlatform) {
      case Platform.android:
      case Platform.macOS:
      case Platform.linux:
      case Platform.windows:
        return true;
      default:
        return false;
    }
  }

  /// Closes the app programmatically.
  Future<void> _closeApp() async {
    switch (currentPlatform) {
      case Platform.android:
      case Platform.macOS:
      case Platform.linux:
        await SystemNavigator.pop(animated: true);
        break;
      default:
        debugger();
        exit(0);
    }
  }
}
