import 'package:flutter/material.dart';

/// Shows a nice looking SnackBar with an icon.
class SnackBarIcon extends StatelessWidget {
  /// The inner padding.
  final EdgeInsets padding;

  /// The border radius.
  final BorderRadius borderRadius;

  /// The background color.
  final MaterialColor background;

  /// The text style.
  final TextStyle? textStyle;

  /// The text to show.
  final String text;

  /// The icon size.
  final double iconSize;

  /// The icon to display.
  final IconData icon;

  /// Creates a new scaffold icon instance.
  SnackBarIcon({
    super.key,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    BorderRadius? borderRadius,
    this.background = Colors.green,
    this.textStyle = const TextStyle(color: Colors.white),
    required this.text,
    this.iconSize = 20,
    this.icon = Icons.check,
  }) : borderRadius = borderRadius ?? BorderRadius.circular(5);

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: background,
      borderRadius: borderRadius,
    ),
    padding: padding,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -padding.top - (iconSize + 10) / 2,
          left: -padding.left - (iconSize + 10) / 2,
          child: Icon(
            Icons.circle,
            color: background.shade900,
            size: iconSize + 10,
          ),
        ),
        Positioned(
          top: -padding.top - iconSize / 2,
          left: -padding.left - iconSize / 2,
          child: Icon(
            icon,
            color: Colors.white,
            size: iconSize,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: textStyle,
              ),
            ),
            IconButton(
              onPressed: ScaffoldMessenger.of(context).hideCurrentSnackBar,
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  /// Creates the SnackBar and shows it.
  static void showSuccessSnackBar(BuildContext context, {required String text}) => _showSnackBar(
    context,
    background: Colors.green,
    textStyle: const TextStyle(color: Colors.white),
    text: text,
    icon: Icons.check,
  );

  /// Creates the SnackBar and shows it.
  static void showErrorSnackBar(BuildContext context, {required String text}) => _showSnackBar(
    context,
    background: Colors.red,
    textStyle: const TextStyle(color: Colors.white),
    text: text,
    icon: Icons.priority_high,
  );

  /// Creates the SnackBar and shows it.
  static void _showSnackBar(
    BuildContext context, {
    required MaterialColor background,
    required String text,
    required TextStyle textStyle,
    required IconData icon,
  }) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: SnackBarIcon(
        background: background,
        text: text,
        textStyle: textStyle,
        icon: icon,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}
