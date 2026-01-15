import 'package:flutter/material.dart';

/// The widget to use in decorations.
class FormLabelWithIcon extends StatelessWidget {
  /// The text.
  final String text;

  /// The icon.
  final IconData icon;

  /// Creates a new label widget instance.
  const FormLabelWithIcon({super.key,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2, right: 6),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 12,
          ),
        ),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    ),
  );
}
