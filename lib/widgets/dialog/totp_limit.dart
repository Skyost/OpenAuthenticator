import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/utils/contributor_plan.dart';
import 'package:open_authenticator/utils/storage_migration.dart';

/// A dialog that blocks everything until the user has either changed its storage type or subscribed to the Contributor Plan.
class TotpLimitDialog extends ConsumerWidget {
  /// The dialog title.
  final String title;

  /// The dialog message.
  final String message;

  /// Whether to add a cancel button.
  final bool cancelButton;

  /// Creates a new mandatory totp limit dialog.
  const TotpLimitDialog({
    super.key,
    required this.title,
    required this.message,
    required this.cancelButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => AlertDialog(
        title: Text(title),
        scrollable: true,
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => _returnIfSucceeded(context, StorageMigrationUtils.changeStorageType(context, ref, StorageType.local)),
            child: Text(translations.totpLimit.autoDialog.actions.stopSynchronization),
          ),
          TextButton(
            onPressed: () => _returnIfSucceeded(context, ContributorPlanUtils.purchase(context, ref)),
            child: Text(translations.totpLimit.autoDialog.actions.subscribe),
          ),
          if (cancelButton)
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(translations.totpLimit.addDialog.actions.cancel),
            ),
        ],
      );

  /// Waits for the [action] result before closing the dialog in case of success.
  Future<void> _returnIfSucceeded(BuildContext context, Future<bool> action) async {
    bool result = await action;
    if (context.mounted && result) {
      Navigator.pop(context, true);
    }
  }

  static Future<void> showAndBlock(
    BuildContext context, {
    String? title,
    String? message,
    bool cancelButton = false,
  }) async {
    bool result = false;
    while (!result && context.mounted) {
      result = await show(context);
    }
  }

  /// Shows the totp limit dialog.
  static Future<bool> show(
    BuildContext context, {
    String? title,
    String? message,
    bool cancelButton = false,
  }) async =>
      (await showDialog<bool>(
        context: context,
        builder: (context) => TotpLimitDialog(
          title: title ?? translations.totpLimit.autoDialog.title,
          message: message ??
              translations.totpLimit.autoDialog.message(
                count: App.freeTotpsLimit.toString(),
              ),
          cancelButton: cancelButton,
        ),
        barrierDismissible: false,
      )) ==
      true;
}
