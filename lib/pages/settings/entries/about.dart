import 'package:flutter/material.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/widgets/sized_scalable_image.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Shows various info about the app.
class AboutSettingsEntryWidget extends StatelessWidget {
  /// Creates a new about settings entry widget instance.
  const AboutSettingsEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) => FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        initialData: _DefaultPackageInfo(),
        builder: (context, snapshot) => ListTile(
          leading: const Icon(Icons.favorite),
          title: Text(translations.settings.about.aboutApp.title(appName: snapshot.data!.appName)),
          subtitle: Text.rich(
            translations.settings.about.aboutApp.subtitle(
              appName: TextSpan(
                text: snapshot.data!.appName,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              appVersion: TextSpan(
                text: snapshot.data!.version,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              appAuthor: const TextSpan(
                text: App.appAuthor,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ),
          enabled: snapshot.data is! _DefaultPackageInfo,
          onTap: () => showAboutDialog(
            context: context,
            applicationName: snapshot.data!.appName,
            applicationVersion: 'v${snapshot.data!.version}',
            applicationIcon: const SizedScalableImageWidget(
              asset: 'assets/images/logo.si',
              height: 90,
              width: 90,
            ),
            applicationLegalese: translations.settings.about.aboutApp.dialogLegalese(
              appName: snapshot.data!.appName,
              appAuthor: App.appAuthor,
            ),
          ),
        ),
      );
}

/// The default package info.
class _DefaultPackageInfo extends PackageInfo {
  /// Creates a new default package info instance.
  _DefaultPackageInfo()
      : super(
          appName: App.appName,
          packageName: App.appPackageName,
          version: '1.0.0',
          buildNumber: '1',
        );
}
