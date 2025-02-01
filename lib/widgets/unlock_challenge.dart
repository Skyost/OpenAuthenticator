import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/app_unlock/method.dart';
import 'package:open_authenticator/model/app_unlock/state.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/blur.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';
import 'package:open_authenticator/widgets/title.dart';

/// The unlock challenge widget.
class UnlockChallengeWidget extends ConsumerStatefulWidget {
  /// The child widget.
  final Widget child;

  /// Creates a new unlock challenge widget instance.
  const UnlockChallengeWidget({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UnlockChallengeWidgetState();
}

/// The master password unlock route widget state.
class _UnlockChallengeWidgetState extends ConsumerState<UnlockChallengeWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tryUnlockIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<AppLockState> appLockState = ref.watch(appLockStateProvider);
    return switch (appLockState) {
      AsyncData<AppLockState>(:final value) => value == AppLockState.unlocked
          ? widget.child
          : Scaffold(
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
                      Center(
                        child: SizedBox(
                          width: math.min(MediaQuery.of(context).size.width - 20, 300),
                          child: FilledButton.icon(
                            onPressed: value == AppLockState.unlockChallengedStarted ? null : tryUnlockIfNeeded,
                            label: Text(translations.appUnlock.widget.button),
                            icon: const Icon(Icons.key),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                below: widget.child,
              ),
            ),
      _ => widget.child,
    };
  }

  /// Tries to unlock the app.
  Future<void> tryUnlockIfNeeded() async {
    AppLockState lockState = await ref.read(appLockStateProvider.future);
    if (!mounted || lockState != AppLockState.locked) {
      return;
    }
    Result result = await ref.read(appLockStateProvider.notifier).unlock(context);
    if (result is ResultError && mounted) {
      SnackBarIcon.showErrorSnackBar(context, text: translations.error.appUnlock);
    }
  }
}
