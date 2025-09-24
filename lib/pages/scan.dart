import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/pages/totp.dart';
import 'package:open_authenticator/widgets/scan/scanner.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Allows to scan QR codes.
class ScanPage extends ConsumerStatefulWidget {
  /// The scan page name.
  static const String name = '/scan';

  /// Creates a new scan page instance.
  const ScanPage({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScanPageState();
}

/// The scan page state.
class _ScanPageState extends ConsumerState<ScanPage> {
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: QrCodeScanner(
      onScan: (barcode) async {
        Uri? uri = Uri.tryParse(barcode);
        if (uri == null) {
          SnackBarIcon.showErrorSnackBar(context, text: translations.error.scan.noUri);
          return true;
        }
        await showWaitingOverlay(
          context,
          future: TotpPage.openFromUri(context, ref, uri),
        );
        return false;
      },
      onError: (exception, listener) => SnackBarIcon.showErrorSnackBar(context, text: translations.error.generic.withException(exception: exception)),
    ),
    floatingActionButton: FloatingActionButton(
      child: const Icon(Icons.close),
      onPressed: () => Navigator.pop(context),
    ),
  );

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(const []);
    WakelockPlus.disable();
    super.dispose();
  }
}
