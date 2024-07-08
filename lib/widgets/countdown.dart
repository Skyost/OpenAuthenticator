import 'dart:async';

import 'package:flutter/material.dart';

/// A countdown widget.
class CountdownWidget extends StatefulWidget {
  /// The timeout.
  final Duration duration;

  /// Triggered when the countdown has finished.
  final VoidCallback? onFinished;

  /// The text style.
  final TextStyle? textStyle;

  /// Creates a new waiting dialog instance.
  const CountdownWidget({
    super.key,
    required this.duration,
    this.onFinished,
    this.textStyle,
  });

  @override
  State<StatefulWidget> createState() => _CountdownWidgetState();
}

/// The countdown widget state.
class _CountdownWidgetState extends State<CountdownWidget> {
  /// The duration left.
  late Duration left = widget.duration;

  /// Whether to display the hours prefix.
  late bool showHoursPrefix = widget.duration.inHours >= 1;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), decreaseTime);
  }

  @override
  Widget build(BuildContext context) => Text(
        timeLeftText,
        style: widget.textStyle,
      );

  /// Decreases the time left.
  void decreaseTime(Timer timer) {
    if (mounted && left > Duration.zero) {
      setState(() => left = left - const Duration(seconds: 1));
    } else {
      timer.cancel();
      widget.onFinished?.call();
    }
  }

  /// The time left text.
  String get timeLeftText {
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    String hoursPrefix = showHoursPrefix ? '${twoDigits(left.inHours)}:' : '';
    String minutes = twoDigits(left.inMinutes.remainder(60));
    String seconds = twoDigits(left.inSeconds.remainder(60));
    return '$hoursPrefix$minutes:$seconds';
  }
}
