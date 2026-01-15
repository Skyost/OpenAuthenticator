import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:open_authenticator/spacing.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/clickable.dart';
import 'package:open_authenticator/widgets/dialog/app_dialog.dart';
import 'package:open_authenticator/widgets/error.dart';

class AboutDialog extends StatelessWidget {
  final String? applicationName;
  final String? applicationVersion;
  final Widget? applicationIcon;
  final String? applicationLegalese;

  const AboutDialog({
    super.key,
    this.applicationName,
    this.applicationVersion,
    this.applicationIcon,
    this.applicationLegalese,
  });

  @override
  Widget build(BuildContext context) => AppDialog(
    title: applicationName == null ? null : Text(MaterialLocalizations.of(context).aboutListTileTitle(applicationName!)),
    actions: [
      if (applicationLegalese != null)
        ClickableButton(
          style: FButtonStyle.secondary(),
          onPress: () => _LicensesDialog.show(context),
          child: Text(MaterialLocalizations.of(context).licensesPageTitle),
        ),
      ClickableButton(
        style: FButtonStyle.secondary(),
        onPress: () => Navigator.pop(context),
        child: Text(MaterialLocalizations.of(context).closeButtonLabel),
      ),
    ],
    children: [
      if (applicationIcon != null)
        Center(
          child: applicationIcon!,
        ),
      if (applicationVersion != null)
        Center(
          child: Text(
            applicationVersion!,
            style: context.theme.typography.lg,
          ),
        ),
      if (applicationLegalese != null)
        Center(
          child: Text(applicationLegalese!),
        ),
    ],
  );

  static Future<void> show(
    BuildContext context, {
    String? applicationName,
    String? applicationVersion,
    Widget? applicationIcon,
    String? applicationLegalese,
  }) => showFDialog(
    context: context,
    builder: (context, style, animation) => AboutDialog(
      applicationName: applicationName,
      applicationVersion: applicationVersion,
      applicationIcon: applicationIcon,
      applicationLegalese: applicationLegalese,
    ),
  );
}

class _LicensesDialog extends StatefulWidget {
  const _LicensesDialog();

  @override
  State<_LicensesDialog> createState() => _LicensesDialogState();

  static Future<void> show(BuildContext context) => showFDialog(
    context: context,
    builder: (context, style, animation) => const _LicensesDialog(),
  );
}

class _LicensesDialogState extends State<_LicensesDialog> {
  late final Future<List<_PackageLicense>> _future = _loadLicenses();

  @override
  Widget build(BuildContext context) => FutureBuilder<List<_PackageLicense>>(
    future: _future,
    builder: (context, snapshot) => AppDialog(
      title: Text(MaterialLocalizations.of(context).licensesPageTitle),
      actions: [
        ClickableButton(
          style: FButtonStyle.secondary(),
          onPress: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
      children: [
        if (snapshot.hasError) ErrorDetails(error: snapshot.error),
        if (snapshot.data == null)
          const CenteredCircularProgressIndicator()
        else
          for (int i = 0; i < snapshot.data!.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == snapshot.data!.length - 1 ? 0 : kSpace),
              child: _PackageRow(
                title: snapshot.data![i].package,
                subtitle: '${snapshot.data![i].estimatedLines} lignes',
                onPress: () => _openDetails(
                  context,
                  package: snapshot.data![i],
                ),
              ),
            ),
      ],
    ),
  );

  Future<List<_PackageLicense>> _loadLicenses() async {
    List<LicenseEntry> entries = await LicenseRegistry.licenses.toList();

    Map<String, List<LicenseParagraph>> byPkg = {};
    for (LicenseEntry entry in entries) {
      for (String pkg in entry.packages) {
        (byPkg[pkg] ??= []).addAll(entry.paragraphs);
      }
    }

    return [
      for (MapEntry<String, List<LicenseParagraph>> entry in byPkg.entries)
        _PackageLicense(
          package: entry.key,
          paragraphs: entry.value,
        ),
    ]..sort((a, b) => a.package.toLowerCase().compareTo(b.package.toLowerCase()));
  }

  Future<void> _openDetails(
    BuildContext context, {
    required _PackageLicense package,
  }) => showFDialog(
    context: context,
    builder: (context, style, animation) => AppDialog(
      title: Text(package.package),
      actions: [
        ClickableButton(
          style: FButtonStyle.secondary(),
          onPress: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
      children: [
        for (LicenseParagraph paragraph in package.paragraphs)
          Padding(
            padding: EdgeInsets.only(
              left: math.max(0, paragraph.indent) * 12,
              bottom: kSpace,
            ),
            child: Text(paragraph.text),
          ),
      ],
    ),
  );
}

class _PackageRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onPress;

  const _PackageRow({
    required this.title,
    required this.subtitle,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) => ClickableTile(
    title: Text(title),
    subtitle: Text(subtitle),
    onPress: onPress,
    suffix: const Icon(FIcons.chevronRight),
  );
}

class _PackageLicense {
  final String package;
  final List<LicenseParagraph> paragraphs;

  const _PackageLicense({
    required this.package,
    required this.paragraphs,
  });

  int get estimatedLines {
    int chars = paragraphs.fold<int>(0, (acc, p) => acc + p.text.length);
    return (chars / 70).ceil();
  }
}
