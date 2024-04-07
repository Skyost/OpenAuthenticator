import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_authenticator/model/totp/repository.dart';
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
  final String label;

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
          imageUrl: totp.imageUrl,
          label: totp.label,
          issuer: totp.issuer,
          size: size,
        );

  /// Returns a seeded random color that corresponds to the [issuer] and the [label].
  Color get _filterColor {
    if (label.isEmpty && (issuer == null || issuer!.isEmpty)) {
      return Colors.transparent;
    }
    Random random = Random((label ?? '').hashCode + (issuer ?? '').hashCode);
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
      child: child,
    );
  }

  /// Loads the cached image if possible.
  Future<void> _loadCachedImageIfPossible() async {
    File? cached;
    if (widget.uuid != null) {
      cached = await TotpRepository.getTotpCachedImage(widget.uuid!);
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
class _TotpCountdownImageWidgetState extends TimeBasedTotpWidgetState<TotpCountdownImageWidget> {
  /// The progress indicator color.
  late Color color = widget.progressColor.shade700;

  /// The progress indicator background color.
  late Color backgroundColor = widget.progressColor.shade100;

  /// The currently remaining validity time.
  late int currentRemainingValidity = remainingValidity;

  /// The timer that allows this widget to refresh every second.
  late Timer refreshTimer;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    DateTime target = DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second).add(const Duration(seconds: 1));
    refreshTimer = Timer(target.difference(now), () {
      updateState(changeColors: false);
      refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) => updateState(changeColors: false));
    });
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: widget.size,
        width: widget.size,
        child: Stack(
          children: [
            Positioned.fill(
              child: TotpImageWidget.fromTotp(
                totp: widget.totp,
              ),
            ),
            Positioned.fill(
              child: CircularProgressIndicator(
                value: 1 - remainingValidity / validity,
                color: color,
                backgroundColor: backgroundColor,
              ),
            ),
          ],
        ),
      );

  @override
  void dispose() {
    refreshTimer.cancel();
    super.dispose();
  }

  @override
  void updateState({bool changeColors = true}) {
    if (mounted) {
      setState(() {
        currentRemainingValidity = remainingValidity;
        if (changeColors) {
          Color? temporary = color;
          color = backgroundColor;
          backgroundColor = temporary;
        }
      });
    }
  }

  int get remainingValidity => validity - calculateExpirationDuration().inSeconds;
}
