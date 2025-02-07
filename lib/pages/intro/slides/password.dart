import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/pages/intro/page.dart';
import 'package:open_authenticator/pages/intro/slides/slide.dart';
import 'package:open_authenticator/pages/settings/entries/save_derived_key.dart';
import 'package:open_authenticator/widgets/form/master_password_form.dart';

/// The slide that allows the user to define a master password.
class PasswordIntroPageSlide extends IntroPageSlide {
  /// The currently chosen password.
  String? _password;

  /// Creates a new password intro page content instance.
  PasswordIntroPageSlide()
      : super(
          name: 'password',
        );

  @override
  bool get canSkip => false;

  @override
  Widget createWidget(BuildContext context, int remainingSteps) => IntroPageSlideWidget(
        titleWidget: Text(translations.intro.password.title),
        slide: this,
        children: [
          IntroPageSlideParagraphWidget(text: translations.intro.password.firstParagraph),
          Padding(
            padding: const EdgeInsets.only(bottom: IntroPageSlideParagraphWidget.kDefaultPadding),
            child: _MasterPasswordForm(
              onChanged: (password) => _password = password,
            ),
          ),
          SaveDerivedKeySettingsEntryWidget.intro(),
          IntroPageSlideParagraphWidget(text: translations.intro.password.secondParagraph),
          IntroPageSlideParagraphWidget(
            text: translations.intro.password.thirdParagraph,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      );

  @override
  Future<bool> shouldSkip(WidgetRef ref) async => (await ref.read(cryptoStoreProvider.future)) != null;

  @override
  Future<bool> onGoToNextSlide(BuildContext context, WidgetRef ref) async {
    if (_password == null) {
      return false;
    }
    StoredCryptoStore currentCryptoStore = ref.read(cryptoStoreProvider.notifier);
    await currentCryptoStore.changeCryptoStore(_password!);
    return true;
  }
}

/// Prompts the master password.
class _MasterPasswordForm extends StatefulWidget {
  /// Triggered when the password has changed.
  /// This will either be a full password, or `null`.
  final ValueChanged<String?>? onChanged;

  /// Creates a new master password form instance.
  /// This will either be a full password, or a blank string.
  const _MasterPasswordForm({
    this.onChanged,
  });

  @override
  State<StatefulWidget> createState() => _MasterPasswordFormState();
}

/// The master password form state.
class _MasterPasswordFormState extends State<_MasterPasswordForm> {
  /// The form key.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => MasterPasswordForm(
        formKey: formKey,
        onFormChanged: formKey.currentState?.validate,
        onChanged: (password) {
          widget.onChanged?.call(password);
          findState(context)?.canGoToNextSlide = password != null;
        },
      );

  /// Finds the intro page state.
  IntroPageState? findState(BuildContext context) => context.findAncestorStateOfType<IntroPageState>();
}
