import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/pages/settings/page.dart';
import 'package:open_authenticator/utils/account.dart';
import 'package:open_authenticator/utils/storage_migration.dart';

/// Allows the user to login or logout from the app.
class AccountLogInSettingsEntryWidget extends ConsumerWidget with RequiresAuthenticationProvider {
  /// Creates a new account login settings entry widget instance.
  const AccountLogInSettingsEntryWidget({
    super.key,
  });

  @override
  Widget buildWidgetWithAuthenticationProviders(BuildContext context, WidgetRef ref) {
    FirebaseAuthenticationState state = ref.watch(firebaseAuthenticationProvider);
    switch (state) {
      case FirebaseAuthenticationStateLoggedOut():
        return const _LogInListTile();
      case FirebaseAuthenticationStateLoggedIn(:final user):
        return _LogOutListTile(user: user.email ?? user.uid);
    }
  }
}

/// The login list tile.
class _LogInListTile extends ConsumerWidget {
  /// Creates a new log in list tile instance.
  const _LogInListTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
    leading: const Icon(Icons.login),
    title: Text(translations.settings.synchronization.accountLogin.logIn.title),
    subtitle: Text(translations.settings.synchronization.accountLogin.logIn.subtitle),
    onTap: () => AccountUtils.trySignIn(context, ref),
  );
}

/// The logout list tile.
class _LogOutListTile extends ConsumerWidget {
  /// The user.
  final String? user;

  /// Creates a new logout list tile instance.
  const _LogOutListTile({
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
    leading: const Icon(Icons.logout),
    title: Text(translations.settings.synchronization.accountLogin.logOut.title),
    subtitle: Text.rich(
      translations.settings.synchronization.accountLogin.logOut.subtitle(
        email: TextSpan(
          text: user,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ),
    onTap: () => StorageMigrationUtils.changeStorageType(context, ref, StorageType.local, logout: true),
  );
}
