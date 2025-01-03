import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/app_unlock/method.dart';
import 'package:open_authenticator/model/settings/app_unlock_method.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/utils/form_label.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/form/master_password_form.dart';
import 'package:open_authenticator/widgets/form/password_form_field.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';

/// Contains various useful methods about the master password.
class MasterPasswordUtils {
  /// Prompts the user to change his master password.
  static Future<Result> changeMasterPassword(
    BuildContext context,
    WidgetRef ref, {
    String? password,
  }) async {
    AppUnlockMethodSettingsEntry appUnlockerMethodsSettingsEntry = ref.read(appUnlockMethodSettingsEntryProvider.notifier);
    Result unlockResult = await appUnlockerMethodsSettingsEntry.unlockWithCurrentMethod(context, UnlockReason.sensibleAction);
    if (unlockResult is! ResultSuccess) {
      return unlockResult;
    }
    if (!context.mounted) {
      return const ResultCancelled();
    }
    _ChangeMasterPasswordDialogResult? result = await showDialog<_ChangeMasterPasswordDialogResult>(
      context: context,
      builder: (context) => _ChangeMasterPasswordDialog(
        defaultPassword: password,
      ),
    );
    if (result == null || result.newPassword == null || !context.mounted) {
      return const ResultCancelled();
    }
    Result changeResult = await showWaitingOverlay(
      context,
      future: ref.read(totpRepositoryProvider.notifier).changeMasterPassword(result.newPassword!, backupPassword: result.backupPassword),
    );
    if (context.mounted) {
      context.showSnackBarForResult(changeResult);
    }
    return changeResult;
  }
}

/// The dialog that allows to change the master password.
class _ChangeMasterPasswordDialog extends ConsumerStatefulWidget {
  /// The default password.
  final String? defaultPassword;

  /// Creates a new change master password dialog instance.
  const _ChangeMasterPasswordDialog({
    this.defaultPassword,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChangeMasterPasswordDialogState();
}

/// The change master password dialog state.
class _ChangeMasterPasswordDialogState extends ConsumerState<_ChangeMasterPasswordDialog> {
  /// The new password form key.
  final GlobalKey<FormState> newPasswordFormKey = GlobalKey<FormState>();

  /// The new password value.
  late String newPassword = widget.defaultPassword ?? '';

  /// Whether the user wants to create a backup.
  bool createBackup = !kDebugMode;

  /// The backup password form key.
  final GlobalKey<FormState> backupPasswordFormKey = GlobalKey<FormState>();

  /// The backup password.
  String? backupPassword;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(translations.masterPassword.changeDialog.title),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MasterPasswordForm(
              formKey: newPasswordFormKey,
              defaultPassword: widget.defaultPassword,
              inputText: translations.masterPassword.changeDialog.newLabel,
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
              if (!newPasswordFormKey.currentState!.validate() || (createBackup && !backupPasswordFormKey.currentState!.validate())) {
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
