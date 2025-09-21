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
      enabled: theme.hasValue,
      title: Text(translations.settings.application.theme.title),
      subtitle: Text(translations.settings.application.theme.subtitle),
      leading: Icon(theme.value?.icon),
      trailing: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Icon(Icons.chevron_right),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _ThemeRouteWidget(),
          ),
        );
      },
    );
  }
}

/// Allows to configure the theme.
class _ThemeRouteWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<ThemeMode> theme = ref.watch(themeSettingsEntryProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(translations.settings.application.theme.title),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          for (ThemeMode mode in ThemeMode.values)
            ListTile(
              leading: Icon(mode.icon),
              title: Text(translations.settings.application.theme.name[mode.name]!),
              subtitle: Text(translations.settings.application.theme.description[mode.name]!),
              trailing: theme.value == mode ? const Icon(Icons.check) : null,
              onTap: () => ref.read(themeSettingsEntryProvider.notifier).changeValue(mode),
            ),
        ],
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
