import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/pages/intro/slides/slide.dart';
import 'package:open_authenticator/pages/settings/entries/synchronize.dart';
import 'package:open_authenticator/utils/account.dart';

/// The slide that allows the user to login to Firebase.
class LogInIntroPageSlide extends IntroPageSlide {
  /// Creates a new login intro page content instance.
  LogInIntroPageSlide()
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
            child: _LogInButton(),
          ),
          SynchronizeSettingsEntryWidget.intro(),
          IntroPageSlideParagraphWidget(text: translations.intro.logIn.thirdParagraph(limit: App.freeTotpsLimit.toString())),
          IntroPageSlideParagraphWidget(
            text: translations.intro.logIn.fourthParagraph(app: App.appName),
            padding: 0,
          ),
        ],
      );

  @override
  Future<bool> shouldSkip(WidgetRef ref) async {
    if (ref.read(userAuthenticationProviders.notifier).availableProviders.isEmpty) {
      return true;
    }
    TotpList totps = await ref.read(totpRepositoryProvider.future);
    if (totps.isNotEmpty) {
      return true;
    }
    return false;
  }
}

/// The log-in button.
class _LogInButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FirebaseAuthenticationState authenticationState = ref.watch(firebaseAuthenticationProvider);
    switch (authenticationState) {
      case FirebaseAuthenticationStateLoggedOut():
        return FilledButton.icon(
          onPressed: () => AccountUtils.trySignIn(context, ref),
          icon: const Icon(Icons.login),
          label: Text(translations.intro.logIn.button.loggedOut),
        );
      case FirebaseAuthenticationStateLoggedIn():
        return FilledButton.icon(
          onPressed: null,
          icon: const Icon(Icons.check),
          label: Text(translations.intro.logIn.button.loggedIn),
        );
    }
  }
}
