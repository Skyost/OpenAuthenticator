import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/app_unlock/method.dart';
import 'package:open_authenticator/model/app_unlock/state.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/backup.dart';
import 'package:open_authenticator/model/settings/entry.dart';
import 'package:open_authenticator/model/storage/local.dart';
import 'package:open_authenticator/model/totp/image_cache.dart';
import 'package:open_authenticator/pages/settings/page.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/dialog/confirmation_dialog.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';
import 'package:rate_my_app/rate_my_app.dart';
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

          AppUnlockState unlockState = ref.read(appUnlockStateProvider.notifier);
          Result unlockResult = await unlockState.tryUnlockWithCurrentMethod(context, UnlockReason.sensibleAction);
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
              SharedPreferences preferences = await ref.read(sharedPreferencesProvider.future);
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
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(translations.settings.dangerZone.clearData.doneDialog.title),
              content: Text(translations.settings.dangerZone.clearData.doneDialog.message),
              scrollable: true,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(MaterialLocalizations.of(context).continueButtonLabel),
                ),
              ],
            ),
          );
          if (currentPlatform.isMobile) {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop', true);
          } else {
            exit(0);
          }
        },
      );
}
