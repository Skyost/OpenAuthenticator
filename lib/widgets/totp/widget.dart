import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/pages/totp.dart';
import 'package:open_authenticator/utils/platform.dart';
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

  /// Triggered when the "decrypt" button has been pressed.
  final VoidCallback? onDecryptPressed;

  /// Triggered when the "edit" button has been pressed.
  final VoidCallback? onEditPressed;

  /// Triggered when the "delete" button has been pressed.
  final VoidCallback? onDeletePressed;

  /// Creates a new TOTP widget instance.
  const TotpWidget({
    super.key,
    required this.totp,
    this.imageSize = 70,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    this.space = 10,
    this.displayCode = true,
    this.onDecryptPressed,
    this.onEditPressed,
    this.onDeletePressed,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (totp.isDecrypted && (totp as DecryptedTotp).issuer != null && (totp as DecryptedTotp).issuer!.isNotEmpty)
                  Text(
                    ((totp as DecryptedTotp)).issuer!,
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Text(
                  (totp.isDecrypted ? (totp as DecryptedTotp).label : null) ?? totp.uuid,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                      onDecryptPressed: totp.isDecrypted ? null : onDecryptPressed,
                      onEditPressed: onEditPressed,
                      onDeletePressed: onDeletePressed,
                    ),
                  ),
              ],
            ),
          ),
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
                onPressed: onDecryptPressed,
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

  /// Triggered when the user long presses the widget on mobile.
  Future<void> _showMobileActionsMenu(BuildContext context, WidgetRef ref) async {
    if (!currentPlatform.isMobile && !kDebugMode) {
      Navigator.pushNamed(context, TotpPage.name);
      return;
    }
    _MobileActionsDialogResult? choice = await showDialog<_MobileActionsDialogResult>(
      context: context,
      builder: (context) => _MobileActionsDialog(
        canEdit: totp.isDecrypted,
        editButtonEnabled: onEditPressed != null,
        deleteButtonEnabled: onDeletePressed != null,
      ),
    );
    if (choice == null || !context.mounted) {
      return;
    }
    switch (choice) {
      case _MobileActionsDialogResult.edit:
        onEditPressed?.call();
        break;
      case _MobileActionsDialogResult.delete:
        onDeletePressed?.call();
        break;
    }
  }
}

/// Wraps all two mobile actions in a dialog.
class _MobileActionsDialog extends StatelessWidget {
  /// Whether the user can edit the TOTP.
  final bool canEdit;

  /// Whether the "edit" button can been pressed.
  final bool editButtonEnabled;

  /// Whether the "delete" button can been pressed.
  final bool deleteButtonEnabled;

  /// Creates a new mobile actions dialog instance.
  const _MobileActionsDialog({
    this.canEdit = true,
    this.editButtonEnabled = true,
    this.deleteButtonEnabled = true,
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(translations.totp.actions.mobileDialog.title),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canEdit)
              ListTile(
                leading: const Icon(Icons.edit),
                onTap: editButtonEnabled ? (() => Navigator.pop(context, _MobileActionsDialogResult.edit)) : null,
                title: Text(translations.totp.actions.mobileDialog.edit),
              ),
            ListTile(
              leading: const Icon(Icons.delete),
              onTap: deleteButtonEnabled ? (() => Navigator.pop(context, _MobileActionsDialogResult.delete)) : null,
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
  final VoidCallback? onEditPressed;

  /// Triggered when the user clicks on "Delete".
  final VoidCallback? onDeletePressed;

  /// Creates a new desktop actions instance.
  const _DesktopActionsWidget({
    this.onDecryptPressed,
    this.onCopyPressed,
    this.onEditPressed,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) => Wrap(
        alignment: WrapAlignment.end,
        children: [
          if (onDecryptPressed == null) ...[
            TextButton.icon(
              onPressed: onCopyPressed,
              icon: const Icon(Icons.copy),
              label: Text(translations.totp.actions.desktopButtons.copy),
            ),
            TextButton.icon(
              onPressed: onEditPressed,
              icon: const Icon(Icons.edit),
              label: Text(translations.totp.actions.desktopButtons.edit),
            ),
          ] else
            TextButton.icon(
              onPressed: onDecryptPressed,
              icon: const Icon(Icons.lock),
              label: Text(translations.totp.actions.decrypt),
            ),
          TextButton.icon(
            onPressed: onDeletePressed,
            icon: const Icon(Icons.delete),
            label: Text(translations.totp.actions.desktopButtons.delete),
          ),
        ],
      );
}
