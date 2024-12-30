import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/pages/settings/page.dart';
import 'package:open_authenticator/utils/account.dart';
import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';

/// Allows the user to link its account to another provider.
class AccountLinkSettingsEntryWidget extends ConsumerWidget with RequiresAuthenticationProvider {
  /// Creates a new account link settings entry widget instance.
  const AccountLinkSettingsEntryWidget({
    super.key,
  });

  @override
  Widget buildWidgetWithAuthenticationProviders(BuildContext context, WidgetRef ref) {
    FirebaseAuthenticationState state = ref.watch(firebaseAuthenticationProvider);
    if (state is! FirebaseAuthenticationStateLoggedIn) {
      return const SizedBox.shrink();
    }
    List<FirebaseAuthenticationProvider> providers = ref.watch(userAuthenticationProviders.select((providers) => providers.loggedInProviders));
    return ListTile(
      leading: const Icon(Icons.link),
      title: Text(translations.settings.synchronization.accountLink.title),
      subtitle: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: translations.settings.synchronization.accountLink.subtitle.text,
            ),
            if (FirebaseAuth.instance.currentUser?.providers.isNotEmpty ?? false)
              translations.settings.synchronization.accountLink.subtitle.linkedProviders(
                providers: TextSpan(
                  children: [
                    for (int i = 0; i < providers.length; i++)
                      TextSpan(
                        text: translations.settings.synchronization.accountLink.subtitle.providers[providers[i].providerId] ?? providers[i].providerId,
                        children: [
                          if (i < providers.length - 1)
                            const TextSpan(
                              text: ', ',
                              style: TextStyle(fontStyle: FontStyle.normal),
                            ),
                        ],
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      )
                  ],
                ),
              ),
          ],
        ),
      ),
      onTap: () => AccountUtils.tryToggleLink(context, ref),
    );
  }
}
