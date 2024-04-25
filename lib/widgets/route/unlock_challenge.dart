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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      tryUnlock();
    });
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<bool> isUnlocked = ref.watch(appUnlockStateProvider);
    return switch (isUnlocked) {
      AsyncData(:bool value) => LockedRouteWidget(
        isLocked: !value,
        onUnlockButtonClicked: tryUnlock,
        child: widget.child,
      ),
      AsyncError() => widget.child,
      _ => const CenteredCircularProgressIndicator(),
    };
  }

  /// Tries to unlock the app.
  Future<void> tryUnlock() async {
    Result result = await ref.read(appUnlockStateProvider.notifier).unlock(context);
    if (result is ResultError && mounted) {
      SnackBarIcon.showErrorSnackBar(context, text: translations.error.appUnlock);
    }
  }
}
