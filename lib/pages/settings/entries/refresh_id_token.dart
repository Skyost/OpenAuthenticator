import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';

/// Allows to refresh the user data and ID token.
class RefreshUserSettingsEntryWidget extends ConsumerWidget {
  /// Creates a new refresh user settings entry widget instance.
  const RefreshUserSettingsEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FirebaseAuthenticationState state = ref.watch(firebaseAuthenticationProvider);
    if (state is! FirebaseAuthenticationStateLoggedIn) {
      return const SizedBox.shrink();
    }
    return ListTile(
      leading: const Icon(Icons.generating_tokens),
      title: const Text('Refresh user'),
      subtitle: const Text('Refreshes the current user and his ID token.'),
      onTap: () async {
        await showWaitingOverlay(
          context,
          future: FirebaseAuth.instance.currentUser!.getIdToken(forceRefresh: true),
        );
        if (!context.mounted) {
          return;
        }
        await showWaitingOverlay(
          context,
          future: FirebaseAuth.instance.currentUser!.reload(),
        );
      },
    );
  }
}
