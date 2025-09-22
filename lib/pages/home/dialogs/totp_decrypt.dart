import 'package:flutter/material.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';
import 'package:open_authenticator/widgets/dialog/app_dialog.dart';
import 'package:open_authenticator/widgets/list/list_tile_padding.dart';

/// Allows the user to choose an action to execute when a TOTP decryption has been done with success.
class TotpDecryptDialog extends StatelessWidget {
  /// Contains all decrypted TOTPs.
  final List<DecryptedTotp> decryptedTotps;

  /// Creates a new TOTP key dialog instance.
  const TotpDecryptDialog({
    super.key,
    this.decryptedTotps = const [],
  });

  @override
  Widget build(BuildContext context) => AppDialog(
    title: Text(translations.totp.totpKeyDialog.title),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
      ),
    ],
    children: [
      ListTilePadding(
        bottom: 10,
        child: Text(
          translations.totp.totpKeyDialog.message(n: decryptedTotps.length),
        ),
      ),
      if (decryptedTotps.length > 1)
        ListTile(
          leading: const Icon(Icons.done_all),
          onTap: () => Navigator.pop(context, TotpDecryptDialogResult.changeAllTotpsKey),
          title: Text(translations.totp.totpKeyDialog.choices.changeAllDecryptedTotpsKey.title),
          subtitle: Text(translations.totp.totpKeyDialog.choices.changeAllDecryptedTotpsKey.subtitle),
        ),
      ListTile(
        leading: const Icon(Icons.key),
        onTap: () => Navigator.pop(context, TotpDecryptDialogResult.changeTotpKey),
        title: Text(translations.totp.totpKeyDialog.choices.changeTotpKey.title(n: decryptedTotps.length)),
        subtitle: Text(translations.totp.totpKeyDialog.choices.changeTotpKey.subtitle),
      ),
      ListTile(
        leading: const Icon(Icons.password),
        onTap: () => Navigator.pop(context, TotpDecryptDialogResult.changeMasterPassword),
        title: Text(translations.totp.totpKeyDialog.choices.changeMasterPassword.title),
        subtitle: Text(translations.totp.totpKeyDialog.choices.changeMasterPassword.subtitle),
      ),
      ListTile(
        leading: const Icon(Icons.close),
        onTap: () => Navigator.pop(context),
        title: Text(translations.totp.totpKeyDialog.choices.doNothing.title),
        subtitle: Text(translations.totp.totpKeyDialog.choices.doNothing.subtitle),
      ),
    ],
  );

  /// Displays the [TotpDecryptDialog].
  static Future<TotpDecryptDialogResult?> show(
    BuildContext context, {
    required List<DecryptedTotp> decryptedTotps,
  }) async => await showDialog<TotpDecryptDialogResult>(
    context: context,
    builder: (context) => TotpDecryptDialog(
      decryptedTotps: decryptedTotps,
    ),
  );
}

/// The [TotpDecryptDialog] result.
enum TotpDecryptDialogResult {
  /// Allows to change the TOTP key.
  changeTotpKey,

  /// Allows to change all TOTPs key (the current one and those that have been decrypted additionally).
  changeAllTotpsKey,

  /// Allows to change the current master password.
  changeMasterPassword,
}
