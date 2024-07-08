import 'package:flutter/material.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';
import 'package:open_authenticator/widgets/totp/time_based.dart';

/// Displays a TOTP code.
class TotpCodeWidget extends TimeBasedTotpWidget {
  /// The text style.
  final TextStyle? textStyle;

  /// Creates a new TOTP code widget instance.
  const TotpCodeWidget({
    super.key,
    required super.totp,
    this.textStyle,
  });

  @override
  State<TimeBasedTotpWidget> createState() => _TotpCodeWidgetState();
}

/// The TOTP code widget state.
class _TotpCodeWidgetState extends TimeBasedTotpWidgetState<TotpCodeWidget> {
  /// The current code.
  late String code = currentTimeCode;

  @override
  Widget build(BuildContext context) => Text(
        code,
        style: widget.textStyle,
      );

  @override
  void updateState() {
    if (mounted) {
      setState(() => code = currentTimeCode);
    }
  }

  /// Returns the time that corresponds to the current time.
  String get currentTimeCode {
    if (!widget.totp.isDecrypted) {
      return '';
    }
    String code = (widget.totp as DecryptedTotp).generator.value().toString();
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < code.length; i++) {
      buffer.write(code[i]);
      int nonZeroIndex = i + 1;
      if (nonZeroIndex % 3 == 0 && nonZeroIndex != code.length) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }
}
