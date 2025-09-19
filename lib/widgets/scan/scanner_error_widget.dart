import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:open_authenticator/i18n/translations.g.dart';

/// The scanner error widget.
class ScannerErrorWidget extends StatelessWidget {
  /// The error.
  final MobileScannerException error;

  /// Creates a new scanner error widget instance.
  const ScannerErrorWidget({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Colors.black,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Icon(
                Icons.error,
                color: Colors.white,
              ),
            ),
            Text(
              switch (error.errorCode) {
                MobileScannerErrorCode.controllerUninitialized => translations.error.scan.controllerUninitialized(exception: error.errorDetails?.details ?? error.errorCode),
                MobileScannerErrorCode.permissionDenied => translations.error.scan.accessDeniedDialog.message(exception: error.errorDetails?.details ?? error.errorCode),
                MobileScannerErrorCode.unsupported => translations.error.scan.unsupported(exception: error.errorDetails?.details ?? error.errorCode),
                _ => translations.error.generic.withException(exception: error.errorDetails?.details ?? error.errorCode),
              },
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
