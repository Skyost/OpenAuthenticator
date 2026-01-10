import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/app_links.dart';

/// Allows to input a link from the clipboard.
class LinkInputSettingsEntryWidget extends ConsumerWidget {
  /// Creates a new link input settings entry widget instance.
  const LinkInputSettingsEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
    leading: const Icon(Icons.link),
    title: const Text('Input link'),
    subtitle: const Text('Inputs an openauthenticator:// link from the clipboard.'),
    onTap: () async {
      ClipboardData? clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData == null || clipboardData.text == null) {
        return;
      }
      Uri? uri = Uri.tryParse(clipboardData.text!);
      if (uri == null || uri.scheme != 'openauthenticator') {
        return;
      }
      ref.read(appLinksListenerProvider.notifier).provideLink(uri);
    },
  );
}