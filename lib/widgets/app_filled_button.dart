import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The [AppFilledButton] default max width.
const double kAppFilledButtonDefaultMaxWidth = 300;

/// A filled button, tonal or not, with a max width.
class AppFilledButton extends StatelessWidget {
  /// The max width.
  final double maxWidth;

  /// The label.
  final Widget label;

  /// The button style.
  final ButtonStyle? style;

  /// The icon.
  final Widget? icon;

  /// Triggered when tapped on.
  final VoidCallback? onPressed;

  /// Whether to use tonal color.
  final bool tonal;

  /// Creates a new app filled button.
  const AppFilledButton({
    super.key,
    this.maxWidth = kAppFilledButtonDefaultMaxWidth,
    required this.label,
    this.style,
    this.icon,
    this.onPressed,
    this.tonal = false,
  });

  @override
  Widget build(BuildContext context) => Align(
        child: SizedBox(
          width: math.min(MediaQuery.sizeOf(context).width - 20, maxWidth),
          child: tonal
              ? FilledButton.tonalIcon(
                  onPressed: onPressed,
                  style: style,
                  label: label,
                  icon: icon,
                )
              : FilledButton.icon(
                  onPressed: onPressed,
                  style: style,
                  label: label,
                  icon: icon,
                ),
        ),
      );
}
