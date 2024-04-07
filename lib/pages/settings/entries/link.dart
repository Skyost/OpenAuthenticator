import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/provider.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/pages/settings/page.dart';
import 'package:open_authenticator/utils/account.dart';

/// Allows the user to link its account to another provider.
class AccountLinkSettingsEntryWidget extends ConsumerWidget with RequiresAuthenticationProvider {
  /// Creates a new account link settings entry widget instance.
  const AccountLinkSettingsEntryWidget({
    super.key,
  });

  @override
  Widget buildWidgetWithAuthenticationProviders(BuildContext context, WidgetRef ref) {
    FirebaseAuthenticationState? state = ref.watch(firebaseAuthenticationProvider).valueOrNull;
    List<FirebaseAuthenticationProvider> providers = ref.watch(userAuthenticationProviders);
    return state is FirebaseAuthenticationStateLoggedIn
        ? ListTile(
            leading: const Icon(Icons.link),
            title: Text(translations.settings.synchronization.accountLink.title),
            subtitle: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: translations.settings.synchronization.accountLink.subtitle.text,
                  ),
                  if (FirebaseAuth.instance.currentUser?.providerData.isNotEmpty ?? false)
                    TextSpan(
                      text: translations.settings.synchronization.accountLink.subtitle.providers(providers: providers.map((provider) => provider.providerId).join(', ')),
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                ],
              ),
            ),
            onTap: () => AccountUtils.tryToggleLink(context, ref),
          )
        : const SizedBox.shrink();
  }
}
