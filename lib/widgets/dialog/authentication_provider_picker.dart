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
import 'package:open_authenticator/widgets/authentication_provider_image.dart';
import 'package:open_authenticator/widgets/dialog/app_dialog.dart';
import 'package:open_authenticator/widgets/invert_colors.dart';

/// Allows to pick an authentication provider.
class AuthenticationProviderPickerDialog extends ConsumerWidget {
  /// The dialog mode.
  final DialogMode dialogMode;

  /// Creates a new authentication picker dialog instance.
  const AuthenticationProviderPickerDialog({
    super.key,
    required this.dialogMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<FirebaseAuthenticationProvider, FirebaseAuthenticationState> authenticationProviders = ref.watch(userAuthenticationProviders);
    List<FirebaseAuthenticationProvider> currentProviders = authenticationProviders.loggedInProviders;
    return AppDialog(
      title: Text(translations.authentication.providerPickerDialogTitle),
      contentPadding: kClassicChoiceDialogPadding,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
      ],
      children: [
        for (FirebaseAuthenticationProvider provider in authenticationProviders.availableProviders)
          if (dialogMode._shouldDisplay(currentProviders, provider))
            _createListTile(
              context,
              provider,
              currentProviders,
            ),
      ],
    );
  }

  /// Creates the button that corresponds to the [provider].
  Widget _createListTile(BuildContext context, FirebaseAuthenticationProvider provider, List<FirebaseAuthenticationProvider> currentProviders) {
    IconData? trailingIcon = dialogMode._getTrailingIcon?.call(currentProviders, provider);
    AuthenticationProviderPickerDialogResult? action = dialogMode._createAction(currentProviders, provider);
    return _ProviderTile(
      provider: provider,
      trailingIcon: trailingIcon,
      onTap: () => Navigator.pop(context, action),
    );
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

/// Represents an action.
typedef AuthenticationProviderPickerDialogAction<T extends FirebaseAuthenticationProvider> = Future<Result<AuthenticationObject>> Function(BuildContext context, T provider);

/// An [AuthenticationProviderPickerDialog] result.
sealed class AuthenticationProviderPickerDialogResult<T extends FirebaseAuthenticationProvider> {
  /// The picked provider.
  final T provider;

  /// The action.
  final AuthenticationProviderPickerDialogAction<T> action;

  /// Creates a new authentication provider picker dialog result instance.
  const AuthenticationProviderPickerDialogResult({
    required this.provider,
    required this.action,
  });
}

/// Returned when the user wants to re-authenticate.
class AuthenticationProviderReAuthenticateResult extends AuthenticationProviderPickerDialogResult<FirebaseAuthenticationProvider> {
  /// Creates a new authentication provider picker dialog re-authenticate result instance.
  AuthenticationProviderReAuthenticateResult({
    required super.provider,
  }) : super(
          action: (context, provider) => provider.reAuthenticate(context),
        );
}

/// Returned when the user wants to toggle link to the picked provider.
class AuthenticationProviderToggleLinkResult extends AuthenticationProviderPickerDialogResult<LinkProvider> {
  /// Whether to link or unlink.
  final bool link;

  /// Creates a new authentication provider picker dialog toggle link (link) result instance.
  AuthenticationProviderToggleLinkResult({
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

  /// Triggered when tapped on.
  final VoidCallback? onTap;

  /// Creates a new provider tile instance.
  const _ProviderTile({
    required this.provider,
    // ignore: unused_element
    this.size = 32,
    this.trailingIcon,
    this.onTap,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProviderTileState();
}

/// The provider tile state.
class _ProviderTileState extends ConsumerState<_ProviderTile> with BrightnessListener {
  @override
  Widget build(BuildContext context) {
    Widget image = FirebaseAuthenticationProviderImage(
      provider: widget.provider,
      width: widget.size,
      height: widget.size,
    );
    bool invertIconOnBrightnessChance = widget.provider is EmailLinkAuthenticationProvider ||
        widget.provider is AppleAuthenticationProvider ||
        widget.provider is GithubAuthenticationProvider ||
        widget.provider is TwitterAuthenticationProvider;
    String? title = switch (widget.provider) {
      EmailLinkAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.email.name,
      GoogleAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.google.name,
      AppleAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.apple.name,
      GithubAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.github.name,
      MicrosoftAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.microsoft.name,
      TwitterAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.twitter.name,
      _ => null,
    };
    String? subtitle = switch (widget.provider) {
      EmailLinkAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.email.description,
      GoogleAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.google.description,
      AppleAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.apple.description,
      GithubAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.github.description,
      MicrosoftAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.microsoft.description,
      TwitterAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.twitter.description,
      _ => null,
    };
    return ListTile(
      leading: invertIconOnBrightnessChance && currentBrightness == Brightness.dark ? InvertColors(child: image) : image,
      title: title == null ? null : Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      enabled: widget.onTap != null,
      onTap: widget.onTap,
      trailing: widget.trailingIcon == null ? null : Icon(widget.trailingIcon),
    );
  }
}

/// Allows to change the dialog behavior.
enum DialogMode<T extends AuthenticationProviderPickerDialogResult> {
  /// Whether the user is trying to link an authentication provider.
  toggleLink<AuthenticationProviderToggleLinkResult>(
    shouldDisplay: _shouldDisplayInToggleLinkMode,
    getTrailingIcon: _getToggleLinkModeTrailingIcon,
    createAction: _createToggleLinkAction,
  ),

  /// Whether the user is trying to reauthenticate.
  reAuthenticate<AuthenticationProviderReAuthenticateResult>(
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

  /// Creates the [toggleLink] action.
  static AuthenticationProviderPickerDialogResult? _createToggleLinkAction(List<FirebaseAuthenticationProvider> currentProviders, FirebaseAuthenticationProvider provider) {
    if (provider is LinkProvider) {
      return AuthenticationProviderToggleLinkResult(
        provider: provider,
        link: !currentProviders.contains(provider),
      );
    }
    return null;
  }

  /// Creates the [reAuthenticate] action.
  static AuthenticationProviderPickerDialogResult? _createReAuthenticateAction(List<FirebaseAuthenticationProvider> currentProviders, FirebaseAuthenticationProvider provider) =>
      AuthenticationProviderReAuthenticateResult(
        provider: provider,
      );
}
