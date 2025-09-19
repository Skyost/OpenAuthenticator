import 'package:flutter/material.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/pages/settings/entries/widgets.dart';

/// Takes the user to Github to report bugs, suggest new features, ...
class GithubSettingsEntryWidget extends UriSettingsEntry {
  /// Creates a new Github settings entry widget instance.
  GithubSettingsEntryWidget({
    super.key,
  }) : super(
         icon: Icons.bug_report,
         title: translations.settings.about.github.title,
         subtitle: translations.settings.about.github.subtitle,
         uri: Uri.parse(App.githubRepositoryUrl).replace(fragment: 'report-bugs-or-suggest-new-features'),
       );
}
