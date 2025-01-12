import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// A settings entry that allows to open a specific URI.
class UriSettingsEntry extends StatelessWidget {
  /// The entry widget title.
  final String title;

  /// The entry widget subtitle.
  final String? subtitle;

  /// The icon.
  final IconData? icon;

  /// The URI to open.
  final Uri uri;

  /// Creates a new URI settings entry instance.
  const UriSettingsEntry({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.uri,
  });

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: canLaunchUrl(uri),
        builder: (context, snapshot) => createListTile(context, snapshot.data),
      );

  Widget createListTile(BuildContext context, bool? canLaunchUri) => canLaunchUri == null || canLaunchUri == true
      ? ListTile(
          leading: const Icon(Icons.translate),
          title: Text(title),
          subtitle: subtitle == null ? null : Text(subtitle!),
          onTap: canLaunchUri == true ? (() async => await launchUrl(uri)) : null,
        )
      : SizedBox.shrink();
}
