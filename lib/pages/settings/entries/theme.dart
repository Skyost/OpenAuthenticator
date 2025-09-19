import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/settings/theme.dart';
import 'package:open_authenticator/widgets/form/dropdown_list_tile.dart';

/// Allows to configure [themeSettingsEntryProvider].
class ThemeSettingsEntryWidget extends ConsumerWidget {
  /// Creates a new theme settings entry widget instance.
  const ThemeSettingsEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<ThemeMode> theme = ref.watch(themeSettingsEntryProvider);
    return DropdownListTile(
      enabled: theme.hasValue,
      title: Text(translations.settings.application.theme.title),
      value: theme.value,
      choices: [
        for (ThemeMode mode in ThemeMode.values)
          DropdownListTileChoice(
            title: translations.settings.application.theme.values[mode.name]!,
            icon: mode.icon,
            value: mode,
          ),
      ],
      onChoiceSelected: (choice) => ref.read(themeSettingsEntryProvider.notifier).changeValue(choice.value),
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
