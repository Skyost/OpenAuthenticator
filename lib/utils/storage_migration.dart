import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/storage/storage.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/utils/form_label.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';
import 'package:open_authenticator/widgets/dialog/waiting_dialog.dart';
import 'package:open_authenticator/widgets/form/password_form_field.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';

/// Contains some useful methods for migrating storage type.
class StorageMigrationUtils {
  /// Changes the storage type.
  /// Gives some feedback to the user thanks to the [context].
  static Future<bool> changeStorageType(
    BuildContext context,
    WidgetRef ref,
    StorageType newType, {
    bool showConfirmation = true,
    String? backupPassword,
    bool logout = false,
    String currentStorageMasterPassword = '',
    String? newStorageMasterPassword,
    StorageMigrationDeletedTotpPolicy storageMigrationDeletedTotpPolicy = StorageMigrationDeletedTotpPolicy.ask,
  }) async {
    if (showConfirmation) {
      _ConfirmationResult? result = await _ConfirmationDialog.ask(context, newType == StorageType.online);
      if (result == null || !result.confirm || !context.mounted) {
        return false;
      }
      backupPassword ??= result.backupPassword;
    }
    StoredCryptoStore currentCryptoStore = ref.read(cryptoStoreProvider.notifier);
    if (!(await currentCryptoStore.checkPasswordValidity(currentStorageMasterPassword))) {
      if (!context.mounted) {
        return false;
      }
      String? enteredCurrentStorageMasterPassword = await MasterPasswordInputDialog.prompt(context);
      if (enteredCurrentStorageMasterPassword == null || !context.mounted) {
        return false;
      }
      currentStorageMasterPassword = enteredCurrentStorageMasterPassword;
    }
    if (!context.mounted) {
      return false;
    }
    Result result = await showWaitingOverlay(
      context,
      future: ref.read(storageProvider.notifier).changeStorageType(
            currentStorageMasterPassword,
            newType,
            backupPassword: backupPassword,
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
      backupPassword,
      currentStorageMasterPassword,
      newStorageMasterPassword,
      storageMigrationDeletedTotpPolicy,
    );
  }

  /// Handles the [result] by returning a message if there is an error.
  static Future<bool> _handleResult(
    Result result,
    BuildContext context,
    WidgetRef ref,
    StorageType newType,
    bool logout,
    String? backupPassword,
    String currentStorageMasterPassword,
    String? newStorageMasterPassword,
    StorageMigrationDeletedTotpPolicy storageMigrationDeletedTotpPolicy,
  ) async {
    switch (result) {
      case ResultSuccess():
        if (logout) {
          await showWaitingOverlay(
            context,
            future: ref.read(firebaseAuthenticationProvider.notifier).logout(),
          );
        }
        if (context.mounted) {
          SnackBarIcon.showSuccessSnackBar(context, text: translations.error.noError);
        }
        return true;
      case ResultError(:final exception):
        if (exception is! StorageMigrationException) {
          context.showSnackBarForResult(result, retryIfError: true);
          return false;
        }
        switch (exception) {
          case ShouldAskForDifferentDeletedTotpPolicyException():
            StorageMigrationDeletedTotpPolicy? enteredStorageMigrationDeletedTotpPolicy = await _StorageMigrationDeletedTotpPolicyPickerDialog.openDialog(context);
            if (enteredStorageMigrationDeletedTotpPolicy == null || !context.mounted) {
              break;
            }
            return await changeStorageType(
              context,
              ref,
              newType,
              showConfirmation: false,
              logout: logout,
              backupPassword: backupPassword,
              currentStorageMasterPassword: currentStorageMasterPassword,
              newStorageMasterPassword: newStorageMasterPassword,
              storageMigrationDeletedTotpPolicy: enteredStorageMigrationDeletedTotpPolicy,
            );
          case NewStoragePasswordMismatchException():
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
              showConfirmation: false,
              logout: logout,
              backupPassword: backupPassword,
              currentStorageMasterPassword: currentStorageMasterPassword,
              newStorageMasterPassword: enteredNewStorageMasterPassword,
              storageMigrationDeletedTotpPolicy: storageMigrationDeletedTotpPolicy,
            );
          case BackupException():
          case SaltError():
          case CurrentStoragePasswordMismatchException():
          case EncryptionKeyChangeFailedError():
          case GenericMigrationError():
          default:
            SnackBarIcon.showErrorSnackBar(context, text: translations.error.storageMigration[exception.code] ?? 'An error occurred.');
            return false;
        }
      default:
        break;
    }
    return false;
  }
}

/// The dialog that allows to confirm the operation.
class _ConfirmationDialog extends StatefulWidget {

  /// Whether the user wants to enable the data synchronization.
  final bool enable;


  /// Creates a new confirmation dialog instance.
  const _ConfirmationDialog({required this.enable,});

  @override
  State<StatefulWidget> createState() => _ConfirmationDialogState();

  /// Asks for the confirmation.
  static Future<_ConfirmationResult?> ask(BuildContext context, bool enable) => showAdaptiveDialog<_ConfirmationResult>(
        context: context,
        builder: (context) => _ConfirmationDialog(enable: enable,),
      );
}

/// The confirmation dialog state.
class _ConfirmationDialogState extends State<_ConfirmationDialog> {
  /// The backup password form key.
  final GlobalKey<FormState> backupPasswordFormKey = GlobalKey<FormState>();

  /// Whether the user wants to create a backup.
  bool createBackup = true;

  /// The backup password.
  String? backupPassword;

  @override
  Widget build(BuildContext context) => AlertDialog.adaptive(
        title: Text(translations.storageMigration.confirmDialog.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.enable ? translations.storageMigration.confirmDialog.message.enable : translations.storageMigration.confirmDialog.message.disable),
            ListTile(
              title: Text(translations.miscellaneous.backupCheckbox.checkbox),
              contentPadding: EdgeInsets.zero,
              trailing: Checkbox(
                value: createBackup,
                onChanged: (value) {
                  setState(() => createBackup = value ?? !createBackup);
                },
              ),
            ),
            if (createBackup)
              Form(
                key: backupPasswordFormKey,
                child: PasswordFormField(
                  initialValue: backupPassword,
                  onChanged: (value) => backupPassword = value,
                  validator: isBackupPasswordValid,
                  decoration: FormLabelWithIcon(
                    icon: Icons.save,
                    text: translations.miscellaneous.backupCheckbox.input.text,
                    hintText: translations.miscellaneous.backupCheckbox.input.hint,
                  ),
                ),
              ),
          ],
        ),
        scrollable: true,
        actions: [
          TextButton(
            onPressed: () {
              if (createBackup && !backupPasswordFormKey.currentState!.validate()) {
                return;
              }
              Navigator.pop(context, _ConfirmationResult(confirm: true, backupPassword: createBackup ? backupPassword : null));
            },
            child: Text(MaterialLocalizations.of(context).continueButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, const _ConfirmationResult()),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
        ],
      );

  /// Checks whether the backup password is valid.
  String? isBackupPasswordValid(String? value) {
    if (createBackup && (backupPassword == null || backupPassword!.isEmpty)) {
      return translations.error.validation.empty;
    }
    return null;
  }
}

/// Returned by the [_ConfirmationDialog].
class _ConfirmationResult {
  /// Whether the user wants to continue.
  final bool confirm;

  /// The backup password.
  final String? backupPassword;

  /// Creates a new confirmation result instance.
  const _ConfirmationResult({
    this.confirm = false,
    this.backupPassword,
  });
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
