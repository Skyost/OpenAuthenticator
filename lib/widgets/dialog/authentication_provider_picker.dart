import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/providers/apple.dart';
import 'package:open_authenticator/model/authentication/providers/email_link.dart';
import 'package:open_authenticator/model/authentication/providers/github.dart';
import 'package:open_authenticator/model/authentication/providers/google.dart';
import 'package:open_authenticator/model/authentication/providers/microsoft.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/providers/twitter.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/utils/brightness_listener.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/sized_scalable_image.dart';

/// Allows to pick an authentication provider.
class AuthenticationProviderPickerDialog extends ConsumerWidget {
  /// The default icon size.
  static const double _kDefaultIconSize = 32;

  /// The dialog mode.
  final DialogMode dialogMode;

  /// Creates a new Wikimedia logo picker dialog instance.
  const AuthenticationProviderPickerDialog({
    super.key,
    this.dialogMode = DialogMode.signIn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<FirebaseAuthenticationProvider, FirebaseAuthenticationState> authenticationProviders = ref.watch(userAuthenticationProviders);
    List<FirebaseAuthenticationProvider> currentProviders = authenticationProviders.loggedInProviders;
    return AlertDialog(
      title: Text(translations.authentication.providerPickerDialog.title),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (FirebaseAuthenticationProvider provider in authenticationProviders.availableProviders)
            if (dialogMode._shouldDisplay(currentProviders, provider))
              _createListTile(
                context,
                provider,
                currentProviders,
              ),
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
  Widget _createListTile(BuildContext context, FirebaseAuthenticationProvider provider, List<FirebaseAuthenticationProvider> currentProviders) {
    IconData? trailingIcon = dialogMode._getTrailingIcon?.call(currentProviders, provider);
    AuthenticationProviderPickerDialogResult? action = dialogMode._createAction(currentProviders, provider);
    if (provider is EmailLinkAuthenticationProvider) {
      return _ProviderTile(
        provider: provider,
        trailingIcon: trailingIcon,
        name: translations.authentication.providerPickerDialog.email.title,
        subtitle: translations.authentication.providerPickerDialog.email.subtitle,
        invertIconOnBrightnessChange: true,
        onTap: () => Navigator.pop(context, action),
      );
    }
    if (provider is GoogleAuthenticationProvider) {
      return _ProviderTile(
        provider: provider,
        trailingIcon: trailingIcon,
        name: translations.authentication.providerPickerDialog.google.title,
        subtitle: translations.authentication.providerPickerDialog.google.subtitle,
        onTap: () => Navigator.pop(context, action),
      );
    }
    if (provider is AppleAuthenticationProvider) {
      return _ProviderTile(
        provider: provider,
        trailingIcon: trailingIcon,
        name: translations.authentication.providerPickerDialog.apple.title,
        subtitle: translations.authentication.providerPickerDialog.apple.subtitle,
        invertIconOnBrightnessChange: true,
        onTap: () => Navigator.pop(context, action),
      );
    }
    if (provider is MicrosoftAuthenticationProvider) {
      return _ProviderTile(
        provider: provider,
        trailingIcon: trailingIcon,
        name: translations.authentication.providerPickerDialog.microsoft.title,
        subtitle: translations.authentication.providerPickerDialog.microsoft.subtitle,
        onTap: () => Navigator.pop(context, action),
      );
    }
    if (provider is TwitterAuthenticationProvider) {
      return _ProviderTile(
        provider: provider,
        trailingIcon: trailingIcon,
        name: translations.authentication.providerPickerDialog.twitter.title,
        subtitle: translations.authentication.providerPickerDialog.twitter.subtitle,
        invertIconOnBrightnessChange: true,
        onTap: () => Navigator.pop(context, action),
      );
    }
    if (provider is GithubAuthenticationProvider) {
      return _ProviderTile(
        provider: provider,
        trailingIcon: trailingIcon,
        name: translations.authentication.providerPickerDialog.github.title,
        subtitle: translations.authentication.providerPickerDialog.github.subtitle,
        invertIconOnBrightnessChange: true,
        onTap: () => Navigator.pop(context, action),
      );
    }
    return const SizedBox.shrink();
  }

  /// Opens the dialog.
  static Future<T?> openDialog<T extends AuthenticationProviderPickerDialogResult>(
    BuildContext context, {
    required DialogMode<T> dialogMode,
  }) =>
      showDialog<T>(
        context: context,
        builder: (context) => AuthenticationProviderPickerDialog(
          dialogMode: dialogMode,
        ),
      );
}

/// An [AuthenticationProviderPickerDialog] result.
sealed class AuthenticationProviderPickerDialogResult<T extends FirebaseAuthenticationProvider> {
  /// The picked provider.
  final T provider;

  /// The action.
  final Future<Result<AuthenticationObject>> Function(BuildContext, T) action;

  /// Creates a new authentication provider picker dialog result instance.
  const AuthenticationProviderPickerDialogResult({
    required this.provider,
    required this.action,
  });
}

/// Returned when the user wants to sign-in.
class AuthenticationProviderSignIn extends AuthenticationProviderPickerDialogResult<FirebaseAuthenticationProvider> {
  /// Creates a new authentication provider picker dialog sign-in result instance.
  AuthenticationProviderSignIn({
    required super.provider,
  }) : super(
          action: (context, provider) => provider.signIn(context),
        );
}

/// Returned when the user wants to re-authenticate.
class AuthenticationProviderReAuthenticate extends AuthenticationProviderPickerDialogResult<FirebaseAuthenticationProvider> {
  /// Creates a new authentication provider picker dialog re-authenticate result instance.
  AuthenticationProviderReAuthenticate({
    required super.provider,
  }) : super(
          action: (context, provider) => provider.reAuthenticate(context),
        );
}

/// Returned when the user wants to toggle link to the picked provider.
class AuthenticationProviderToggleLink extends AuthenticationProviderPickerDialogResult<LinkProvider> {
  /// Whether to link or unlink.
  final bool link;

  /// Creates a new authentication provider picker dialog toggle link (link) result instance.
  AuthenticationProviderToggleLink({
    required super.provider,
    this.link = true,
  }) : super(
          action: link ? ((context, provider) => provider.link(context)) : ((context, provider) => provider.unlink(context)),
        );
}

/// A [FirebaseAuthenticationProvider] tile.
class _ProviderTile extends ConsumerStatefulWidget {
  /// The provider.
  final FirebaseAuthenticationProvider provider;

  /// The icon size.
  final double size;

  /// The icon to append when needed.
  final IconData? trailingIcon;

  /// The provider name.
  final String name;

  /// The tile subtitle.
  final String subtitle;

  /// Triggered when tapped on.
  final VoidCallback? onTap;

  /// Whether to invert the icon colors on brightness change.
  final bool invertIconOnBrightnessChange;

  /// Creates a new provider tile instance.
  const _ProviderTile({
    required this.provider,
    // ignore: unused_element
    this.size = AuthenticationProviderPickerDialog._kDefaultIconSize,
    this.trailingIcon,
    required this.name,
    required this.subtitle,
    this.onTap,
    this.invertIconOnBrightnessChange = false,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProviderTileState();
}

/// The provider tile state.
class _ProviderTileState extends ConsumerState<_ProviderTile> with BrightnessListener {
  @override
  Widget build(BuildContext context) {
    Widget image = SizedScalableImageWidget(
      asset: 'assets/images/authentication/${widget.name.toLowerCase()}.si',
      width: widget.size,
      height: widget.size,
    );
    return ListTile(
      leading: widget.invertIconOnBrightnessChange && currentBrightness == Brightness.dark
          ? ColorFiltered(
              colorFilter: const ColorFilter.matrix(
                [
                  -1.0, 0.0, 0.0, 0.0, 255.0, //
                  0.0, -1.0, 0.0, 0.0, 255.0, //
                  0.0, 0.0, -1.0, 0.0, 255.0, //
                  0.0, 0.0, 0.0, 1.0, 0.0, //
                ],
              ),
              child: image,
            )
          : image,
      title: Text(widget.name),
      subtitle: Text(widget.subtitle),
      enabled: widget.onTap != null,
      onTap: widget.onTap,
      trailing: widget.trailingIcon == null ? null : Icon(widget.trailingIcon),
    );
  }
}

/// Allows to change the dialog behavior.
enum DialogMode<T extends AuthenticationProviderPickerDialogResult> {
  /// Whether the user is trying to authenticate himself.
  signIn<AuthenticationProviderSignIn>(
    shouldDisplay: _shouldDisplayInSignInMode,
    createAction: _createSignAction,
  ),

  /// Whether the user is trying to link an authentication provider.
  toggleLink<AuthenticationProviderToggleLink>(
    shouldDisplay: _shouldDisplayInToggleLinkMode,
    getTrailingIcon: _getToggleLinkModeTrailingIcon,
    createAction: _createToggleLinkAction,
  ),

  /// Whether the user is trying to reauthenticate.
  reAuthenticate<AuthenticationProviderReAuthenticate>(
    shouldDisplay: _shouldDisplayInReAuthenticateMode,
    createAction: _createReAuthenticateAction,
  );

  /// Whether the [provider] should be displayed.
  final bool Function(List<FirebaseAuthenticationProvider> currentProviders, FirebaseAuthenticationProvider provider) _shouldDisplay;

  /// The trailing icon to display.
  final IconData? Function(List<FirebaseAuthenticationProvider> currentProviders, FirebaseAuthenticationProvider provider)? _getTrailingIcon;

  /// Creates the picker dialog action.
  final AuthenticationProviderPickerDialogResult? Function(List<FirebaseAuthenticationProvider> currentProviders, FirebaseAuthenticationProvider provider) _createAction;

  /// Creates a new dialog mode instance.
  const DialogMode({
    required bool Function(List<FirebaseAuthenticationProvider> currentProviders, FirebaseAuthenticationProvider provider) shouldDisplay,
    IconData? Function(List<FirebaseAuthenticationProvider> currentProviders, FirebaseAuthenticationProvider provider)? getTrailingIcon,
    required AuthenticationProviderPickerDialogResult? Function(List<FirebaseAuthenticationProvider> currentProviders, FirebaseAuthenticationProvider provider) createAction,
  })  : _shouldDisplay = shouldDisplay,
        _getTrailingIcon = getTrailingIcon,
        _createAction = createAction;

  /// Whether the [provider] should be displayed in [signIn] mode.
  static bool _shouldDisplayInSignInMode(List<FirebaseAuthenticationProvider> currentProviders, FirebaseAuthenticationProvider provider) => !currentProviders.contains(provider);

  /// Whether the [provider] should be displayed in [link] mode.
  static bool _shouldDisplayInToggleLinkMode(List<FirebaseAuthenticationProvider> currentProviders, FirebaseAuthenticationProvider provider) {
    Iterable<LinkProvider> linkProviders = currentProviders.whereType<LinkProvider>();
    if (linkProviders.length == 1 && provider == linkProviders.first) {
      return false;
    }
    return provider is LinkProvider;
  }

  /// Whether the [provider] should be displayed in [reAuthenticate] mode.
  static bool _shouldDisplayInReAuthenticateMode(List<FirebaseAuthenticationProvider> currentProviders, FirebaseAuthenticationProvider provider) => currentProviders.contains(provider);

  /// Returns the [link] mode trailing icon.
  static IconData? _getToggleLinkModeTrailingIcon(List<FirebaseAuthenticationProvider> currentProviders, FirebaseAuthenticationProvider provider) =>
      currentProviders.contains(provider) ? Icons.link_off : null;

  /// Creates the [signIn] action.
  static AuthenticationProviderPickerDialogResult? _createSignAction(List<FirebaseAuthenticationProvider> currentProviders, FirebaseAuthenticationProvider provider) => AuthenticationProviderSignIn(
        provider: provider,
      );

  /// Creates the [toggleLink] action.
  static AuthenticationProviderPickerDialogResult? _createToggleLinkAction(List<FirebaseAuthenticationProvider> currentProviders, FirebaseAuthenticationProvider provider) {
    if (provider is LinkProvider) {
      return AuthenticationProviderToggleLink(
        provider: provider,
        link: !currentProviders.contains(provider),
      );
    }
    return null;
  }

  /// Creates the [reAuthenticate] action.
  static AuthenticationProviderPickerDialogResult? _createReAuthenticateAction(List<FirebaseAuthenticationProvider> currentProviders, FirebaseAuthenticationProvider provider) =>
      AuthenticationProviderReAuthenticate(
        provider: provider,
      );
}
