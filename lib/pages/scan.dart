import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/pages/totp.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/code_scan.dart';
import 'package:open_authenticator/widgets/dialog/confirmation_dialog.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';

/// Allows to scan QR codes.
class ScanPage extends ConsumerWidget {
  /// The scan page name.
  static const String name = '/scan';

  /// Creates a new scan page instance.
  const ScanPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => CodeScanner(
        once: true,
        formats: const [BarcodeFormat.qrCode],
        loading: const CenteredCircularProgressIndicator(),
        onScan: (code, details, listener) async {
          if (code == null || !context.mounted) {
            return;
          }
          Uri? uri = Uri.tryParse(code);
          if (uri == null) {
            SnackBarIcon.showErrorSnackBar(context, text: translations.error.scan.noUri);
            return;
          }
          await showWaitingOverlay(
            context,
            future: TotpPage.openFromUri(context, ref, uri),
          );
        },
        onAccessDenied: (exception, listener) => ConfirmationDialog.ask(
          context,
          title: translations.error.scan.accessDeniedDialog.title,
          message: translations.error.scan.accessDeniedDialog.message(exception: exception),
        ),
        onError: (exception, listener) => SnackBarIcon.showErrorSnackBar(context, text: translations.error.generic.withException(exception: exception)),
      );
}
