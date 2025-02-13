import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/settings/storage_type.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/utils/master_password.dart';

/// Allows to change the user master password.
class ChangeMasterPasswordSettingsEntryWidget extends ConsumerWidget {
  /// Creates a new change master password settings entry widget instance.
  const ChangeMasterPasswordSettingsEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<StorageType> storageType = ref.watch(storageTypeSettingsEntryProvider);
    return ListTile(
      leading: const Icon(Icons.password),
      title: Text(translations.settings.security.changeMasterPassword.title),
      subtitle: Text.rich(
        TextSpan(
          text: translations.settings.security.changeMasterPassword.subtitle.text,
          children: [
            if (storageType.valueOrNull == StorageType.online)
              TextSpan(
                text: '\n${translations.settings.security.changeMasterPassword.subtitle.sync}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
      onTap: () => MasterPasswordUtils.changeMasterPassword(context, ref),
    );
  }
}
