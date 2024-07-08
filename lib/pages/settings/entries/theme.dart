import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/settings/theme.dart';

/// Allows to configure [themeSettingsEntryProvider].
class ThemeSettingsEntryWidget extends ConsumerWidget {
  /// Creates a new theme settings entry widget instance.
  const ThemeSettingsEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<ThemeMode> theme = ref.watch(themeSettingsEntryProvider);
    return ListTile(
      leading: Icon(theme.valueOrNull.icon),
      enabled: theme.hasValue,
      title: DropdownButtonFormField<ThemeMode>(
        value: theme.valueOrNull,
        decoration: InputDecoration(
          labelText: translations.settings.application.theme.title,
        ),
        items: [
          for (ThemeMode theme in ThemeMode.values)
            if (translations.settings.application.theme.values.containsKey(theme.name))
              DropdownMenuItem<ThemeMode>(
                value: theme,
                child: Text(translations.settings.application.theme.values[theme.name]!),
              ),
        ],
        onChanged: (value) async {
          if (value != null) {
            await ref.read(themeSettingsEntryProvider.notifier).changeValue(value);
          }
        },
      ),
    );
  }
}

/// Allows to associate an icon with a theme mode.
extension _Icon on ThemeMode? {
  /// Returns the icon associated with the current theme mode.
  IconData get icon {
    switch (this) {
      case null:
      case ThemeMode.system:
        return Icons.auto_awesome;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.light:
        return Icons.light_mode;
    }
  }
}
