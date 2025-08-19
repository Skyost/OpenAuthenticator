import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';

/// Allows to change the app locale for debugging purposes.
class LocaleEntryWidget extends ConsumerWidget {
  /// Creates a new Locale entry widget instance.
  const LocaleEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
        leading: const Icon(Icons.translate),
        title: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Language',
          ),
          child: DropdownButton<AppLocale>(
            value: TranslationProvider.of(context).locale,
            items: [
              for (AppLocale locale in AppLocale.values)
                DropdownMenuItem<AppLocale>(
                  value: locale,
                  child: Text(locale.languageCode),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                LocaleSettings.setLocale(value);
              }
            },
          ),
        ),
      );
}
