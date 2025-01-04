import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:open_authenticator/utils/brightness_listener.dart';

/// Allows to blur a widget. Kudos to "jagritjkh/blur" for the initial implementation.
class BlurWidget extends StatefulWidget {
  /// A widget to display below the blur effect.
  final Widget? below;

  /// A widget to display above the blur effect.
  final Widget? above;

  /// Value of blur effect, higher the blur more the blur effect.
  final double blur;

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
    this.below,
    this.above,
    this.blur = 5,
    this.borderRadius,
    this.colorOpacity = 0.5,
    this.overlay,
    this.alignment = Alignment.center,
  });

  @override
  State<StatefulWidget> createState() => _BlurWidgetState();
}

/// The blur widget state.
class _BlurWidgetState extends State<BlurWidget> with BrightnessListener {
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        child: Stack(
          children: [
            if (widget.below != null) widget.below!,
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
                child: Container(
                  decoration: BoxDecoration(
                    color: (currentBrightness == Brightness.light ? Colors.white : Colors.black).withValues(alpha: widget.colorOpacity),
                  ),
                  alignment: widget.alignment,
                  child: widget.overlay,
                ),
              ),
            ),
            if (widget.above != null) widget.above!,
          ],
        ),
      );
}
