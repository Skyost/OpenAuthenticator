import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/backend/user.dart';
import 'package:open_authenticator/model/settings/storage_type.dart';
import 'package:open_authenticator/utils/account.dart';
import 'package:open_authenticator/widgets/clickable.dart';

/// Allows to delete the user account.
class DeleteAccountSettingsEntryWidget extends ConsumerWidget with FTileMixin {
  /// Creates a new delete account settings entry widget instance.
  const DeleteAccountSettingsEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    User? user = ref.watch(userProvider).value;
    if (user == null) {
      return const SizedBox.shrink();
    }
    AsyncValue<StorageType> storageType = ref.watch(storageTypeSettingsEntryProvider);
    bool enabled = storageType is AsyncData<StorageType> && storageType.value != StorageType.shared;
    return ClickableTile(
      prefix: const Icon(FIcons.user),
      title: Text(translations.settings.dangerZone.deleteAccount.title),
      subtitle: Text(translations.settings.dangerZone.deleteAccount.subtitle),
      enabled: enabled,
      onPress: () => AccountUtils.tryDeleteAccount(context, ref),
    );
  }
}
