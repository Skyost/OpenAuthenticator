import 'package:flutter/material.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/widgets/countdown.dart';

/// Shows a waiting dialog.
Future<T> showWaitingDialog<T>(
  BuildContext context, {
  Future<T>? future,
  String? message,
  Duration? timeout,
  String? timeoutMessage,
  bool Function()? onCancel,
}) async {
  GlobalKey dialogKey = GlobalKey();
  showAdaptiveDialog(
    context: context,
    builder: (context) => _WaitingDialog(
      key: dialogKey,
      message: message,
      timeout: timeout,
      timeoutMessage: timeoutMessage,
      onCancel: onCancel,
    ),
  );
  if (future != null) {
    T result = await future;
    if (dialogKey.currentContext?.mounted ?? false) {
      Navigator.pop(dialogKey.currentContext!);
    }
    return result;
  }
  return null as T;
}

/// A waiting dialog, with or without a timeout.
class _WaitingDialog extends StatefulWidget {
  /// The message to display.
  final String? message;

  /// The timeout.
  final Duration? timeout;

  /// Shown when timed out.
  final String? timeoutMessage;

  /// The cancel callback.
  final bool Function()? onCancel;

  /// Creates a new waiting dialog instance.
  const _WaitingDialog({
    super.key,
    this.message,
    this.timeout,
    this.timeoutMessage,
    this.onCancel,
  });

  @override
  State<StatefulWidget> createState() => _WaitingDialogState();
}

/// The waiting dialog state.
class _WaitingDialogState extends State<_WaitingDialog> {
  /// Whether we ran out of time.
  bool timedOut = false;

  @override
  Widget build(BuildContext context) => AlertDialog.adaptive(
        content: PopScope(
          canPop: false,
          child: timedOut
              ? Text(widget.timeoutMessage ?? translations.miscellaneous.waitingDialog.defaultTimeoutMessage)
              : Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 24),
                      child: CircularProgressIndicator(),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: widget.message ?? translations.miscellaneous.waitingDialog.defaultMessage),
                          if (widget.timeout != null) ...[
                            const TextSpan(text: '\n'),
                            translations.miscellaneous.waitingDialog.countdown(
                              countdown: WidgetSpan(
                                child: CountdownWidget(
                                  duration: widget.timeout!,
                                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                  onFinished: () {
                                    if (mounted) {
                                      setState(() => timedOut = true);
                                    }
                                  },
                                ),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        actions: widget.onCancel == null
            ? null
            : [
                TextButton(
                  child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                  onPressed: () {
                    if (widget.onCancel!()) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
      );
}
