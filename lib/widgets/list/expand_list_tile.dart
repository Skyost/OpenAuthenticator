import 'package:flutter/material.dart';
import 'package:open_authenticator/utils/brightness_listener.dart';

/// A list tile that allows to expand its content by tapping on it.
class ExpandListTile extends StatefulWidget {
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
  State<StatefulWidget> createState() => _ExpandListTileState();
}

/// The expand list tile instance.
class _ExpandListTileState extends State<ExpandListTile> with BrightnessListener {
  /// Whether the content is expanded.
  bool expand = false;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            iconColor: Theme.of(context).primaryColor,
            title: widget.title,
            onTap: () {
              setState(() => expand = !expand);
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
          if (expand) ...widget.children,
        ],
      );
}
