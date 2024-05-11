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
import 'package:open_authenticator/utils/master_password.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/dialog/confirmation_dialog.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';
import 'package:open_authenticator/widgets/totp/code.dart';
import 'package:open_authenticator/widgets/totp/image.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';

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
                      onDecryptPressed: totp.isDecrypted ? null : () => _tryDecrypt(context, ref),
                      onEditPressed: () async => await _edit(context, ref),
                      onDeletePressed: () async => await _delete(context, ref),
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
  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    CryptoStore? currentCryptoStore = await ref.read(cryptoStoreProvider.future);
    if (currentCryptoStore == null) {
      if (context.mounted) {
        SnackBarIcon.showErrorSnackBar(context, text: translations.error.generic.tryAgain);
      }
      return;
    }
    if (!(await totp.encryptedData.canDecryptData(currentCryptoStore))) {
      if (context.mounted) {
        bool shouldContinue = await ConfirmationDialog.ask(
          context,
          title: translations.totp.actions.editConfirmationDialog.title,
          message: translations.totp.actions.editConfirmationDialog.message,
        );
        if (!shouldContinue) {
          return;
        }
      }
    }
    if (context.mounted) {
      await Navigator.pushNamed(context, TotpPage.name, arguments: {OpenAuthenticatorApp.kRouteParameterTotp: totp});
    }
  }

  /// Allows to delete the TOTP.
  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    bool confirmation = await ConfirmationDialog.ask(
      context,
      title: translations.totp.actions.deleteConfirmationDialog.title,
      message: translations.totp.actions.deleteConfirmationDialog.message,
    );
    if (!confirmation || !context.mounted) {
      return;
    }
    Result result = await showWaitingOverlay(
      context,
      future: ref.read(totpRepositoryProvider.notifier).deleteTotp(totp),
    );
    if (result is ResultError && context.mounted) {
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
      builder: (context) => _MobileActionsDialog(
        canEdit: totp.isDecrypted,
      ),
    );
    if (choice == null || !context.mounted) {
      return;
    }
    switch (choice) {
      case _MobileActionsDialogResult.edit:
        _edit(context, ref);
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
    if (password == null || !context.mounted) {
      return;
    }

    late CryptoStore previousCryptoStore;
    TotpRepository repository = ref.read(totpRepositoryProvider.notifier);
    Totp decrypted = await showWaitingOverlay(
      context,
      future: () async {
        previousCryptoStore = await CryptoStore.fromPassword(password, totp.encryptedData.encryptionSalt);
        return await totp.decrypt(previousCryptoStore);
      }(),
    );
    if (!context.mounted) {
      return;
    }
    if (!decrypted.isDecrypted) {
      SnackBarIcon.showErrorSnackBar(context, text: translations.error.totpDecrypt);
      return;
    }

    _TotpKeyDialogResult? choice = await showAdaptiveDialog<_TotpKeyDialogResult>(
      context: context,
      builder: (context) => _TotpKeyDialog(),
    );

    switch (choice) {
      case _TotpKeyDialogResult.changeTotpKey:
        CryptoStore? currentCryptoStore = await ref.read(cryptoStoreProvider.future);
        if (currentCryptoStore == null) {
          if (context.mounted) {
            SnackBarIcon.showErrorSnackBar(context, text: translations.error.generic.tryAgain);
          }
          break;
        }
        DecryptedTotp? decryptedTotpWithNewKey = await totp.changeEncryptionKey(previousCryptoStore, currentCryptoStore);
        if (decryptedTotpWithNewKey == null || !decryptedTotpWithNewKey.isDecrypted) {
          if (context.mounted) {
            SnackBarIcon.showErrorSnackBar(context, text: translations.error.generic.tryAgain);
          }
          break;
        }
        await repository.updateTotp(totp.uuid, decryptedTotpWithNewKey);
        break;
      case _TotpKeyDialogResult.changeMasterPassword:
        if (context.mounted) {
          await MasterPasswordUtils.changeMasterPassword(context, ref, password: password);
        }
        break;
      default:
        break;
    }
    await repository.tryDecryptAll(previousCryptoStore);
  }
}

/// Wraps all two mobile actions in a dialog.
class _MobileActionsDialog extends StatelessWidget {
  /// Whether the user can edit the TOTP.
  final bool canEdit;

  /// Creates a new mobile actions dialog instance.
  const _MobileActionsDialog({
    this.canEdit = true,
  });

  @override
  Widget build(BuildContext context) => AlertDialog.adaptive(
        title: Text(translations.totp.actions.mobileDialog.title),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canEdit)
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

/// Allows the user to choose an action to execute when a TOTP decryption has been done with success.
class _TotpKeyDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AlertDialog.adaptive(
        title: Text(translations.totp.totpKeyDialog.title),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              translations.totp.totpKeyDialog.message,
            ),
            ListTile(
              leading: const Icon(Icons.key),
              onTap: () => Navigator.pop(context, _TotpKeyDialogResult.changeTotpKey),
              title: Text(translations.totp.totpKeyDialog.choices.changeTotpKey.title),
              subtitle: Text(translations.totp.totpKeyDialog.choices.changeTotpKey.subtitle),
            ),
            ListTile(
              leading: const Icon(Icons.password),
              onTap: () => Navigator.pop(context, _TotpKeyDialogResult.changeMasterPassword),
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
        ],
      );
}

/// The [_TotpKeyDialog] result.
enum _TotpKeyDialogResult {
  /// Allows to change the TOTP key.
  changeTotpKey,

  /// Allows to change the current master password.
  changeMasterPassword;
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
