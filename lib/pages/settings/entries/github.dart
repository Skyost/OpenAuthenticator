import 'package:flutter/material.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:url_launcher/url_launcher.dart';

/// Takes the user to Github to report bugs, suggest new features, ...
class GithubSettingsEntryWidget extends StatelessWidget {
  /// Creates a new Github settings entry widget instance.
  const GithubSettingsEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.bug_report),
    title: Text(translations.settings.about.github.title),
    subtitle: Text(translations.settings.about.github.subtitle),
    onTap: () async {
      Uri uri = Uri.parse(App.githubRepositoryUrl);
      Uri withFragment = Uri(
        scheme: uri.scheme,
        host: uri.host,
        path: uri.path,
        fragment: 'report-bugs-or-suggest-new-features',
      );
      if (await canLaunchUrl(withFragment)) {
        launchUrl(withFragment);
      }
    },
  );
}
