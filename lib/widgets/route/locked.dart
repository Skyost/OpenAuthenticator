import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/widgets/blur.dart';
import 'package:open_authenticator/widgets/title.dart';

/// A widget that allows to lock a route widget until the user completes a specified action.
class LockedRouteWidget extends StatelessWidget {
  /// The route widget.
  final Widget child;

  /// Whether the route is locked.
  final bool isLocked;

  /// Triggered when the user wants to unlock the app.
  final VoidCallback? onUnlockButtonClicked;

  /// Creates a new locked route widget instance.
  const LockedRouteWidget({
    super.key,
    required this.child,
    this.isLocked = false,
    this.onUnlockButtonClicked,
  });

  @override
  Widget build(BuildContext context) => isLocked
      ? Scaffold(
          body: BlurWidget(
            above: Center(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: TitleWidget(
                      textAlign: TextAlign.center,
                      textStyle: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      translations.appUnlock.widget.text(app: App.appName),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Align(
                    child: SizedBox(
                      width: math.min(MediaQuery.of(context).size.width, 300),
                      child: FilledButton.icon(
                        onPressed: onUnlockButtonClicked,
                        label: Text(translations.appUnlock.widget.button),
                        icon: const Icon(Icons.key),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            child: child,
          ),
        )
      : child;
}
