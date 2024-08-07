import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Displays a classic image or a vector image.
class SmartImageWidget extends StatelessWidget {
  /// The image key.
  /// Useful when [imageCache] should not be taken into account.
  final Key? imageKey;

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

  /// The image type.
  final ImageType imageType;

  /// Creates a new smart image widget instance.
  SmartImageWidget({
    super.key,
    this.imageKey,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.scaleDown,
    this.errorBuilder,
    ImageType? imageType,
    bool? autoDetectImageType,
  }) : imageType = ((autoDetectImageType ?? imageType == null) ? (source.endsWith('.svg') ? ImageType.svg : ImageType.other) : imageType!);

  @override
  Widget build(BuildContext context) {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return imageType == ImageType.svg
          ? SvgPicture.network(
              source,
              key: imageKey,
              width: width,
              height: height,
              fit: fit,
            )
          : Image.network(
              source,
              key: imageKey,
              width: width,
              height: height,
              cacheWidth: width?.ceil(),
              cacheHeight: height?.ceil(),
              fit: fit,
              errorBuilder: errorBuilder,
            );
    }
    File file = File(source);
    if (!file.existsSync()) {
      return const SizedBox.shrink();
    }
    return imageType == ImageType.svg
        ? SvgPicture.file(
            file,
            key: imageKey,
            width: width,
            height: height,
            fit: fit,
          )
        : Image.file(
            file,
            key: imageKey,
            width: width,
            height: height,
            cacheWidth: width?.ceil(),
            cacheHeight: height?.ceil(),
            fit: fit,
            errorBuilder: errorBuilder,
          );
  }
}

/// The image type.
enum ImageType {
  /// "SVG" type.
  svg,

  /// Any other image.
  other;
}
