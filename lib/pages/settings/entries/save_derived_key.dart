import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/app_unlock/method.dart';
import 'package:open_authenticator/model/settings/app_unlock_method.dart';
import 'package:open_authenticator/pages/settings/entries/bool_entry.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';

/// Allows to configure [saveDerivedKeySettingsEntryProvider].
class SaveDerivedKeySettingsEntryWidget extends CheckboxSettingsEntryWidget<AppUnlockMethodSettingsEntry, AppUnlockMethod> {
  /// Creates a new save derived key settings entry widget instance.
  SaveDerivedKeySettingsEntryWidget({
    super.key,
    super.contentPadding,
  }) : super(
          icon: Icons.key,
          provider: appUnlockMethodSettingsEntryProvider,
          title: translations.settings.security.saveDerivedKey.title,
          subtitle: translations.settings.security.saveDerivedKey.subtitle,
        );

  /// Creates a new save derived key settings entry widget instance for the intro page.
  SaveDerivedKeySettingsEntryWidget.intro({
    Key? key,
  }) : this(
          key: key,
          contentPadding: EdgeInsets.zero,
        );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<AppUnlockMethod> unlockMethod = ref.watch(appUnlockMethodSettingsEntryProvider);
    if (!unlockMethod.hasValue || unlockMethod.value is LocalAuthenticationAppUnlockMethod) {
      return const SizedBox.shrink();
    }
    return super.build(context, ref);
  }

  @override
  Future<void> changeValue(BuildContext context, WidgetRef ref, bool newValue) async {
    AppUnlockMethod newMethod = newValue ? NoneAppUnlockMethod() : MasterPasswordAppUnlockMethod();
    if (!(await ref.read(appUnlockMethodSettingsEntryProvider.notifier).changeValueIfUnlockSucceed(newMethod, context)) && context.mounted) {
      SnackBarIcon.showErrorSnackBar(context, text: translations.settings.security.saveDerivedKey.error);
    }
  }

  @override
  bool isEnabled(AppUnlockMethod? value) => value is! MasterPasswordAppUnlockMethod;
}
