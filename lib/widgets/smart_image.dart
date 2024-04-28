import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Displays a classic image or a vector image.
class SmartImageWidget extends StatelessWidget {
  /// The image source.
  final String source;

  /// The width.
  final double? width;

  /// The height.
  final double? height;

  /// How to fit images.
  final BoxFit fit;

  /// The error widget builder.
  final ImageErrorWidgetBuilder? errorBuilder;

  /// The cached image.
  final File? cachedImage;

  /// Creates a new smart image widget instance.
  const SmartImageWidget({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.scaleDown,
    this.errorBuilder,
    this.cachedImage,
  });

  @override
  Widget build(BuildContext context) {
    if (cachedImage != null) {
      return source.endsWith('.svg')
          ? SvgPicture.file(
              cachedImage!,
              width: width,
              height: height,
              fit: fit,
            )
          : Image.file(
              cachedImage!,
              width: width,
              height: height,
              cacheWidth: width?.ceil(),
              cacheHeight: height?.ceil(),
              fit: fit,
              errorBuilder: errorBuilder,
            );
    }
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return source.endsWith('.svg')
          ? SvgPicture.network(
              source,
              width: width,
              height: height,
              fit: fit,
            )
          : Image.network(
              source,
              width: width,
              height: height,
              cacheWidth: width?.ceil(),
              cacheHeight: height?.ceil(),
              fit: fit,
              errorBuilder: errorBuilder,
            );
    }
    return source.endsWith('.svg')
        ? SvgPicture.asset(
            source,
            width: width,
            height: height,
            fit: fit,
          )
        : Image.asset(
            source,
            width: width,
            height: height,
            cacheWidth: width?.ceil(),
            cacheHeight: height?.ceil(),
            fit: fit,
            errorBuilder: errorBuilder,
          );
  }
}
