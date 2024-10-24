import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:open_authenticator/utils/image_type.dart';
import 'package:open_authenticator/utils/jovial_svg.dart';

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
      return imageType == ImageType.other
          ? Image.network(
              source,
              key: imageKey,
              width: width,
              height: height,
              cacheWidth: width?.ceil(),
              cacheHeight: height?.ceil(),
              fit: fit,
              errorBuilder: errorBuilder,
            )
          : SizedBox(
              width: width,
              height: height,
              child: ScalableImageWidget.fromSISource(
                si: ScalableImageSource.fromSvgHttpUrl(Uri.parse(source)),
                key: imageKey,
                fit: fit,
              ),
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
            si: ScalableImageSource.fromSvgFile(file, () => file.readAsString()),
            key: imageKey,
            fit: fit,
          ),
        ),
      ImageType.si => SizedBox(
          width: width,
          height: height,
          child: ScalableImageWidget.fromSISource(
            si: SIFileSource(file: file),
            key: imageKey,
            fit: fit,
          ),
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
