import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/model/settings/storage_type.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/pages/settings/page.dart';
import 'package:open_authenticator/utils/account.dart';

/// Allows to delete the user account.
class DeleteAccountSettingsEntryWidget extends ConsumerWidget with RequiresAuthenticationProvider {
  /// Creates a new delete account settings entry widget instance.
  const DeleteAccountSettingsEntryWidget({
    super.key,
  });

  @override
  Widget buildWidgetWithAuthenticationProviders(BuildContext context, WidgetRef ref) {
    FirebaseAuthenticationState state = ref.watch(firebaseAuthenticationProvider);
    if (state is! FirebaseAuthenticationStateLoggedIn) {
      return const SizedBox.shrink();
    }
    AsyncValue<StorageType> storageType = ref.watch(storageTypeSettingsEntryProvider);
    bool enabled = storageType is AsyncData<StorageType> && storageType.value != StorageType.online;
    return DangerZoneListTile(
      icon: Icons.person_off,
      title: translations.settings.dangerZone.deleteAccount.title,
      subtitle: translations.settings.dangerZone.deleteAccount.subtitle,
      enabled: enabled,
      onTap: () => AccountUtils.tryDeleteAccount(context, ref),
    );
  }
}
