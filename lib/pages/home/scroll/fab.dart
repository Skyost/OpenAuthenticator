import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:open_authenticator/utils/platform.dart';

/// A widget that triggers a callback when the user scrolls, so that the floating action button can be hidden or shown.
class RevealFloatingActionButtonWidget extends StatelessWidget {
  /// Whether to display the floating action button initially.
  static final bool hasFloatingActionButton = currentPlatform == Platform.android || kDebugMode;

  /// Called when the user scrolls up.
  final VoidCallback? onHideFloatingActionButton;

  /// Called when the user scrolls down.
  final VoidCallback? onShowFloatingActionButton;

  /// The child widget.
  final Widget child;

  /// Creates a new reveal floating action button widget instance.
  const RevealFloatingActionButtonWidget({
    super.key,
    this.onHideFloatingActionButton,
    this.onShowFloatingActionButton,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => hasFloatingActionButton
      ? NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.maxScrollExtent != notification.metrics.minScrollExtent) {
              ScrollDirection direction = notification.direction;
              if (direction == ScrollDirection.reverse) {
                onHideFloatingActionButton?.call();
              } else if (direction == ScrollDirection.forward) {
                onShowFloatingActionButton?.call();
              }
            }
            return false;
          },
          child: child,
        )
      : child;
}
