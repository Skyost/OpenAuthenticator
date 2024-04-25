import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/main.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/pages/totp.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/dialog/confirmation_dialog.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';
import 'package:open_authenticator/widgets/totp/code.dart';
import 'package:open_authenticator/widgets/totp/image.dart';

/// Allows to display TOTPs in a [ListView].
class TotpWidget extends ConsumerWidget {
  /// The TOTP instance.
  final Totp totp;

  /// The TOTP image size.
  final double imageSize;

  /// The content padding.
  final EdgeInsets contentPadding;

  /// The space between the images and the textual elements.
  final double space;

  /// Whether to display the code.
  final bool displayCode;

  /// Creates a new TOTP widget instance.
  const TotpWidget({
    super.key,
    required this.totp,
    this.imageSize = 70,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    this.space = 10,
    this.displayCode = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget result = Padding(
      padding: contentPadding,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: space),
            child: totp.isDecrypted
                ? TotpCountdownImageWidget(
                    totp: totp,
                    size: imageSize,
                  )
                : TotpImageWidget.fromTotp(
                    totp: totp,
                    size: imageSize,
                  ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (totp.issuer != null && totp.issuer!.isNotEmpty)
                Text(
                  totp.issuer!,
                ),
              Text(
                totp.label ?? totp.uuid,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              if (totp.isDecrypted && displayCode)
                TotpCodeWidget(
                  totp: totp as DecryptedTotp,
                  textStyle: Theme.of(context).textTheme.headlineLarge,
                ),
              if (!currentPlatform.isMobile)
                SizedBox(
                  width: MediaQuery.of(context).size.width - contentPadding.left - contentPadding.right - imageSize - space,
                  child: _DesktopActionsWidget(
                    onCopyPressed: totp.isDecrypted ? (() async => await _copyCode(context)) : null,
                    onDecryptPressed: totp.isDecrypted ? null : () => _tryDecrypt(context, ref),
                    onEditPressed: () async => await _edit(context),
                    onDeletePressed: () async => await _delete(context, ref),
                  ),
                ),
            ],
          ),
          const Spacer(),
          if (currentPlatform.isMobile)
            if (totp.isDecrypted)
              IconButton(
                icon: Icon(
                  Icons.copy,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () async => await _copyCode(context),
              )
            else
              IconButton(
                icon: Icon(
                  Icons.lock,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () async => await _tryDecrypt(context, ref),
              ),
        ],
      ),
    );
    return (currentPlatform.isMobile || kDebugMode)
        ? InkWell(
            onLongPress: () => _showMobileActionsMenu(context, ref),
            child: result,
          )
        : result;
  }

  /// Allows to copy the code to the clipboard.
  Future<void> _copyCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: (totp as DecryptedTotp).generator.generate(DateTime.now())));
    if (context.mounted) {
      SnackBarIcon.showSuccessSnackBar(context, text: translations.totp.actions.copyConfirmation);
    }
  }

  /// Allows to edit the TOTP.
  Future<void> _edit(BuildContext context) async {
    await Navigator.pushNamed(context, TotpPage.name, arguments: {OpenAuthenticatorApp.kRouteParameterTotp: totp});
  }

  /// Allows to delete the TOTP.
  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    bool confirmation = await ConfirmationDialog.ask(
      context,
      title: translations.totp.actions.deleteConfirmationDialog.title,
      message: translations.totp.actions.deleteConfirmationDialog.message,
    );
    if (!confirmation) {
      return;
    }
    if ((await ref.read(totpRepositoryProvider.notifier).deleteTotp(totp)) is ResultError && context.mounted) {
      SnackBarIcon.showErrorSnackBar(context, text: translations.error.generic.noTryAgain);
    }
  }

  /// Triggered when the user long presses the widget on mobile.
  Future<void> _showMobileActionsMenu(BuildContext context, WidgetRef ref) async {
    if (!currentPlatform.isMobile && !kDebugMode) {
      Navigator.pushNamed(context, TotpPage.name);
      return;
    }
    _MobileActionsDialogResult? choice = await showAdaptiveDialog<_MobileActionsDialogResult>(
      context: context,
      builder: (context) => _MobileActionsDialog(),
    );
    if (choice == null || !context.mounted) {
      return;
    }
    switch (choice) {
      case _MobileActionsDialogResult.edit:
        _edit(context);
        break;
      case _MobileActionsDialogResult.delete:
        _delete(context, ref);
        break;
    }
  }

  /// Tries to decrypt the current TOTP.
  Future<void> _tryDecrypt(BuildContext context, WidgetRef ref) async {
    String? password = await TextInputDialog.prompt(
      context,
      title: translations.totp.decryptDialog.title,
      message: translations.totp.decryptDialog.message,
      password: true,
    );
    if (password == null) {
      return;
    }
    Totp result = await totp.decrypt(await CryptoStore.fromPassword(password, salt: totp.encryptionSalt));
    if (!result.isDecrypted) {
      if (context.mounted) {
        SnackBarIcon.showErrorSnackBar(context, text: translations.error.totpDecrypt);
      }
      return;
    }
    TotpRepository repository =  await ref.read(totpRepositoryProvider.notifier);
    await repository.deleteTotp(totp);
    await repository.addTotp(result);
    if (context.mounted) {
      SnackBarIcon.showSuccessSnackBar(context, text: translations.error.noError);
    }
  }
}

/// Wraps all two desktop actions in a dialog.
class _MobileActionsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AlertDialog.adaptive(
        title: Text(translations.totp.actions.mobileDialog.title),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              onTap: () => Navigator.pop(context, _MobileActionsDialogResult.edit),
              title: Text(translations.totp.actions.mobileDialog.edit),
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              onTap: () => Navigator.pop(context, _MobileActionsDialogResult.delete),
              title: Text(translations.totp.actions.mobileDialog.delete),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
        ],
      );
}

/// The [_MobileActionsDialog] result.
enum _MobileActionsDialogResult {
  /// When the user wants to edit the TOTP.
  edit,

  /// When the user wants to delete the TOTP.
  delete;
}

/// Wraps all three desktop actions in a widget.
class _DesktopActionsWidget extends StatelessWidget {
  /// Triggered when the user clicks on "Decrypt".
  final VoidCallback? onDecryptPressed;

  /// Triggered when the user clicks on "Copy code".
  final VoidCallback? onCopyPressed;

  /// Triggered when the user clicks on "Edit".
  final VoidCallback onEditPressed;

  /// Triggered when the user clicks on "Delete".
  final VoidCallback onDeletePressed;

  /// Creates a new desktop actions instance.
  const _DesktopActionsWidget({
    this.onDecryptPressed,
    this.onCopyPressed,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) => Wrap(
        alignment: WrapAlignment.end,
        children: [
          if (onDecryptPressed == null)
            TextButton.icon(
              onPressed: onCopyPressed,
              icon: const Icon(Icons.copy),
              label: Text(translations.totp.actions.desktopButtons.copy),
            )
          else
            TextButton.icon(
              onPressed: onDecryptPressed,
              icon: const Icon(Icons.lock),
              label: Text(translations.totp.actions.decrypt),
            ),
          TextButton.icon(
            onPressed: onEditPressed,
            icon: const Icon(Icons.edit),
            label: Text(translations.totp.actions.desktopButtons.edit),
          ),
          TextButton.icon(
            onPressed: onDeletePressed,
            icon: const Icon(Icons.delete),
            label: Text(translations.totp.actions.desktopButtons.delete),
          ),
        ],
      );
}
