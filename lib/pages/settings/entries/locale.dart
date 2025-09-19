import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/widgets/form/dropdown_list_tile.dart';

/// Allows to change the app locale for debugging purposes.
class LocaleEntryWidget extends ConsumerWidget {
  /// Creates a new Locale entry widget instance.
  const LocaleEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => DropdownListTile(
    leading: const Icon(Icons.translate),
    title: Text('Language'),
    value: TranslationProvider.of(context).locale,
    choices: [
      for (AppLocale locale in AppLocale.values)
        DropdownListTileChoice(
          title: locale.languageCode,
          value: locale,
        ),
    ],
    onChoiceSelected: (choice) => LocaleSettings.setLocale(choice.value),
  );
}
