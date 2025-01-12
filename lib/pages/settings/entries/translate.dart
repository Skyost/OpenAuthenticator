import 'package:flutter/material.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/pages/settings/entries/uri_settings_entry.dart';
import 'package:url_launcher/url_launcher.dart';

/// Takes the user to the app translation page.
class TranslateSettingsEntryWidget extends UriSettingsEntry {
  /// Creates a new translate settings entry widget instance.
  TranslateSettingsEntryWidget({
    super.key,
  }) : super(
          icon: Icons.translate,
          title: translations.settings.about.translate.title,
          subtitle: translations.settings.about.translate.subtitle(appName: App.appName),
          uri: Uri.parse(App.appTranslationUrl),
        );
}
