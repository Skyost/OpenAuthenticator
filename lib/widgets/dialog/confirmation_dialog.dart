import 'package:flutter/material.dart';

/// A dialog that allows to choose whether to execute an action or not.
class ConfirmationDialog extends StatelessWidget {
  /// The dialog title.
  final String title;

  /// The dialog message.
  final String message;

  /// Creates a confirmation dialog instance.
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) => AlertDialog.adaptive(
        title: Text(title),
        scrollable: true,
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
        ],
      );

  /// Asks for the confirmation.
  static Future<bool> ask(
    BuildContext context, {
    required String title,
    required String message,
  }) async =>
      (await showAdaptiveDialog(
        context: context,
        builder: (context) => ConfirmationDialog(
          title: title,
          message: message,
        ),
      )) ==
      true;
}
