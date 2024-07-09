import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_authenticator/model/settings/cache_totp_pictures.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/widgets/smart_image.dart';
import 'package:open_authenticator/widgets/totp/time_based.dart';

/// Displays a TOTP image.
class TotpImageWidget extends StatefulWidget {
  /// The TOTP UUID.
  final String? uuid;

  /// The TOTP image URL.
  final String? imageUrl;

  /// The TOTP label.
  final String? label;

  /// The TOTP issuer.
  final String? issuer;

  /// The size.
  final double size;

  /// Creates a new TOTP image widget instance.
  const TotpImageWidget({
    super.key,
    this.uuid,
    this.imageUrl,
    required this.label,
    this.issuer,
    this.size = 100,
  });

  /// Creates a new TOTP image widget instance from a TOTP instance.
  TotpImageWidget.fromTotp({
    Key? key,
    required Totp totp,
    double size = 100,
  }) : this(
          key: key,
          uuid: totp.uuid,
          imageUrl: totp.isDecrypted ? (totp as DecryptedTotp).imageUrl : null,
          label: totp.isDecrypted ? (totp as DecryptedTotp).label : null,
          issuer: totp.isDecrypted ? (totp as DecryptedTotp).issuer : null,
          size: size,
        );

  /// Returns a seeded random color that corresponds to the [issuer] and the [label].
  Color get _filterColor {
    if ((label == null || label!.isEmpty) && (issuer == null || issuer!.isEmpty)) {
      return Colors.transparent;
    }
    Random random = Random(label.hashCode + (issuer ?? '').hashCode);
    return Colors.primaries[random.nextInt(Colors.primaries.length)];
  }

  @override
  State<StatefulWidget> createState() => _TotpImageWidgetState();
}

/// The TOTP image widget state.
class _TotpImageWidgetState extends State<TotpImageWidget> {
  /// Whether the cached image has been loaded.
  bool cachedImageLoaded = false;

  /// The cached image file.
  File? cachedImageFile;

  @override
  void initState() {
    super.initState();
    _loadCachedImageIfPossible();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (widget.imageUrl == null || !cachedImageLoaded) {
      child = ColorFiltered(
        colorFilter: ColorFilter.mode(
          widget._filterColor,
          BlendMode.color,
        ),
        child: SvgPicture.asset(
          'assets/images/logo.svg',
          height: widget.size,
          width: widget.size,
          fit: BoxFit.contain,
        ),
      );
    } else {
      child = SmartImageWidget(
        source: widget.imageUrl!,
        height: widget.size,
        width: widget.size,
        fit: BoxFit.contain,
        cachedImage: cachedImageFile,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.size),
      child: SizedBox.square(
        dimension: widget.size,
        child: child,
      ),
    );
  }

  /// Loads the cached image if possible.
  Future<void> _loadCachedImageIfPossible() async {
    File? cached;
    if (widget.uuid != null && widget.imageUrl != null) {
      cached = await TotpImageCache.getTotpCachedImage(widget.uuid!);
      if (!cached.existsSync()) {
        cached = null;
      }
    }
    if (mounted) {
      setState(() {
        cachedImageLoaded = true;
        cachedImageFile = cached;
      });
    }
  }
}

/// Displays the TOTP image with a countdown.
class TotpCountdownImageWidget extends TimeBasedTotpWidget {
  /// The circle size.
  final double size;

  /// The progress color.
  final MaterialColor progressColor;

  /// Creates a new TOTP countdown image widget instance.
  const TotpCountdownImageWidget({
    super.key,
    required super.totp,
    this.size = 30,
    this.progressColor = Colors.green,
  });

  @override
  State<TimeBasedTotpWidget> createState() => _TotpCountdownImageWidgetState();
}

/// The TOTP countdown image widget state.
class _TotpCountdownImageWidgetState extends TimeBasedTotpWidgetState<TotpCountdownImageWidget> with TickerProviderStateMixin {
  /// The progress indicator color.
  late Color color = widget.progressColor.shade700;

  /// The progress indicator background color.
  late Color backgroundColor = widget.progressColor.shade100;

  /// The animation controller.
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    if (((DateTime.now().millisecondsSinceEpoch ~/ 1000) ~/ this.validity).isEven) {
      changeColors();
    }
    scheduleAnimation();
  }

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: widget.size,
        child: Stack(
          children: [
            Positioned.fill(
              child: TotpImageWidget.fromTotp(
                totp: widget.totp,
              ),
            ),
            Positioned.fill(
              child: CircularProgressIndicator(
                value: animationController.value / validity,
                color: color,
                backgroundColor: backgroundColor,
              ),
            ),
          ],
        ),
      );

  @override
  void didUpdateWidget(covariant TotpCountdownImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totp.validity != widget.totp.validity) {
      cancelAnimation();
      scheduleAnimation();
    }
  }

  @override
  void dispose() {
    cancelAnimation();
    super.dispose();
  }

  @override
  void updateState({bool changeColors = true}) {
    if (mounted) {
      animationController.duration = _validity;
      animationController.forward(from: 0);
      setState(() {
        if (changeColors) {
          this.changeColors();
        }
      });
    }
  }

  /// Schedule the animation.
  void scheduleAnimation() {
    Duration validity = _validity;
    animationController = AnimationController(
      vsync: this,
      duration: validity,
      upperBound: this.validity.toDouble(),
    )
      ..addListener(() {
        setState(() {});
      })
      ..forward(from: (validity - calculateExpirationDuration()).inMilliseconds / 1000);
  }

  /// Cancels the animation.
  void cancelAnimation() {
    animationController.dispose();
  }

  /// Changes the colors.
  void changeColors() {
    Color? temporary = color;
    color = backgroundColor;
    backgroundColor = temporary;
  }

  /// Returns the TOTP validity.
  Duration get _validity => Duration(seconds: validity);
}
