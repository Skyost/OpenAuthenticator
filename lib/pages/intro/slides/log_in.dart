import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/provider.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/pages/intro/slides/slide.dart';
import 'package:open_authenticator/pages/settings/entries/synchronize.dart';
import 'package:open_authenticator/utils/account.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';

/// The slide that allows the user to login to Firebase.
class LoginIntroPageSlide extends IntroPageSlide {
  /// Creates a new login intro page content instance.
  LoginIntroPageSlide()
      : super(
          name: 'logIn',
        );

  @override
  Widget createWidget(BuildContext context, int remainingSteps) => IntroPageSlideWidget(
        titleWidget: Text(translations.intro.logIn.title),
        slide: this,
        children: [
          IntroPageSlideParagraphWidget(text: translations.intro.logIn.firstParagraph),
          IntroPageSlideParagraphWidget(
            text: translations.intro.logIn.secondParagraph,
            textStyle: const TextStyle(fontStyle: FontStyle.italic),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: IntroPageSlideParagraphWidget.kDefaultPadding),
            child: _LoginButton(),
          ),
          SynchronizeSettingsEntryWidget.intro(),
          IntroPageSlideParagraphWidget(text: translations.intro.logIn.thirdParagraph),
          IntroPageSlideParagraphWidget(
            text: translations.intro.logIn.fourthParagraph(app: App.appName),
            padding: 0,
          ),
        ],
      );

  @override
  Future<bool> shouldSkip(WidgetRef ref) async {
    if (FirebaseAuthenticationProvider.availableProviders.isEmpty) {
      return true;
    }
    List<Totp> totps = await ref.read(totpRepositoryProvider.future);
    if (totps.isNotEmpty) {
      return true;
    }
    FirebaseAuthenticationState state = await ref.read(firebaseAuthenticationProvider.future);
    return state is! FirebaseAuthenticationStateLoggedOut;
  }
}

/// The login button.
class _LoginButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<FirebaseAuthenticationState> authenticationState = ref.watch(firebaseAuthenticationProvider);
    switch (authenticationState) {
      case AsyncData(:final value):
        String label;
        IconData icon;
        bool canLogin = false;
        switch (value) {
          case FirebaseAuthenticationStateLoggedOut():
            label = translations.intro.logIn.button.loggedOut;
            icon = Icons.login;
            canLogin = true;
            break;
          case FirebaseAuthenticationStateWaitingForConfirmation():
            label = translations.intro.logIn.button.waitingForConfirmation;
            icon = Icons.hourglass_bottom;
            break;
          case FirebaseAuthenticationStateLoggedIn():
            label = translations.intro.logIn.button.loggedIn;
            icon = Icons.check;
            break;
        }
        return FilledButton.icon(
          onPressed: canLogin ? () => AccountUtils.trySignIn(context, ref) : null,
          icon: Icon(icon),
          label: Text(label),
        );
      case AsyncError():
        return FilledButton.icon(
          onPressed: null,
          icon: const Icon(Icons.error_outline),
          label: Text(translations.intro.logIn.button.error),
        );
      case _:
        return const CenteredCircularProgressIndicator();
    }
  }
}
