import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/countdown.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';

/// The dialog that allows the user to verify its email.
class VerifyEmailDialog extends ConsumerStatefulWidget {
  /// The buttons minimum width.
  static const double _kDefaultButtonMinWidth = 200;

  /// The buttons minimum width.
  final double buttonsMinWidth;

  /// Creates a new verify email dialog instance.
  const VerifyEmailDialog({
    super.key,
    this.buttonsMinWidth = _kDefaultButtonMinWidth,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VerifyEmailDialogState();

  /// Shows the dialog.
  static Future<void> show(BuildContext context) => showAdaptiveDialog(
        context: context,
        builder: (context) => const VerifyEmailDialog(),
      );
}

/// The verify email dialog state.
class _VerifyEmailDialogState extends ConsumerState<VerifyEmailDialog> {
  /// The timer before being able to send another mail.
  Timer? nextMailTimer;

  /// The time to wait before a verification mail can be sent.
  Duration timeToWaitBeforeNextVerificationEmail = FirebaseAuth.instance.timeToWaitBeforeNextVerificationEmail;

  @override
  Widget build(BuildContext context) {
    FirebaseAuthenticationState state = ref.watch(firebaseAuthenticationProvider);
    List<Widget> children = [
      Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Text('We need to verify your address mail to confirm your account. Please click on the button below to receive an email and click on the received link to continue.'),
      ),
    ];
    switch (state) {
      case FirebaseAuthenticationStateEmailNeedsVerification():
        children.addAll(
          [
            if (timeToWaitBeforeNextVerificationEmail == Duration.zero)
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: widget.buttonsMinWidth),
                child: FilledButton.tonalIcon(
                  onPressed: sendMail,
                  icon: Icon(Icons.mail),
                  label: Text('Send a mail'),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: widget.buttonsMinWidth),
                child: FilledButton.tonalIcon(
                  onPressed: null,
                  icon: Icon(Icons.hourglass_bottom),
                  label: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'Wait '),
                        WidgetSpan(
                          child: CountdownWidget(duration: timeToWaitBeforeNextVerificationEmail),
                        ),
                        TextSpan(text: ' before sending another mail')
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: widget.buttonsMinWidth),
                child: TextButton.icon(
                  onPressed: () {
                    showWaitingOverlay(
                      context,
                      future: () async {
                        ref.read(firebaseAuthenticationProvider.notifier).refreshUser();
                        await Future.delayed(Duration(seconds: 1));
                      }(),
                    );
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('Refresh'),
                ),
              ),
            ),
          ],
        );
        break;
      case FirebaseAuthenticationStateLoggedIn():
        children.add(
          FilledButton.tonalIcon(
            onPressed: null,
            icon: Icon(Icons.check),
            label: Text('Verified with success'),
          ),
        );
        break;
      default:
        break;
    }
    return AlertDialog.adaptive(
      title: Text('Verify email'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            state is FirebaseAuthenticationStateLoggedIn ? MaterialLocalizations.of(context).closeButtonLabel : MaterialLocalizations.of(context).cancelButtonLabel,
          ),
        ),
      ],
      scrollable: true,
    );
  }

  @override
  void dispose() {
    nextMailTimer?.cancel();
    super.dispose();
  }

  /// Sends a mail, if possible.
  Future<void> sendMail() async {
    Result result = await showWaitingOverlay(
      context,
      future: ref.read(firebaseAuthenticationProvider.notifier).sendVerificationEmail(),
    );
    Duration timeToWaitBeforeNextVerificationEmail = FirebaseAuth.instance.timeToWaitBeforeNextVerificationEmail + const Duration(seconds: 1);
    if (mounted) {
      context.showSnackBarForResult(
        result,
        retryIfError: true,
      );
      setState(() => this.timeToWaitBeforeNextVerificationEmail = timeToWaitBeforeNextVerificationEmail);
    }
    nextMailTimer = Timer(
      timeToWaitBeforeNextVerificationEmail,
      () {
        if (mounted) {
          setState(() {
            nextMailTimer = null;
            this.timeToWaitBeforeNextVerificationEmail = Duration.zero;
          });
        }
      },
    );
  }
}
