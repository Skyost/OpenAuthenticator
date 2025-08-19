import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/utils/brightness_listener.dart';

/// A list tile that allows to expand its content by tapping on it.
class ExpandListTile extends ConsumerStatefulWidget {
  /// The tile title.
  final Widget title;

  /// The expanded children.
  final List<Widget> children;

  /// Whether the tile is enabled.
  final bool enabled;

  /// The icon color.
  final Color? iconColor;

  /// Creates a new expand list tile instance.
  const ExpandListTile({
    super.key,
    required this.title,
    this.children = const [],
    this.enabled = true,
    this.iconColor,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExpandListTileState();
}

/// The expand list tile instance.
class _ExpandListTileState extends ConsumerState<ExpandListTile> with SingleTickerProviderStateMixin, BrightnessListener {
  /// The expand controller.
  late AnimationController expandController;

  /// The expand animation.
  late Animation<double> expandAnimation;

  /// Whether the content is expanded.
  bool expand = false;

  @override
  void initState() {
    super.initState();
    expandController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    expandAnimation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            iconColor: Theme.of(context).colorScheme.primary,
            title: widget.title,
            onTap: () {
              bool willExpand = !expand;
              setState(() => expand = willExpand);
              if (willExpand) {
                expandController.forward();
              } else {
                expandController.reverse();
              }
            },
            trailing: AnimatedRotation(
              turns: expand ? 0.25 : 0,
              duration: const Duration(milliseconds: 100),
              child: Icon(
                Icons.chevron_right,
                color: widget.iconColor ?? (currentBrightness == Brightness.light ? null : Colors.white),
              ),
            ),
            enabled: widget.enabled,
          ),
          SizeTransition(
            axisAlignment: 1.0,
            sizeFactor: expandAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.children,
            ),
          ),
          // for (Widget child in widget.children)
          //   SizeTransition(
          //     axisAlignment: 1.0,
          //     sizeFactor: expandAnimation,
          //     child: child,
          //   ),
        ],
      );

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }
}
