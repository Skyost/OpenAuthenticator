import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/provider.dart';

/// Allows to pick an authentication provider.
class AuthenticationProviderPickerDialog extends ConsumerWidget {
  /// The default icon size.
  static const double _kDefaultIconSize = 32;

  /// Whether to link instead of login using the provider.
  final bool link;

  /// Creates a new Wikimedia logo picker dialog instance.
  const AuthenticationProviderPickerDialog({
    super.key,
    this.link = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<FirebaseAuthenticationProvider> currentProviders = ref.watch(userAuthenticationProviders);
    return AlertDialog.adaptive(
      title: Text(translations.authentication.providerPickerDialog.title),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (FirebaseAuthenticationProvider provider in FirebaseAuthenticationProvider.availableProviders)
            if (link) ...[
              if (provider is! LinkProvider) _createListTile(provider, currentProviders),
            ] else //
              ...[
              if (!currentProviders.contains(provider)) _createListTile(provider, currentProviders),
            ]
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
      ],
    );
  }

  /// Creates the button that corresponds to the [provider].
  Widget _createListTile(FirebaseAuthenticationProvider provider, List<FirebaseAuthenticationProvider> currentProviders) {
    IconData? unlinkIcon = link && currentProviders.contains(provider) ? Icons.link_off : null;
    switch (provider) {
      case EmailLinkAuthenticationProvider():
        return _ProviderTile(
          provider: provider,
          unlinkIcon: unlinkIcon,
          name: translations.authentication.providerPickerDialog.email.title,
          subtitle: translations.authentication.providerPickerDialog.email.subtitle,
        );
      case GoogleAuthenticationProvider():
        return _ProviderTile(
          provider: provider,
          unlinkIcon: unlinkIcon,
          name: translations.authentication.providerPickerDialog.google.title,
          subtitle: translations.authentication.providerPickerDialog.google.subtitle,
        );
      case AppleAuthenticationProvider():
        return _ProviderTile(
          provider: provider,
          unlinkIcon: unlinkIcon,
          name: translations.authentication.providerPickerDialog.apple.title,
          subtitle: translations.authentication.providerPickerDialog.apple.subtitle,
        );
      case MicrosoftAuthenticationProvider():
        return _ProviderTile(
          provider: provider,
          unlinkIcon: unlinkIcon,
          name: translations.authentication.providerPickerDialog.microsoft.title,
          subtitle: translations.authentication.providerPickerDialog.microsoft.subtitle,
        );
      case TwitterAuthenticationProvider():
        return _ProviderTile(
          provider: provider,
          unlinkIcon: unlinkIcon,
          name: translations.authentication.providerPickerDialog.twitter.title,
          subtitle: translations.authentication.providerPickerDialog.twitter.subtitle,
        );
      case GithubAuthenticationProvider():
        return _ProviderTile(
          provider: provider,
          unlinkIcon: unlinkIcon,
          name: translations.authentication.providerPickerDialog.github.title,
          subtitle: translations.authentication.providerPickerDialog.github.subtitle,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// Opens the dialog.
  static Future<FirebaseAuthenticationProvider?> openDialog(
    BuildContext context, {
    bool link = false,
  }) =>
      showAdaptiveDialog<FirebaseAuthenticationProvider>(
        context: context,
        builder: (context) => AuthenticationProviderPickerDialog(
          link: link,
        ),
      );
}

/// A [FirebaseAuthenticationProvider] tile.
class _ProviderTile extends StatelessWidget {
  /// The provider.
  final FirebaseAuthenticationProvider provider;

  /// The icon size.
  final double size;

  /// The icon to append when linked.
  final IconData? unlinkIcon;

  /// The provider name.
  final String name;

  /// The tile subtitle.
  final String subtitle;

  /// Creates a new provider tile instance.
  const _ProviderTile({
    required this.provider,
    this.size = AuthenticationProviderPickerDialog._kDefaultIconSize,
    this.unlinkIcon,
    required this.name,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        leading: SvgPicture.asset(
          'assets/images/authentication/${name.toLowerCase()}.svg',
          width: size,
          height: size,
        ),
        title: Text(name),
        subtitle: Text(subtitle),
        onTap: () => Navigator.pop(context, provider),
        trailing: Icon(unlinkIcon),
      );
}
