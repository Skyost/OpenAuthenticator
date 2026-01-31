import 'dart:math' as math;

import 'package:flutter/material.dart';

class RotationAnimationWidget extends StatefulWidget {
  final Widget child;

  final Duration duration;

  const RotationAnimationWidget({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<RotationAnimationWidget> createState() => _RotationAnimationWidgetState();
}

class _RotationAnimationWidgetState extends State<RotationAnimationWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (context, child) => Transform.rotate(
      angle: -_controller.value * 2.0 * math.pi,
      child: child,
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
