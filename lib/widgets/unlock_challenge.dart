import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/app_unlock/state.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/blur.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';
import 'package:open_authenticator/widgets/title.dart';

/// An overlay that is shown waiting for the user to solve the unlock challenge.
class UnlockChallengeOverlay {
  /// The current overlay entry, if inserted.
  static OverlayEntry? _currentEntry;

  /// Displays the unlock challenge overlay.
  static void display(BuildContext context) {
    if (_currentEntry != null) {
      return;
    }
    _currentEntry = OverlayEntry(
      builder: (context) => _UnlockChallengeOverlayWidget(
        onUnlock: () {
          _currentEntry?.remove();
          _currentEntry = null;
        },
      ),
    );
    Overlay.of(context).insert(_currentEntry!);
  }
}

/// The unlock challenge widget.
class _UnlockChallengeOverlayWidget extends ConsumerStatefulWidget {
  /// Triggered when unlocked.
  final VoidCallback? onUnlock;

  /// Creates a new unlock challenge route widget instance.
  const _UnlockChallengeOverlayWidget({
    this.onUnlock,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UnlockChallengeWidgetState();
}

/// The master password unlock route widget state.
class _UnlockChallengeWidgetState extends ConsumerState<_UnlockChallengeOverlayWidget> {
  /// Whether the unlock challenge has started.
  bool unlockChallengedStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      tryUnlockIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
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
                      onPressed: unlockChallengedStarted ? null : tryUnlockIfNeeded,
                      label: Text(translations.appUnlock.widget.button),
                      icon: const Icon(Icons.key),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  /// Tries to unlock the app.
  Future<void> tryUnlockIfNeeded() async {
    bool isUnlocked = await ref.read(appUnlockStateProvider.future);
    if (!mounted) {
      return;
    }
    if (isUnlocked) {
      widget.onUnlock?.call();
      return;
    }
    setState(() => unlockChallengedStarted = true);
    Result result = await ref.read(appUnlockStateProvider.notifier).unlock(context);
    if (!mounted) {
      return;
    }
    setState(() => unlockChallengedStarted = false);
    switch (result) {
      case ResultSuccess():
        widget.onUnlock?.call();
        break;
      case ResultError():
        SnackBarIcon.showErrorSnackBar(context, text: translations.error.appUnlock);
        break;
      default:
        break;
    }
  }
}
