import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/app_unlock/method.dart';
import 'package:open_authenticator/model/settings/app_unlock_method.dart';
import 'package:open_authenticator/pages/settings/entries/widgets.dart';
import 'package:open_authenticator/utils/local_authentication/local_authentication.dart';

/// Allows to configure [enableLocalAuthSettingsEntryProvider].
class EnableLocalAuthSettingsEntryWidget extends CheckboxSettingsEntryWidget<AppUnlockMethodSettingsEntry, AppUnlockMethod> {
  /// Creates a new enable local auth settings entry widget instance.
  EnableLocalAuthSettingsEntryWidget({
    super.key,
  }) : super(
          provider: appUnlockMethodSettingsEntryProvider,
          title: translations.settings.security.enableLocalAuth.title,
          subtitle: translations.settings.security.enableLocalAuth.subtitle,
          icon: Icons.lock,
        );

  @override
  Widget build(BuildContext context, WidgetRef ref) => FutureBuilder(
        future: LocalAuthentication.instance.isSupported(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return createListTile(context, ref, enabled: false);
          }
          return snapshot.data == true ? super.build(context, ref) : const SizedBox.shrink();
        },
      );

  @override
  Future<void> changeValue(BuildContext context, WidgetRef ref, bool newValue) async {
    AppUnlockMethod newMethod = newValue ? LocalAuthenticationAppUnlockMethod() : NoneAppUnlockMethod();
    ref.read(appUnlockMethodSettingsEntryProvider.notifier).changeValueIfUnlockSucceed(newMethod, context);
  }

  @override
  bool isEnabled(AppUnlockMethod? value) => value is LocalAuthenticationAppUnlockMethod;
}
