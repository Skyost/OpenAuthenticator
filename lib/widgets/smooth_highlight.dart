import 'package:flutter/material.dart';

/// Huge thanks to `smooth_highlight` library for this.
class SmoothHighlight extends StatefulWidget {
  /// Highlight target widget.
  /// If child has no size, nothing happens.
  final Widget child;

  /// The highlight color.
  /// If [enabled] is false, this color is not used.
  final Color color;

  /// Whether this highlight is enabled.
  /// If false, the child does not be highlight at all. default to true.
  /// Ex. `enabled: count % 2 ==0` means that highlight if count is only even.
  final bool enabled;

  /// Whether this highlight works also in initState phase.
  /// If true, the highlight will be applied to the child in initState phase. default to false.
  final bool useInitialHighLight;

  /// The padding of the highlight.
  final EdgeInsets padding;

  /// Triggered when the highlight has been finished.
  final VoidCallback? onHighlightFinished;

  /// Creates a new smooth highlight widget instance.
  const SmoothHighlight({
    super.key,
    required this.child,
    required this.color,
    this.enabled = true,
    this.useInitialHighLight = false,
    this.padding = EdgeInsets.zero,
    this.onHighlightFinished,
  });

  @override
  State<SmoothHighlight> createState() => _SmoothHighlightState();
}

/// The smooth highlight wiget state.
class _SmoothHighlightState extends State<SmoothHighlight> with SingleTickerProviderStateMixin {
  /// Whether the widget has been disposed.
  bool disposed = false;

  /// The animation controller.
  late final animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  /// The animation.
  late final Animation<Decoration> animation = animationController
      .drive(
        CurveTween(curve: Curves.easeInOut),
      )
      .drive(
        DecorationTween(
          begin: const BoxDecoration(),
          end: BoxDecoration(
            color: widget.color,
          ),
        ),
      );

  @override
  void initState() {
    super.initState();
    if (widget.useInitialHighLight) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        animationController.forward();
      });
    }
    animation.addStatusListener((status) async {
      switch (status) {
        case AnimationStatus.dismissed:
          if (mounted) {
            widget.onHighlightFinished?.call();
          }
          break;
        case AnimationStatus.completed:
          await Future.delayed(const Duration(milliseconds: 200));
          // this is workaround for following error occurs if you use in ListView scroll :
          // `called after AnimationController.dispose() AnimationController methods should not be used after calling dispose.`
          if (!disposed) {
            await animationController.reverse();
          }
          break;
        default:
          break;
      }
    });
  }

  @override
  void didUpdateWidget(covariant SmoothHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled) {
      animationController.forward();
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Padding(
      padding: widget.padding,
      child: widget.child,
    );
    return widget.enabled
        ? DecoratedBoxTransition(
            decoration: animation,
            child: child,
          )
        : child;
  }
}
