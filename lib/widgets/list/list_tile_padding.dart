import 'package:flutter/material.dart';

/// A widget that gives the same padding as a [ListTile].
class ListTilePadding extends StatelessWidget {
  /// The top padding.
  final double? top;

  /// The bottom padding.
  final double? bottom;

  /// The child.
  final Widget child;

  /// Creates a new list tile padding instance.
  const ListTilePadding({
    super.key,
    this.top,
    this.bottom,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: (Theme.of(context).listTileTheme.contentPadding?.resolve(Directionality.of(context)) ?? const EdgeInsets.symmetric(horizontal: 16)).copyWith(
      top: top,
      bottom: bottom,
    ),
    child: child,
  );
}
