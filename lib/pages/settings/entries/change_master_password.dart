import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/settings/storage_type.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/utils/form_label.dart';
import 'package:open_authenticator/widgets/dialog/waiting_dialog.dart';
import 'package:open_authenticator/widgets/form/master_password_form.dart';
import 'package:open_authenticator/widgets/form/password_form_field.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';

/// Allows to change the user master password.
class ChangeMasterPasswordSettingsEntryWidget extends ConsumerWidget {
  /// Creates a new change master password settings entry widget instance.
  const ChangeMasterPasswordSettingsEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<StorageType> storageType = ref.watch(storageTypeSettingsEntryProvider);
    return ListTile(
      leading: const Icon(Icons.password),
      title: Text(translations.settings.security.changeMasterPassword.title),
      subtitle: Text.rich(
        TextSpan(
          text: translations.settings.security.changeMasterPassword.subtitle.text,
          children: [
            if (storageType.valueOrNull == StorageType.online)
              TextSpan(text: '\n${translations.settings.security.changeMasterPassword.subtitle.sync}', style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
      ),
      onTap: () async {
        _ChangeMasterPasswordDialogResult? result = await showAdaptiveDialog<_ChangeMasterPasswordDialogResult>(
          context: context,
          builder: (context) => _ChangeMasterPasswordDialog(),
        );
        if (result == null || result.newPassword == null || !context.mounted) {
          return;
        }
        bool changeResult = await showWaitingOverlay(
          context,
          future: ref.read(totpRepositoryProvider.notifier).changeMasterPassword(result.newPassword!, backupPassword: result.backupPassword),
        );
        if (!context.mounted) {
          return;
        }
        if (changeResult) {
          SnackBarIcon.showSuccessSnackBar(context, text: translations.error.noError);
        } else {
          SnackBarIcon.showErrorSnackBar(context, text: translations.error.generic.noTryAgain);
        }
      },
    );
  }
}

/// The dialog that allows to change the master password.
class _ChangeMasterPasswordDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChangeMasterPasswordDialogState();
}

/// The change master password dialog state.
class _ChangeMasterPasswordDialogState extends ConsumerState<_ChangeMasterPasswordDialog> {
  /// The old password form key.
  final GlobalKey<FormState> oldPasswordFormKey = GlobalKey<FormState>();

  /// The old password value.
  String oldPassword = '';

  /// The new password form key.
  final GlobalKey<FormState> newPasswordFormKey = GlobalKey<FormState>();

  /// The new password value.
  String newPassword = '';

  /// Whether the user wants to create a backup.
  bool createBackup = true;

  /// The backup password form key.
  final GlobalKey<FormState> backupPasswordFormKey = GlobalKey<FormState>();

  /// The backup password.
  String? backupPassword;

  /// The old password validation result.
  bool oldPasswordValidationResult = false;

  @override
  Widget build(BuildContext context) => AlertDialog.adaptive(
        title: Text(translations.settings.security.changeMasterPassword.dialog.title),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: oldPasswordFormKey,
              child: PasswordFormField(
                decoration: FormLabelWithIcon(
                  icon: Icons.key,
                  text: translations.settings.security.changeMasterPassword.dialog.current.label,
                  hintText: translations.settings.security.changeMasterPassword.dialog.current.hint,
                ),
                onChanged: (value) => oldPassword = value,
                initialValue: oldPassword,
                validator: isPasswordValid,
              ),
            ),
            MasterPasswordForm(
              formKey: newPasswordFormKey,
              inputText: translations.settings.security.changeMasterPassword.dialog.newLabel,
              onChanged: (value) => newPassword = value ?? '',
            ),
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
        actions: [
          TextButton(
            onPressed: () async {
              StoredCryptoStore cryptoStore = ref.read(cryptoStoreProvider.notifier);
              oldPasswordValidationResult = await cryptoStore.checkPasswordValidity(oldPassword);
              if (!oldPasswordFormKey.currentState!.validate() || !newPasswordFormKey.currentState!.validate()) {
                return;
              }
              if (createBackup && !backupPasswordFormKey.currentState!.validate()) {
                return;
              }
              if (context.mounted) {
                Navigator.pop(context, _ChangeMasterPasswordDialogResult(newPassword: newPassword, backupPassword: createBackup ? backupPassword : null));
              }
            },
            child: Text(MaterialLocalizations.of(context).continueButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
        ],
      );

  /// Checks whether the entered password is valid.
  String? isPasswordValid(String? value) {
    if (!oldPasswordValidationResult) {
      return translations.error.validation.masterPassword;
    }
    return null;
  }

  /// Checks whether the backup password is valid.
  String? isBackupPasswordValid(String? value) {
    if (createBackup && (backupPassword == null || backupPassword!.isEmpty)) {
      return translations.error.validation.empty;
    }
    return null;
  }
}

/// Returned by the [_ChangeMasterPasswordDialog].
class _ChangeMasterPasswordDialogResult {
  /// The new password.
  final String? newPassword;

  /// The backup password.
  final String? backupPassword;

  /// Creates a new confirmation result instance.
  const _ChangeMasterPasswordDialogResult({
    this.newPassword,
    this.backupPassword,
  });
}
