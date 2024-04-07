import 'dart:ui';

import 'package:flutter/material.dart';

/// Allows to blur a widget. Kudos to "jagritjkh/blur" for the initial implementation.
class BlurWidget extends StatelessWidget {
  /// The child widget.
  final Widget child;

  /// A widget to display above the blur effect.
  final Widget? above;

  /// Value of blur effect, higher the blur more the blur effect.
  final double blur;

  /// Color of blur effect.
  final Color blurColor;

  /// Radius of the child to be blurred.
  final BorderRadius? borderRadius;

  /// Opacity of the blurColor.
  final double colorOpacity;

  /// Widget that can be stacked over blurred widget.
  final Widget? overlay;

  /// Alignment geometry of the overlay.
  final AlignmentGeometry alignment;

  /// Creates a new blur widget instance.
  const BlurWidget({
    super.key,
    required this.child,
    this.above,
    this.blur = 5,
    this.blurColor = Colors.white,
    this.borderRadius,
    this.colorOpacity = 0.5,
    this.overlay,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Stack(
          children: [
            child,
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Container(
                  decoration: BoxDecoration(
                    color: blurColor.withOpacity(colorOpacity),
                  ),
                  alignment: alignment,
                  child: overlay,
                ),
              ),
            ),
            if (above != null) above!,
          ],
        ),
      );
}
