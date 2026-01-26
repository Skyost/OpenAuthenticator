import 'package:flutter/material.dart';
import 'package:open_authenticator/widgets/clickable.dart';
import 'package:open_authenticator/widgets/dialog/app_dialog.dart';
import 'package:open_authenticator/widgets/error.dart';

/// A dialog displaying an error with the option to retry.
class ErrorDialog extends StatelessWidget {
  /// The additional message to display.
  final String? message;

  /// The error.
  final Object? error;

  /// The stacktrace.
  final StackTrace stackTrace;

  /// Whether to allow retry.
  final bool allowRetry;

  /// Creates a new error display widget instance.
  const ErrorDialog({
    super.key,
    this.message,
    this.error,
    required this.stackTrace,
    this.allowRetry = true,
  });

  @override
  Widget build(BuildContext context) => AppDialog(
    title: const Text('Erreur'),
    actions: [
      if (allowRetry)
        ClickableButton(
          onPress: () => Navigator.pop(context, ErrorDialogResult.report),
          child: const Text('Reporter'),
        ),
      ClickableButton(
        onPress: () => Navigator.pop(context, ErrorDialogResult.cancel),
        child: const Text('Annuler'),
      ),
    ], // TODO: Localize
    children: [
      ErrorDetails(
        error: error,
        stackTrace: stackTrace,
        message: message,
      ),
    ],
  );

  /// Opens the dialog.
  static Future<ErrorDialogResult?> openDialog(
    BuildContext context, {
    String? message,
    Object? error,
    StackTrace? stackTrace,
  }) => showDialog<ErrorDialogResult>(
    context: context,
    builder: (context) => ErrorDialog(
      message: message,
      error: error,
      stackTrace: stackTrace ?? StackTrace.current,
    ),
  );
}

/// The result of the error dialog.
enum ErrorDialogResult {
  /// The user pressed cancel.
  cancel,

  /// The user pressed report.
  report,
}
