import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/pages/settings/entries/about.dart';
import 'package:open_authenticator/pages/settings/entries/backup_now.dart';
import 'package:open_authenticator/pages/settings/entries/cache_totp_pictures.dart';
import 'package:open_authenticator/pages/settings/entries/change_master_password.dart';
import 'package:open_authenticator/pages/settings/entries/clear_data.dart';
import 'package:open_authenticator/pages/settings/entries/confirm_email.dart';
import 'package:open_authenticator/pages/settings/entries/contributor_plan.dart';
import 'package:open_authenticator/pages/settings/entries/contributor_plan_state.dart';
import 'package:open_authenticator/pages/settings/entries/delete_account.dart';
import 'package:open_authenticator/pages/settings/entries/display_copy_button.dart';
import 'package:open_authenticator/pages/settings/entries/enable_local_auth.dart';
import 'package:open_authenticator/pages/settings/entries/github.dart';
import 'package:open_authenticator/pages/settings/entries/link.dart';
import 'package:open_authenticator/pages/settings/entries/locale.dart';
import 'package:open_authenticator/pages/settings/entries/log_in.dart';
import 'package:open_authenticator/pages/settings/entries/manage_backups.dart';
import 'package:open_authenticator/pages/settings/entries/refresh_id_token.dart';
import 'package:open_authenticator/pages/settings/entries/save_derived_key.dart';
import 'package:open_authenticator/pages/settings/entries/show_intro_page.dart';
import 'package:open_authenticator/pages/settings/entries/synchronize.dart';
import 'package:open_authenticator/pages/settings/entries/theme.dart';
import 'package:open_authenticator/pages/settings/entries/translate.dart';
import 'package:open_authenticator/utils/platform.dart';

/// Allows to configure the app.
class SettingsPage extends ConsumerWidget {
  /// The settings page name.
  static const String name = '/settings';

  /// Creates a new settings page instance.
  const SettingsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: Text(translations.settings.title),
        ),
        body: Theme(
          data: Theme.of(context).copyWith(
            buttonTheme: const ButtonThemeData(
              alignedDropdown: false,
            ),
          ),
          child: ListView(
            children: [
              _SettingsPageSectionTitle(title: translations.settings.application.title),
              const ContributorPlanEntryWidget(),
              const ThemeSettingsEntryWidget(),
              CacheTotpPicturesSettingsEntryWidget(),
              if (currentPlatform.isMobile || kDebugMode) //
                DisplayCopyButtonSettingsEntryWidget(),
              _SettingsPageSectionTitle(title: translations.settings.security.title),
              EnableLocalAuthSettingsEntryWidget(),
              SaveDerivedKeySettingsEntryWidget(),
              const ChangeMasterPasswordSettingsEntryWidget(),
              const _SynchronizationSectionTitle(),
              const ConfirmEmailSettingsEntryWidget(),
              const AccountLinkSettingsEntryWidget(),
              SynchronizeSettingsEntryWidget(),
              const AccountLogInSettingsEntryWidget(),
              _SettingsPageSectionTitle(title: translations.settings.backups.title),
              const BackupNowSettingsEntryWidget(),
              const ManageBackupSettingsEntryWidget(),
              _SettingsPageSectionTitle(title: translations.settings.about.title),
              TranslateSettingsEntryWidget(),
              GithubSettingsEntryWidget(),
              const AboutSettingsEntryWidget(),
              _SettingsPageSectionTitle(title: translations.settings.dangerZone.title),
              const DeleteAccountSettingsEntryWidget(),
              const ClearDataSettingsEntryWidget(),
              if (kDebugMode) ...[
                const _SettingsPageSectionTitle(title: 'Debug'),
                const ShowIntroPageSettingsEntryWidget(),
                const ContributorPlanStateEntryWidget(),
                const LocaleEntryWidget(),
                const RefreshUserSettingsEntryWidget(),
              ]
            ],
          ),
        ),
      );
}

/// A settings section title.
class _SettingsPageSectionTitle extends StatelessWidget {
  /// The title.
  final String title;

  /// Creates a new settings page section title instance.
  const _SettingsPageSectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      );
}

/// The "Synchronization" page section title.
class _SynchronizationSectionTitle extends ConsumerWidget with RequiresAuthenticationProvider {
  /// Creates a new synchronization section title.
  const _SynchronizationSectionTitle();

  @override
  Widget buildWidgetWithAuthenticationProviders(BuildContext context, WidgetRef ref) => _SettingsPageSectionTitle(title: translations.settings.synchronization.title);
}

/// A widget that needs some authentication providers.
mixin RequiresAuthenticationProvider on ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool hasProvider = ref.watch(userAuthenticationProviders.select((providers) => providers.availableProviders.isNotEmpty));
    if (!hasProvider) {
      return SizedBox.shrink();
    }
    FirebaseAuthenticationState authenticationState = ref.watch(firebaseAuthenticationProvider);
    return isAuthenticationStateValid(authenticationState) ? buildWidgetWithAuthenticationProviders(context, ref) : SizedBox.shrink();
  }

  /// Whether this settings entry requires a specific state to be displayed.
  bool isAuthenticationStateValid(FirebaseAuthenticationState authenticationState) => true;

  /// Builds the widget when authentication providers are available.
  Widget buildWidgetWithAuthenticationProviders(BuildContext context, WidgetRef ref);
}
