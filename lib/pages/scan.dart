import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/main.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';
import 'package:open_authenticator/pages/home.dart';
import 'package:open_authenticator/pages/totp.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/code_scan.dart';
import 'package:open_authenticator/widgets/dialog/confirmation_dialog.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';

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
          if (code != null && context.mounted) {
            Uri? uri = Uri.tryParse(code);
            if (uri == null) {
              SnackBarIcon.showErrorSnackBar(context, text: translations.scan.error.noUri);
              return;
            }
            CryptoStore? cryptoStore = await ref.read(cryptoStoreProvider.future);
            DecryptedTotp? totp = await DecryptedTotp.fromUri(uri, cryptoStore);
            if (!context.mounted) {
              return;
            }
            if (totp == null) {
              SnackBarIcon.showErrorSnackBar(context, text: translations.scan.error.scanError(exception: Exception('Failed to decrypt TOTP.')));
              return;
            }
            Navigator.pushNamedAndRemoveUntil(
              context,
              TotpPage.name,
              (route) => route.settings.name == HomePage.name,
              arguments: {
                OpenAuthenticatorApp.kRouteParameterTotp: totp,
                OpenAuthenticatorApp.kRouteParameterAddTotp: true,
              },
            );
          }
        },
        onAccessDenied: (exception, listener) => ConfirmationDialog.ask(
          context,
          title: translations.scan.error.accessDeniedDialog.title,
          message: translations.scan.error.accessDeniedDialog.message(exception: exception),
        ),
        onError: (exception, listener) => SnackBarIcon.showErrorSnackBar(context, text: translations.scan.error.scanError(exception: exception)),
      );
}
