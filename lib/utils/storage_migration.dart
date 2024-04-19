import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/storage/storage.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';
import 'package:open_authenticator/widgets/dialog/waiting_dialog.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';

/// Contains some useful methods for migrating storage type.
class StorageMigrationUtils {
  /// Changes the storage type.
  /// Gives some feedback to the user thanks to the [context].
  static Future<bool> changeStorageType(
    BuildContext context,
    WidgetRef ref,
    StorageType newType, {
    bool logout = false,
    String? currentStorageMasterPassword,
    String? newStorageMasterPassword,
    StorageMigrationDeletedTotpPolicy storageMigrationDeletedTotpPolicy = StorageMigrationDeletedTotpPolicy.ask,
  }) async {
    currentStorageMasterPassword ??= await TextInputDialog.prompt(
      context,
      title: translations.storageMigration.masterPasswordDialog.title,
      message: translations.storageMigration.masterPasswordDialog.message,
      password: true,
    );
    if (currentStorageMasterPassword == null || !context.mounted) {
      return false;
    }
    StorageMigrationResult result = await showWaitingOverlay(
      context,
      future: ref.read(storageProvider.notifier).changeStorageType(
            currentStorageMasterPassword,
            newType,
            newStorageMasterPassword: newStorageMasterPassword,
            storageMigrationDeletedTotpPolicy: storageMigrationDeletedTotpPolicy,
          ),
    );
    if (!context.mounted) {
      return false;
    }
    return await _handleResult(
      result,
      context,
      ref,
      newType,
      logout,
      currentStorageMasterPassword,
      newStorageMasterPassword,
      storageMigrationDeletedTotpPolicy,
    );
  }

  /// Handles the [result] by returning a message if there is an error.
  static Future<bool> _handleResult(
    StorageMigrationResult result,
    BuildContext context,
    WidgetRef ref,
    StorageType newType,
    bool logout,
    String? currentStorageMasterPassword,
    String? newStorageMasterPassword,
    StorageMigrationDeletedTotpPolicy storageMigrationDeletedTotpPolicy,
  ) async {
    switch (result) {
      case StorageMigrationResult.success:
        if (logout) {
          await showWaitingOverlay(
            context,
            future: ref.read(firebaseAuthenticationProvider.notifier).logout(),
          );
        }
        if (context.mounted) {
          SnackBarIcon.showSuccessSnackBar(context, text: translations.storageMigration.success);
        }
        return true;
      case StorageMigrationResult.askForDifferentDeletedTotpPolicy:
        StorageMigrationDeletedTotpPolicy? enteredStorageMigrationDeletedTotpPolicy = await _StorageMigrationDeletedTotpPolicyPickerDialog.openDialog(context);
        if (enteredStorageMigrationDeletedTotpPolicy == null || !context.mounted) {
          return false;
        }
        return await changeStorageType(
          context,
          ref,
          newType,
          logout: logout,
          currentStorageMasterPassword: currentStorageMasterPassword,
          newStorageMasterPassword: newStorageMasterPassword,
          storageMigrationDeletedTotpPolicy: enteredStorageMigrationDeletedTotpPolicy,
        );
      case StorageMigrationResult.newStoragePasswordMismatch:
        String? enteredNewStorageMasterPassword = await TextInputDialog.prompt(
          context,
          title: translations.storageMigration.newStoragePasswordMismatchDialog.title,
          message: newStorageMasterPassword == null
              ? translations.storageMigration.newStoragePasswordMismatchDialog.defaultMessage
              : translations.storageMigration.newStoragePasswordMismatchDialog.errorMessage,
          password: true,
          initialValue: newStorageMasterPassword,
        );
        if (enteredNewStorageMasterPassword == null || !context.mounted) {
          return false;
        }
        return await changeStorageType(
          context,
          ref,
          newType,
          logout: logout,
          currentStorageMasterPassword: currentStorageMasterPassword,
          newStorageMasterPassword: enteredNewStorageMasterPassword,
          storageMigrationDeletedTotpPolicy: storageMigrationDeletedTotpPolicy,
        );
      case StorageMigrationResult.saltError:
      case StorageMigrationResult.currentStoragePasswordMismatch:
      case StorageMigrationResult.encryptionKeyChangeFailed:
      case StorageMigrationResult.genericError:
      default:
        SnackBarIcon.showErrorSnackBar(context, text: translations.storageMigration.error[result.name] ?? 'An error occurred.');
        return false;
    }
  }
}

/// Allows the user to choose its [StorageMigrationDeletedTotpPolicy].
class _StorageMigrationDeletedTotpPolicyPickerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AlertDialog.adaptive(
        title: Text(translations.storageMigration.deletedTotpPolicyPickerDialog.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(translations.storageMigration.deletedTotpPolicyPickerDialog.message),
            ListTile(
              leading: const Icon(Icons.delete),
              title: Text(translations.storageMigration.deletedTotpPolicyPickerDialog.delete.title),
              subtitle: Text(translations.storageMigration.deletedTotpPolicyPickerDialog.delete.subtitle),
              onTap: () => Navigator.pop(context, StorageMigrationDeletedTotpPolicy.delete),
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: Text(translations.storageMigration.deletedTotpPolicyPickerDialog.restore.title),
              subtitle: Text(translations.storageMigration.deletedTotpPolicyPickerDialog.restore.subtitle),
              onTap: () => Navigator.pop(context, StorageMigrationDeletedTotpPolicy.keep),
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
  static Future<StorageMigrationDeletedTotpPolicy?> openDialog(BuildContext context) => showAdaptiveDialog<StorageMigrationDeletedTotpPolicy>(
        context: context,
        builder: (context) => _StorageMigrationDeletedTotpPolicyPickerDialog(),
      );
}
