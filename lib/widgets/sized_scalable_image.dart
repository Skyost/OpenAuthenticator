import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:jovial_svg/src/compact.dart';

/// A sized scalable image widget.
class SizedScalableImageWidget extends StatelessWidget {
  /// The width.
  final double? width;

  /// The height.
  final double? height;

  /// The fit parameter to pass to the SVG widget.
  final BoxFit fit;

  /// The padding.
  final EdgeInsetsGeometry? padding;

  /// The asset path.
  final String asset;

  /// The alignment.
  final Alignment alignment;

  /// Whether to put the image widget inside of a container (if both [width] / [height] & [padding] are specified).
  final bool useContainer;

  /// Creates a new sized scalable image widget instance.
  const SizedScalableImageWidget({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.padding,
    required this.asset,
    this.alignment = Alignment.center,
    this.useContainer = false,
  });

  @override
  Widget build(BuildContext context) {
    File file = File(asset);
    Widget child = ScalableImageWidget.fromSISource(
      si: file.existsSync()
          ? _SIFileSource(file, null)
          : ScalableImageSource.fromSI(
              rootBundle,
              asset,
            ),
      fit: fit,
      alignment: alignment,
    );
    if (useContainer) {
      if ((width != null || height != null) && padding != null) {
        child = Container(
          width: width,
          height: height,
          padding: padding,
          child: child,
        );
      }
    } else {
      if (width != null || height != null) {
        child = SizedBox(
          width: width,
          height: height,
          child: child,
        );
      }
      if (padding != null) {
        child = Padding(
          padding: padding!,
          child: child,
        );
      }
    }
    return child;
  }
}

class _SIFileSource extends ScalableImageSource {
  final File file;
  final Color? currentColor;

  _SIFileSource(this.file, this.currentColor);

  @override
  Future<ScalableImage> get si => createSI();

  @override
  Future<ScalableImage> createSI({bool compact = false}) async {
    ScalableImageCompact scalableImageCompact = ScalableImageCompact.fromBytes(file.readAsBytesSync(), currentColor: currentColor);
    if (compact) {
      return scalableImageCompact;
    } else {
      return scalableImageCompact.toDag();
    }
  }

  @override
  bool operator ==(final Object other) {
    if (other is _SIFileSource) {
      return file == other.file && currentColor == other.currentColor;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => 0xf67cd716 ^ Object.hash(file, currentColor);

  @override
  String toString() => '__SIFileSource($file $currentColor)';
}
