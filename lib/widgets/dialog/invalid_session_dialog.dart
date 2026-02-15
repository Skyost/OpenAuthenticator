import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/utils/account.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/clickable.dart';
import 'package:open_authenticator/widgets/dialog/app_dialog.dart';

class InvalidSessionDialog extends ConsumerWidget {
  final bool handleResult;

  const InvalidSessionDialog._({
    super.key,
    this.handleResult = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => AppDialog(
    title: const Text('Invalid session'),
    actions: [
      ClickableButton(
        onPress: () async {
          Result result = handleResult ? (await AccountUtils.trySignIn(context)) : const ResultSuccess();
          if (result is ResultSuccess && context.mounted) {
            Navigator.pop(context, InvalidSessionDialogChoice.logIn);
          }
        },
        child: const Text('Log-in'),
      ),
      ClickableButton(
        variant: .secondary,
        onPress: () => Navigator.pop(context),
        child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
      ),
    ],
    children: [
      const Text('Your session has either expired or is invalid. Please log-in again to synchronize your TOTPs.'),
    ],
  );

  static Future<InvalidSessionDialogChoice?> openDialog(BuildContext context, {bool handleResult = false}) async =>
      await (showDialog<InvalidSessionDialogChoice>(
        context: context,
        builder: (context) => const InvalidSessionDialog._(),
      ));

  static Future<void> openDialogAndHandleChoice(BuildContext context) => openDialog(context, handleResult: true);
}

enum InvalidSessionDialogChoice { logIn }
