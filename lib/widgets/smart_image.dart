import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:open_authenticator/widgets/sized_scalable_image.dart';

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
  }) : imageType = ((autoDetectImageType ?? imageType == null) ? ImageType.inferFromSource(source) : imageType!);

  @override
  Widget build(BuildContext context) {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return imageType == ImageType.svg
          ? SizedBox(
              width: width,
              height: height,
              child: ScalableImageWidget.fromSISource(
                si: ScalableImageSource.fromSvgHttpUrl(Uri.parse(source)),
                key: imageKey,
                fit: fit,
              ),
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
    return switch (imageType) {
      ImageType.svg => SizedBox(
        width: width,
        height: height,
        child: ScalableImageWidget.fromSISource(
          si: ScalableImageSource.fromSvg(rootBundle, source),
          key: imageKey,
          fit: fit,
        ),
      ),
      ImageType.si => SizedScalableImageWidget(
        width: width,
        height: height,
        asset: source,
        key: imageKey,
        fit: fit,
      ),
      ImageType.other => Image.file(
        file,
        key: imageKey,
        width: width,
        height: height,
        cacheWidth: width?.ceil(),
        cacheHeight: height?.ceil(),
        fit: fit,
        errorBuilder: errorBuilder,
      ),
    };
  }
}

/// The image type.
enum ImageType {
  /// "SVG" type.
  svg,

  /// "SI" type.
  si,

  /// Any other image.
  other;

  /// Infers an image type from the given [source].
  static ImageType inferFromSource(String source) {
    if (source.endsWith('.svg')) {
      return svg;
    }
    if (source.endsWith('.si')) {
      return si;
    }
    return other;
  }
}
