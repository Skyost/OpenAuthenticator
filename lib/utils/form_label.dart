import 'package:flutter/material.dart';

/// A form label with a nice icon.
class FormLabelWithIcon extends InputDecoration {
  /// Creates a new form label with icon instance.
  FormLabelWithIcon({
    required String text,
    required IconData icon,
    super.hintText,
    super.suffixIcon,
  }) : super(
          floatingLabelBehavior: hintText == null ? FloatingLabelBehavior.auto : FloatingLabelBehavior.always,
          label: _LabelWidget(
            text: text,
            icon: icon,
          ),
        );
}

/// The widget to use in decorations.
class _LabelWidget extends StatelessWidget {
  /// The text.
  final String text;

  /// The icon.
  final IconData icon;

  /// Creates a new label widget instance.
  const _LabelWidget({
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
            Text(text),
          ],
        ),
  );
}
