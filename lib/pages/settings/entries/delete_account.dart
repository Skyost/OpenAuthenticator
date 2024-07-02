import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/model/settings/storage_type.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/pages/settings/page.dart';
import 'package:open_authenticator/utils/account.dart';
import 'package:open_authenticator/utils/brightness_listener.dart';

/// Allows to delete the user account.
class DeleteAccountSettingsEntryWidget extends ConsumerWidget with RequiresAuthenticationProvider {
  /// Creates a new delete account settings entry widget instance.
  const DeleteAccountSettingsEntryWidget({
    super.key,
  });

  @override
  Widget buildWidgetWithAuthenticationProviders(BuildContext context, WidgetRef ref) {
    FirebaseAuthenticationState state = ref.watch(firebaseAuthenticationProvider);
    return state is FirebaseAuthenticationStateLoggedIn ? _DeleteAccountListTile() : const SizedBox.shrink();
  }
}

/// The delete account list tile.
class _DeleteAccountListTile extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DeleteAccountListTileState();
}

/// The delete account list tile state.
class _DeleteAccountListTileState extends ConsumerState<_DeleteAccountListTile> with BrightnessListener {
  @override
  Widget build(BuildContext context) {
    AsyncValue<StorageType> storageType = ref.watch(storageTypeSettingsEntryProvider);
    return ListTile(
      leading: Icon(
        Icons.person_off,
        color: _textColor,
      ),
      title: Text(
        translations.settings.synchronization.deleteAccount.title,
        style: TextStyle(color: _textColor),
      ),
      subtitle: Text(
        translations.settings.synchronization.deleteAccount.subtitle,
        style: TextStyle(color: _textColor),
      ),
      onTap: storageType is AsyncData<StorageType> && storageType.value != StorageType.online ? (() => AccountUtils.tryDeleteAccount(context, ref)) : null,
    );
  }

  /// The text color.
  Color get _textColor => currentBrightness == Brightness.light ? Colors.red.shade900 : Colors.red.shade400;
}
