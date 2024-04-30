import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/app_unlock/state.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/route/locked.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';

/// A route that is locked waiting for the user to solve the unlock challenge.
class UnlockChallengeRouteWidget extends ConsumerStatefulWidget {
  /// The route widget.
  final Widget child;

  /// Creates a new unlock challenge route widget instance.
  const UnlockChallengeRouteWidget({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UnlockChallengeRouteWidgetState();
}

/// The master password unlock route widget state.
class _UnlockChallengeRouteWidgetState extends ConsumerState<UnlockChallengeRouteWidget> {
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
  Widget build(BuildContext context) {
    AsyncValue<bool> isUnlocked = ref.watch(appUnlockStateProvider);
    return switch (isUnlocked) {
      AsyncData(:bool value) => _createRouteWidget(value),
      AsyncError() => widget.child,
      _ => unlockChallengedStarted ? _createRouteWidget() : const CenteredCircularProgressIndicator(),
    };
  }

  /// Creates the route widget.
  Widget _createRouteWidget([bool isUnlocked = false]) => LockedRouteWidget(
    isLocked: !isUnlocked,
    onUnlockButtonClicked: tryUnlockIfNeeded,
    child: widget.child,
  );

  /// Tries to unlock the app.
  Future<void> tryUnlockIfNeeded() async {
    bool isUnlocked = await ref.watch(appUnlockStateProvider.future);
    if (isUnlocked || !mounted) {
      return;
    }
    setState(() => unlockChallengedStarted = true);
    Result result = await ref.read(appUnlockStateProvider.notifier).unlock(context);
    if (mounted) {
      setState(() => unlockChallengedStarted = false);
      if (result is ResultError) {
        SnackBarIcon.showErrorSnackBar(context, text: translations.error.appUnlock);
      }
    }
  }
}
