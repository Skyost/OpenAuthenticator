import 'package:flutter/material.dart';
import 'package:open_authenticator/app.dart';

/// The title widget with a nice green color.
class TitleWidget extends StatelessWidget {
  /// The text align.
  final TextAlign? textAlign;

  /// The text style.
  final TextStyle? textStyle;

  /// Creates a new title widget instance.
  const TitleWidget({
    super.key,
    this.textAlign,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    List<String> parts = App.appName.split(' ');
    return Text.rich(
      TextSpan(
        children: [
          if (parts.length == 1) _createGradientText(parts.first),
          if (parts.length > 1) ...[
            TextSpan(
              text: '${parts.first} ',
            ),
            _createGradientText(parts[1]),
            for (int i = 2; i < parts.length; i++)
              TextSpan(
                text: ' ${parts[i]}',
              ),
          ],
        ],
      ),
      style: textStyle,
      textAlign: textAlign,
    );
  }

  /// Creates a text with a gradient.
  WidgetSpan _createGradientText(String text) => WidgetSpan(
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(colors: [
            Colors.green.shade300,
            Colors.green.shade400,
            Colors.green.shade500,
            Colors.green.shade500,
            Colors.green.shade600,
            Colors.green.shade800,
          ], stops: const [
            0,
            0.021,
            0.293,
            0.554,
            0.796,
            1,
          ]).createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: Text(
            text,
            style: (textStyle ?? const TextStyle()).copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      );
}
