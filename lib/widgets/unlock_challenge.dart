import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/app_unlock/methods/method.dart';
import 'package:open_authenticator/model/app_unlock/state.dart';
import 'package:open_authenticator/model/password_verification/methods/method.dart';
import 'package:open_authenticator/model/password_verification/password_verification.dart';
import 'package:open_authenticator/model/settings/app_unlock_method.dart';
import 'package:open_authenticator/spacing.dart';
import 'package:open_authenticator/utils/master_password.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/app_scaffold.dart';
import 'package:open_authenticator/widgets/blur.dart';
import 'package:open_authenticator/widgets/clickable.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';
import 'package:open_authenticator/widgets/title.dart';
import 'package:open_authenticator/widgets/toast.dart';

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
        return AppScaffold(
          scaffoldStyle: (scaffoldStyle) => scaffoldStyle.copyWith(
            backgroundColor: Colors.transparent,
          ),
          center: true,
          children: [
            BlurWidget(
              above: switch (cannotUnlockException) {
                LocalAuthenticationDeviceNotSupported() => _UnlockChallengeWidgetContent(
                  text: translations.appUnlock.cannotUnlock.localAuthentication.deviceNotSupported,
                  buttonIcon: FIcons.x,
                  buttonLabel: translations.appUnlock.cannotUnlock.localAuthentication.button,
                  onButtonPress: () async {
                    List<PasswordVerificationMethod> passwordVerificationMethod = await ref.read(passwordVerificationProvider.future);
                    if (passwordVerificationMethod.isNotEmpty) {
                      String? password = context.mounted ? (await MasterPasswordInputDialog.prompt(context)) : null;
                      if (password == null) {
                        return;
                      }
                    }
                    await ref.read(appUnlockMethodSettingsEntryProvider.notifier).changeValue(NoneAppUnlockMethod.kMethodId);
                    await tryUnlockIfNeeded();
                  },
                ),
                MasterPasswordNoPasswordVerificationMethodAvailable() || MasterPasswordNoSalt() => _UnlockChallengeWidgetContent(
                  text: translations.appUnlock.cannotUnlock.masterPassword.noPasswordVerificationMethodAvailable,
                  buttonIcon: FIcons.key,
                  buttonLabel: translations.appUnlock.cannotUnlock.masterPassword.button,
                  onButtonPress: () async {
                    Result<String> changeResult = await MasterPasswordUtils.changeMasterPassword(context, ref, askForUnlock: false);
                    if (changeResult is ResultSuccess<String>) {
                      await ref.read(appUnlockMethodSettingsEntryProvider.notifier).changeValue(NoneAppUnlockMethod.kMethodId, disableResult: changeResult);
                      await tryUnlockIfNeeded();
                    }
                  },
                ),
                _ => _UnlockChallengeWidgetContent(
                  text: translations.appUnlock.widget.text(app: App.appName),
                  buttonIcon: FIcons.key,
                  buttonLabel: translations.appUnlock.widget.button,
                  onButtonPress: value == AppLockState.unlockChallengedStarted ? null : tryUnlockIfNeeded,
                ),
              },
              below: widget.child,
            ),
          ],
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
      showErrorToast(context, text: translations.error.appUnlock);
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
  final VoidCallback? onButtonPress;

  /// Creates a new unlock challenge widget content instance.
  const _UnlockChallengeWidgetContent({
    required this.text,
    required this.buttonLabel,
    this.buttonIcon,
    this.onButtonPress,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: ListView(
      shrinkWrap: true,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: kBigSpace),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: TitleWidget(
              textAlign: TextAlign.center,
              textStyle: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: kBigSpace),
          child: Text(
            text,
            textAlign: TextAlign.center,
          ),
        ),
        Center(
          child: SizedBox(
            width: math.min(MediaQuery.sizeOf(context).width - 20, 300),
            child: ClickableButton(
              onPress: onButtonPress,
              prefix: buttonIcon == null ? null : Icon(buttonIcon),
              child: Text(buttonLabel),
            ),
          ),
        ),
      ],
    ),
  );
}
