import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/pages/settings/page.dart';
import 'package:open_authenticator/widgets/dialog/verify_email.dart';

/// Allows the user to verify its email.
class VerifyEmailSettingsEntryWidget extends ConsumerWidget with RequiresAuthenticationProvider {
  /// Creates a new account verify settings entry widget instance.
  const VerifyEmailSettingsEntryWidget({
    super.key,
  });

  @override
  Widget buildWidgetWithAuthenticationProviders(BuildContext context, WidgetRef ref) {
    FirebaseAuthenticationState state = ref.watch(firebaseAuthenticationProvider);
    if (state is! FirebaseAuthenticationStateEmailNeedsVerification) {
      return const SizedBox.shrink();
    }
    return ListTile(
      leading: Icon(Icons.mark_email_read),
      title: Text('Verify email'),
      subtitle: Text('You have to verify your email before being able to use your account.'),
      onTap: () => VerifyEmailDialog.show(context),
    );
  }
}
