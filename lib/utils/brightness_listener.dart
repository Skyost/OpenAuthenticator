import 'package:flutter/material.dart';

/// Allows to listen to the platform's brightness.
mixin BrightnessListener<T extends StatefulWidget> on State<T> {
  /// The current brightness.
  Brightness currentBrightness = Brightness.light;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Brightness brightness = MediaQuery.of(context).platformBrightness;
    if (mounted) {
      setState(() => currentBrightness = brightness);
    } else {
      currentBrightness = brightness;
    }
  }
}