import 'package:flutter/material.dart';

/// A widget that gives the same padding as a [ListTile].
class ListTilePadding extends StatelessWidget {
  /// The child.
  final Widget child;

  /// Creates a new list tile padding instance.
  const ListTilePadding({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: child,
  );
}
