import 'package:flutter/material.dart';

/// A widget that gives the same padding as a [ListTile].
class ListTilePadding extends StatelessWidget {
  /// The top padding.
  final double top;

  /// The bottom padding.
  final double bottom;

  /// The child.
  final Widget child;

  /// Creates a new list tile padding instance.
  const ListTilePadding({
    super.key,
    this.top = 0,
    this.bottom = 0,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(
          top: top,
          right: 16,
          bottom: bottom,
          left: 16,
        ),
        child: child,
      );
}
