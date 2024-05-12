import 'package:flutter/foundation.dart';
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
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }
    return ListTile(
      leading: const Icon(Icons.translate),
      title: DropdownButtonFormField<AppLocale>(
        value: TranslationProvider.of(context).locale,
        decoration: const InputDecoration(
          labelText: 'Language',
        ),
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
    );
  }
}
