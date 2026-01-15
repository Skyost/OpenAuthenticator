import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:open_authenticator/i18n/translations.g.dart';

/// Allows to change the app locale for debugging purposes.
class LocaleEntryWidget extends ConsumerWidget with FTileMixin {
  /// Creates a new Locale entry widget instance.
  const LocaleEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => FSelectMenuTile<AppLocale>.fromMap(
    {
      for (AppLocale locale in AppLocale.values) locale.languageCode: locale,
    },
    selectControl: FMultiValueControl.managed(
      initial: {TranslationProvider.of(context).locale},
      min: 1,
      max: 1,
      onChange: (choices) => LocaleSettings.setLocale(choices.first),
    ),
    prefix: const Icon(FIcons.languages),
    title: const Text('Language'),
    detailsBuilder: (_, values, _) => Text(values.first.name),
  );
}
