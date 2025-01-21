import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/pages/intro/page.dart';

/// Allows to show the intro page.
class ShowIntroPageSettingsEntryWidget extends ConsumerWidget {
  /// Creates a new show intro page settings entry widget instance.
  const ShowIntroPageSettingsEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
      leading: const Icon(Icons.first_page),
      title: const Text('Show intro page'),
      subtitle: const Text('Displays the intro page.'),
      onTap: () async {
        await Navigator.pushNamedAndRemoveUntil(context, IntroPage.name, (_) => false);
      },
    );
}
