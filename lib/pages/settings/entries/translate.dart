import 'package:flutter/material.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:url_launcher/url_launcher.dart';

/// Takes the user to the app translation page.
class TranslateSettingsEntryWidget extends StatelessWidget {
  /// Creates a new translate settings entry widget instance.
  const TranslateSettingsEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.translate),
    title: Text(translations.settings.about.translate.title),
    subtitle: Text(translations.settings.about.translate.subtitle(appName: App.appName)),
    onTap: () async {
      Uri uri = Uri.parse(App.appTranslationUrl);
      if (await canLaunchUrl(uri)) {
        launchUrl(uri);
      }
    },
  );
}
