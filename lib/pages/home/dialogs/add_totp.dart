import 'package:flutter/material.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/widgets/dialog/app_dialog.dart';

/// A dialog that allows to choose a method to add a TOTP.
class AddTotpDialog extends StatelessWidget {
  /// Whether this dialog is supported on the current platform.
  static final bool isSupported = currentPlatform.isMobile;

  /// Creates a new add totp dialog instance.
  const AddTotpDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) => AppDialog(
    title: Text(translations.home.addDialog.title),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
      ),
    ],
    children: [
      ListTile(
        leading: const Icon(Icons.qr_code),
        onTap: () => Navigator.pop(context, AddTotpDialogResult.qrCode),
        title: Text(translations.home.addDialog.qrCode.title),
        subtitle: Text(translations.home.addDialog.qrCode.subtitle),
      ),
      ListTile(
        leading: const Icon(Icons.short_text),
        onTap: () => Navigator.pop(context, AddTotpDialogResult.manually),
        title: Text(translations.home.addDialog.manually.title),
        subtitle: Text(translations.home.addDialog.manually.subtitle),
      ),
    ],
  );

  /// Displays the [AddTotpDialog].
  static Future<AddTotpDialogResult?> show(BuildContext context) async => await showDialog<AddTotpDialogResult>(
    context: context,
    builder: (context) => const AddTotpDialog(),
  );
}

/// The [AddTotpDialog] result.
enum AddTotpDialogResult {
  /// When the user wants to use a QR code to add a TOTP.
  qrCode,

  /// When the user wants to manually add the TOTP.
  manually,
}
