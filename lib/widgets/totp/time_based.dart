import 'dart:async';

import 'package:flutter/material.dart';
import 'package:open_authenticator/model/totp/totp.dart';

/// A TOTP expiration time based widget.
abstract class TimeBasedTotpWidget extends StatefulWidget {
  /// The TOTP instance.
  final Totp totp;

  /// Creates a new time based TOTP widget instance.
  const TimeBasedTotpWidget({
    super.key,
    required this.totp,
  });

  @override
  State<TimeBasedTotpWidget> createState();
}

/// The time based TOTP widget state.
abstract class TimeBasedTotpWidgetState<T extends TimeBasedTotpWidget> extends State<T> {
  /// The update timer.
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _updateTimer = Timer(calculateExpirationDuration(), () {
      updateState();
      _updateTimer = Timer.periodic(Duration(seconds: validity), (_) => updateState());
    });
  }

  @override
  void dispose() {
    _cancelUpdates();
    super.dispose();
  }

  /// The validity.
  int get validity => widget.totp.validity ?? Totp.kDefaultValidity;

  /// Triggered when the state should be updated.
  void updateState();

  /// Cancels the updates.
  void _cancelUpdates() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  /// Calculates the expiration duration.
  Duration calculateExpirationDuration([DateTime? date]) {
    date ??= DateTime.now();
    return _calculateExpirationDate(date).difference(date);
  }

  /// Calculates the expiration date.
  DateTime _calculateExpirationDate(DateTime date) {
    int currentUnixTime = date.toUtc().millisecondsSinceEpoch ~/ 1000;
    int timeStepRemainder = currentUnixTime % validity;
    int expirationTime = currentUnixTime + (validity - timeStepRemainder);
    return DateTime.fromMillisecondsSinceEpoch(expirationTime * 1000);
  }
}
