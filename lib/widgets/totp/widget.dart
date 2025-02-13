import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/pages/totp.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/widgets/dialog/app_dialog.dart';
import 'package:open_authenticator/widgets/totp/code.dart';
import 'package:open_authenticator/widgets/totp/image.dart';

/// Allows to display TOTPs in a [ListView].
class TotpWidget extends StatelessWidget {
  /// The default image size.
  static const double _kDefaultImageSize = 70;

  /// The default padding.
  static const EdgeInsets _kDefaultPadding = EdgeInsets.symmetric(vertical: 10, horizontal: 16);

  /// The default space.
  static const double _kDefaultSpace = 10;

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

  /// Triggered when tapped.
  final Function(BuildContext context)? onTap;

  /// Triggered when long pressed.
  final Function(BuildContext context)? onLongPress;

  /// The footer widget builder.
  final WidgetBuilder? footerWidgetBuilder;

  /// the trailing widget builder.
  final WidgetBuilder? trailingWidgetBuilder;

  /// Creates a new TOTP widget instance that adapts itself to the current platform.
  TotpWidget.adaptive({
    Key? key,
    required Totp totp,
    double imageSize = _kDefaultImageSize,
    EdgeInsets contentPadding = _kDefaultPadding,
    double space = _kDefaultSpace,
    bool displayCode = true,
    Function(BuildContext context)? onTap,
    VoidCallback? onDecryptPressed,
    VoidCallback? onEditPressed,
    VoidCallback? onDeletePressed,
    VoidCallback? onCopyPressed,
  }) : this(
          key: key,
          totp: totp,
          imageSize: imageSize,
          contentPadding: contentPadding,
          space: space,
          displayCode: displayCode,
          onTap: onTap,
          footerWidgetBuilder: currentPlatform.isDesktop
              ? ((context) => _DesktopActionsWidget(
                    totp: totp,
                    onDecryptPressed: onDecryptPressed,
                    onEditPressed: onEditPressed,
                    onDeletePressed: onDeletePressed,
                    onCopyPressed: onCopyPressed,
                  ))
              : null,
          trailingWidgetBuilder: currentPlatform.isMobile
              ? ((context) {
                  Color color = Theme.of(context).colorScheme.primary;
                  if (totp.isDecrypted) {
                    return onCopyPressed == null
                        ? const SizedBox.shrink()
                        : IconButton(
                            icon: Icon(
                              Icons.copy,
                              color: color,
                            ),
                            onPressed: onCopyPressed,
                          );
                  } else {
                    return onDecryptPressed == null
                        ? const SizedBox.shrink()
                        : IconButton(
                            icon: Icon(
                              Icons.lock,
                              color: color,
                            ),
                            onPressed: onDecryptPressed,
                          );
                  }
                })
              : null,
          onLongPress: currentPlatform.isMobile || kDebugMode
              ? ((context) => _showMobileActionsMenu(
                    context,
                    totp,
                    onEditPressed: onEditPressed,
                    onDeletePressed: onDeletePressed,
                  ))
              : null,
        );

  /// Creates a new TOTP widget instance.
  const TotpWidget({
    super.key,
    required this.totp,
    this.imageSize = _kDefaultImageSize,
    this.contentPadding = _kDefaultPadding,
    this.space = _kDefaultSpace,
    this.displayCode = true,
    this.onTap,
    this.onLongPress,
    this.footerWidgetBuilder,
    this.trailingWidgetBuilder,
  });

  @override
  Widget build(BuildContext context) {
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
                if (footerWidgetBuilder != null)
                  SizedBox(
                    width: MediaQuery.of(context).size.width - contentPadding.left - contentPadding.right - imageSize - space,
                    child: footerWidgetBuilder!.call(context),
                  ),
              ],
            ),
          ),
          if (trailingWidgetBuilder != null) trailingWidgetBuilder!.call(context),
        ],
      ),
    );
    return (onLongPress != null || onTap != null)
        ? InkWell(
            onLongPress: onLongPress == null ? null : (() => onLongPress!.call(context)),
            onTap: onTap == null ? null : (() => onTap!.call(context)),
            child: result,
          )
        : result;
  }

  /// Triggered when the user long presses the widget on mobile.
  static Future<void> _showMobileActionsMenu(
    BuildContext context,
    Totp totp, {
    VoidCallback? onEditPressed,
    VoidCallback? onDeletePressed,
  }) async {
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
  Widget build(BuildContext context) => AppDialog(
        title: Text(translations.totp.actions.mobileDialog.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
        ],
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
  /// The TOTP instance.
  final Totp totp;

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
    required this.totp,
    this.onDecryptPressed,
    this.onCopyPressed,
    this.onEditPressed,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (totp.isDecrypted) ...[
            Flexible(
              child: TextButton.icon(
                onPressed: onCopyPressed,
                icon: const Icon(Icons.copy),
                label: Text(
                  translations.totp.actions.desktopButtons.copy,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Flexible(
              child: TextButton.icon(
                onPressed: onEditPressed,
                icon: const Icon(Icons.edit),
                label: Text(
                  translations.totp.actions.desktopButtons.edit,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ] else
            Flexible(
              child: TextButton.icon(
                onPressed: onDecryptPressed,
                icon: const Icon(Icons.lock),
                label: Text(
                  translations.totp.actions.decrypt,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          Flexible(
            child: TextButton.icon(
              onPressed: onDeletePressed,
              icon: const Icon(Icons.delete),
              label: Text(
                translations.totp.actions.desktopButtons.delete,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      );
}
