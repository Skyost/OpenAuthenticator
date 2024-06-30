import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/pages/settings/page.dart';
import 'package:open_authenticator/utils/account.dart';

/// Allows to delete the user account.
class DeleteAccountSettingsEntryWidget extends ConsumerWidget with RequiresAuthenticationProvider {
  /// Creates a new delete account settings entry widget instance.
  const DeleteAccountSettingsEntryWidget({
    super.key,
  });

  @override
  Widget buildWidgetWithAuthenticationProviders(BuildContext context, WidgetRef ref) => ListTile(
        leading: Icon(
          Icons.person_off,
          color: Colors.red.shade900,
        ),
        title: Text(
          translations.settings.synchronization.deleteAccount.title,
          style: TextStyle(color: Colors.red.shade900),
        ),
        subtitle: Text(
          translations.settings.synchronization.deleteAccount.subtitle,
          style: TextStyle(color: Colors.red.shade900),
        ),
        onTap: () => AccountUtils.tryDeleteAccount(context, ref),
      );
}
