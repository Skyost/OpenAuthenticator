import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/app_unlock/method.dart';
import 'package:open_authenticator/model/app_unlock/state.dart';
import 'package:open_authenticator/model/password_verification/methods/method.dart';
import 'package:open_authenticator/model/password_verification/password_verification.dart';
import 'package:open_authenticator/model/settings/app_unlock_method.dart';
import 'package:open_authenticator/utils/master_password.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/app_filled_button.dart';
import 'package:open_authenticator/widgets/blur.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';
import 'package:open_authenticator/widgets/list/list_tile_padding.dart';
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
  /// Will be non-null if the app cannot be unlocked for a specific reason.
  CannotUnlockException? cannotUnlockException;

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
    switch (appLockState) {
      case AsyncData<AppLockState>(:final value):
        if (value == AppLockState.unlocked) {
          return widget.child;
        }
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: BlurWidget(
            above: switch (cannotUnlockException) {
              LocalAuthenticationDeviceNotSupported() => _UnlockChallengeWidgetContent(
                  text: translations.appUnlock.cannotUnlock.localAuthentication.deviceNotSupported,
                  buttonIcon: Icons.close,
                  buttonLabel: translations.appUnlock.cannotUnlock.localAuthentication.button,
                  onButtonPressed: () async {
                    List<PasswordVerificationMethod> passwordVerificationMethod = await ref.read(passwordVerificationProvider.future);
                    if (passwordVerificationMethod.isNotEmpty) {
                      String? password = context.mounted ? (await MasterPasswordInputDialog.prompt(context)) : null;
                      if (password == null) {
                        return;
                      }
                    }
                    await ref.read(appUnlockMethodSettingsEntryProvider.notifier).changeValue(NoneAppUnlockMethod());
                    await tryUnlockIfNeeded();
                  },
                ),
              MasterPasswordNoPasswordVerificationMethodAvailable() || MasterPasswordNoSalt() => _UnlockChallengeWidgetContent(
                  text: translations.appUnlock.cannotUnlock.masterPassword.noPasswordVerificationMethodAvailable,
                  buttonIcon: Icons.key,
                  buttonLabel: translations.appUnlock.cannotUnlock.masterPassword.button,
                  onButtonPressed: () async {
                    Result<String> changeResult = await MasterPasswordUtils.changeMasterPassword(context, ref, askForUnlock: false);
                    if (changeResult is ResultSuccess<String>) {
                      await ref.read(appUnlockMethodSettingsEntryProvider.notifier).changeValue(
                            NoneAppUnlockMethod(),
                            disableResult: changeResult,
                          );
                      await tryUnlockIfNeeded();
                    }
                  },
                ),
              _ => _UnlockChallengeWidgetContent(
                  text: translations.appUnlock.widget.text(app: App.appName),
                  buttonIcon: Icons.key,
                  buttonLabel: translations.appUnlock.widget.button,
                  onButtonPressed: value == AppLockState.unlockChallengedStarted ? null : tryUnlockIfNeeded,
                ),
            },
            below: widget.child,
          ),
        );
      default:
        return widget.child;
    }
  }

  /// Tries to unlock the app.
  Future<void> tryUnlockIfNeeded() async {
    AppLockState lockState = await ref.read(appLockStateProvider.future);
    if (!mounted || lockState != AppLockState.locked) {
      return;
    }
    Result result = await ref.read(appLockStateProvider.notifier).unlock(context);
    if (!mounted || result is! ResultError) {
      return;
    }
    if (result.exception is CannotUnlockException) {
      setState(() => cannotUnlockException = result.exception as CannotUnlockException);
    } else if (mounted) {
      SnackBarIcon.showErrorSnackBar(context, text: translations.error.appUnlock);
    }
  }
}

/// The content of [UnlockChallengeWidget].
class _UnlockChallengeWidgetContent extends StatelessWidget {
  /// The text to display.
  final String text;

  /// The action button label.
  final String buttonLabel;

  /// The action button icon.
  final IconData? buttonIcon;

  /// Triggered when the action button has been pressed.
  final VoidCallback? onButtonPressed;

  /// Creates a new unlock challenge widget content instance.
  const _UnlockChallengeWidgetContent({
    required this.text,
    required this.buttonLabel,
    this.buttonIcon,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTilePadding(
              bottom: 20,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: TitleWidget(
                  textAlign: TextAlign.center,
                  textStyle: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ),
            ListTilePadding(
              bottom: 20,
              child: Text(
                text,
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: SizedBox(
                width: math.min(MediaQuery.sizeOf(context).width - 20, 300),
                child: AppFilledButton(
                  onPressed: onButtonPressed,
                  label: Text(buttonLabel),
                  icon: buttonIcon == null ? null : Icon(buttonIcon),
                ),
              ),
            ),
          ],
        ),
      );
}
