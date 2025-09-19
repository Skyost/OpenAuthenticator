import 'package:flutter/material.dart';

/// A divider with a text in the middle.
class DividerText extends StatelessWidget {
  /// The left divider.
  final Widget leftDivider;

  /// The text.
  final Widget text;

  /// The right divider.
  final Widget rightDivider;

  /// Creates a new divider text instance.
  const DividerText({
    super.key,
    this.leftDivider = const Divider(),
    required this.text,
    this.rightDivider = const Divider(),
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: leftDivider),
      Padding(
        padding: const EdgeInsets.only(right: 10, bottom: 4, left: 10),
        child: text,
      ),
      Expanded(child: rightDivider),
    ],
  );
}
