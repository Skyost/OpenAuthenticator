import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/utils/form_label.dart';
import 'package:open_authenticator/widgets/form/master_password_form.dart';
import 'package:open_authenticator/widgets/form/password_form_field.dart';

/// Allows to change the user master password.
class ChangeMasterPasswordSettingsEntryWidget extends ConsumerWidget {
  /// Creates a new change master password settings entry widget instance.
  const ChangeMasterPasswordSettingsEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
        leading: const Icon(Icons.password),
        title: Text(translations.settings.security.changeMasterPassword.title),
        subtitle: Text.rich(
          translations.settings.security.changeMasterPassword.subtitle(
            italic: (text) => TextSpan(
              text: text,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ),
        onTap: () {
          showAdaptiveDialog(
            context: context,
            builder: (context) => _ChangeMasterPasswordDialog(),
          );
        },
      );
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
              await ref.read(totpRepositoryProvider.notifier).changeMasterPassword(newPassword);
              if (context.mounted) {
                Navigator.pop(context);
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
      return translations.settings.security.changeMasterPassword.dialog.errorIncorrectPassword;
    }
    return null;
  }
}
