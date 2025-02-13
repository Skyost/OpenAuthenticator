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
import 'package:open_authenticator/utils/form_label.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/app_filled_button.dart';
import 'package:open_authenticator/widgets/authentication_provider_image.dart';
import 'package:open_authenticator/widgets/dialog/app_dialog.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';
import 'package:open_authenticator/widgets/divider_text.dart';
import 'package:open_authenticator/widgets/list/list_tile_padding.dart';

/// Allows to sign in in the user.
class SignInDialog extends ConsumerStatefulWidget {
  /// Creates a new sign-in dialog instance.
  const SignInDialog({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignInDialogState();

  /// Opens the dialog.
  static Future<SignInDialogResult?> openDialog(BuildContext context) => showDialog<SignInDialogResult>(
        context: context,
        builder: (context) => SignInDialog(),
      );
}

/// The sign-in dialog state.
class _SignInDialogState extends ConsumerState<SignInDialog> {
  @override
  Widget build(BuildContext context) => AppDialog(
        title: Text(translations.authentication.signInDialog.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
        ],
        children: [
          ListTilePadding(
            bottom: 20,
            child: _EmailForm(
              onEmailValidated: (provider, email) {
                Navigator.pop(
                  context,
                  SignInDialogResult(
                    provider: provider,
                    signIn: (context, provider) => (provider as EmailLinkAuthenticationProvider).signIn(context, email: email),
                  ),
                );
              },
            ),
          ),
          ListTilePadding(
            bottom: 20,
            child: DividerText(
              text: Text(translations.authentication.signInDialog.separator),
            ),
          ),
          ListTilePadding(
            child: _OtherProvidersWrap(
              onProviderSelected: (provider) {
                Navigator.pop(
                  context,
                  SignInDialogResult(
                    provider: provider,
                    signIn: (context, provider) => provider.signIn(context),
                  ),
                );
              },
            ),
          ),
        ],
      );
}

/// Represents a sign-in action.
typedef SignIn = Future<Result<AuthenticationObject>> Function(BuildContext context, FirebaseAuthenticationProvider provider);

/// Represents a sign-in dialog action.
class SignInDialogResult {
  /// The provider.
  final FirebaseAuthenticationProvider provider;

  /// The action.
  final SignIn signIn;

  /// Creates a new sign-in dialog result instance.
  const SignInDialogResult({
    required this.provider,
    required this.signIn,
  });
}

/// Displays the email form.
class _EmailForm extends ConsumerStatefulWidget {
  /// Triggered when an email has been validated.
  final Function(EmailLinkAuthenticationProvider, String) onEmailValidated;

  /// Creates a new email form instance.
  const _EmailForm({
    required this.onEmailValidated,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EmailFormState();
}

/// The email form state.
class _EmailFormState extends ConsumerState<_EmailForm> {
  /// The email.
  String email = '';

  @override
  Widget build(BuildContext context) {
    String? emailToConfirm = ref.watch(emailLinkConfirmationStateProvider).valueOrNull;
    Map<FirebaseAuthenticationProvider, FirebaseAuthenticationState> providers = ref.watch(userAuthenticationProviders);
    FirebaseAuthenticationState? emailAuthenticationState = providers.getAuthenticationState<EmailLinkAuthenticationProvider>();
    bool canAuthenticateByEmail =
        emailToConfirm == null && emailAuthenticationState is FirebaseAuthenticationStateLoggedOut && providers.availableProviders.whereType<EmailLinkAuthenticationProvider>().isNotEmpty;
    Widget child = Text(translations.authentication.signInDialog.email.button);
    String description = canAuthenticateByEmail ? translations.authentication.signInDialog.email.description.signIn : translations.authentication.signInDialog.email.description.cannotUse;
    if (emailToConfirm != null) {
      description = translations.authentication.signInDialog.email.description.waitingForConfirmation;
    } else if (emailAuthenticationState is FirebaseAuthenticationStateLoggedIn) {
      child = _ButtonChildWithAuthenticatedBadge(child: child);
      description = translations.authentication.signInDialog.email.description.alreadySignedIn;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: TextFormField(
            enabled: canAuthenticateByEmail,
            onChanged: (value) {
              setState(() => email = value);
            },
            decoration: FormLabelWithIcon(
              icon: Icons.email,
              text: translations.authentication.signInDialog.email.title,
              hintText: emailToConfirm ??
                  (emailAuthenticationState is FirebaseAuthenticationStateLoggedIn ? emailAuthenticationState.user.email : null) ??
                  translations.authentication.signInDialog.email.hint,
            ),
            textInputAction: TextInputAction.done,
            validator: TextInputDialog.validateEmail,
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Align(
            alignment: Alignment.topRight,
            child: Text(
              description,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.right,
            ),
          ),
        ),
        AppFilledButton(
          icon: Icon(Icons.send),
          onPressed: email.trim().isNotEmpty && TextInputDialog.validateEmail(email) == null ? (() => onEmailChosen(providers.getProvider<EmailLinkAuthenticationProvider>())) : null,
          label: child,
        ),
      ],
    );
  }

  /// Sends a mail confirmation.
  Future<void> onEmailChosen(EmailLinkAuthenticationProvider provider) async {
    if (TextInputDialog.validateEmail(email) == null) {
      widget.onEmailValidated(provider, email);
    }
  }
}

/// Allows to display other providers.
class _OtherProvidersWrap extends ConsumerWidget {
  /// Triggered when a provider has been selected.
  final Function(FirebaseAuthenticationProvider) onProviderSelected;

  /// The circle button size.
  final double circleButtonSize;

  /// The space between two circle buttons.
  final double circleButtonSpace;

  /// A circle button inner padding.
  final double circleButtonPadding;

  /// Creates a new others providers wrap instance.
  const _OtherProvidersWrap({
    required this.onProviderSelected,
    this.circleButtonSize = 30,
    this.circleButtonSpace = 10,
    this.circleButtonPadding = 20,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<FirebaseAuthenticationProvider> providers = ref.watch(userAuthenticationProviders).availableProviders;
    providers.removeWhere((provider) => provider is EmailLinkAuthenticationProvider);
    double circleLineWidth = providers.length * (circleButtonSize + circleButtonSpace * 2 + circleButtonPadding * 2);
    return LayoutBuilder(
      builder: (context, constraints) => circleLineWidth <= constraints.maxWidth && providers.length >= 3
          ? Wrap(
              alignment: WrapAlignment.center,
              spacing: circleButtonSpace,
              children: [
                for (FirebaseAuthenticationProvider provider in providers)
                  _ProviderCircleButton(
                    onTapIfLoggedOut: () => onProviderSelected(provider),
                    provider: provider,
                    size: circleButtonSize,
                    padding: EdgeInsets.all(circleButtonPadding),
                  ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < providers.length; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: i < providers.length - 1 ? 10 : 0),
                    child: _ProviderButton(
                      onTapIfLoggedOut: () => onProviderSelected(providers[i]),
                      provider: providers[i],
                    ),
                  ),
              ],
            ),
    );
  }
}

/// A circle button that allows to choose a provider.
class _ProviderCircleButton extends ConsumerWidget {
  /// The provider.
  final FirebaseAuthenticationProvider provider;

  /// The button size.
  final double size;

  /// The button padding.
  final EdgeInsets padding;

  /// Triggered when tapped on (only if user is logged out for the selected provider).
  final VoidCallback? onTapIfLoggedOut;

  /// Creates a new provider button instance.
  const _ProviderCircleButton({
    required this.provider,
    required this.size,
    required this.padding,
    this.onTapIfLoggedOut,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FirebaseAuthenticationState? state = ref.watch(userAuthenticationProviders.select((providers) => providers[provider]));
    Widget button = Tooltip(
      message: switch (provider) {
        EmailLinkAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.email.name,
        GoogleAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.google.name,
        AppleAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.apple.name,
        GithubAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.github.name,
        MicrosoftAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.microsoft.name,
        TwitterAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.twitter.name,
        _ => null,
      },
      child: FilledButton.tonal(
        onPressed: state is FirebaseAuthenticationStateLoggedOut ? onTapIfLoggedOut : null,
        style: FilledButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(20),
          backgroundColor: Colors.white,
        ),
        child: FirebaseAuthenticationProviderImage(
          provider: provider,
          width: size,
          height: size,
        ),
      ),
    );
    if (state is FirebaseAuthenticationStateLoggedIn) {
      button = _AuthenticatedBadge(
        offset: Offset(-padding.right / 2, 0),
        child: button,
      );
    }
    return button;
  }
}

/// A button that allows to choose a provider.
class _ProviderButton extends ConsumerWidget {
  /// The provider.
  final FirebaseAuthenticationProvider provider;

  /// Triggered when tapped on (only if user is logged out for the selected provider).
  final VoidCallback? onTapIfLoggedOut;

  /// Creates a new provider button instance.
  const _ProviderButton({
    required this.provider,
    this.onTapIfLoggedOut,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FirebaseAuthenticationState? state = ref.watch(userAuthenticationProviders.select((providers) => providers[provider]));
    String? title = switch (provider) {
      EmailLinkAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.email.name,
      GoogleAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.google.name,
      AppleAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.apple.name,
      GithubAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.github.name,
      MicrosoftAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.microsoft.name,
      TwitterAuthenticationProvider() => translations.authentication.firebaseAuthenticationProvider.twitter.name,
      _ => null,
    };
    Widget child = title == null ? SizedBox.shrink() : Text(title);
    if (state is FirebaseAuthenticationStateLoggedIn) {
      child = _ButtonChildWithAuthenticatedBadge(
        child: child,
      );
    }
    return AppFilledButton(
      onPressed: state is FirebaseAuthenticationStateLoggedOut ? onTapIfLoggedOut : null,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      icon: FirebaseAuthenticationProviderImage(
        provider: provider,
        width: 16,
        height: 16,
      ),
      label: child,
    );
  }
}

/// Allows to display an [_AuthenticatedBadge] in a [AppFilledButton].
class _ButtonChildWithAuthenticatedBadge extends StatelessWidget {
  /// The child.
  final Widget child;

  /// Creates a new button child with authenticated badge instance.
  const _ButtonChildWithAuthenticatedBadge({
    required this.child,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => _AuthenticatedBadge(
          alignment: Alignment.topCenter,
          offset: Offset(constraints.maxWidth / 2 + 7, -7),
          child: child,
        ),
      );
}

/// Displays a badge indicating the user already has the current provider.
class _AuthenticatedBadge extends StatelessWidget {
  /// The badge offset.
  final Offset? offset;

  /// The alignment.
  final AlignmentGeometry? alignment;

  /// The widget child.
  final Widget child;

  /// Creates a new authenticated badge instance.
  const _AuthenticatedBadge({
    this.offset,
    this.alignment,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Badge(
        offset: offset,
        alignment: alignment,
        label: Icon(
          Icons.check,
          color: Colors.white,
        ),
        backgroundColor: Colors.green.shade700,
        textColor: Colors.white,
        child: child,
      );
}
