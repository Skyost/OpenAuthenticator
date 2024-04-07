import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/settings/show_intro.dart';
import 'package:open_authenticator/pages/home.dart';
import 'package:open_authenticator/pages/intro/slides/slide.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/step_progress_indicator.dart';

/// Shows an intro page, that explains what the app does to the user.
class IntroPage extends ConsumerStatefulWidget {
  /// The intro page name.
  static const String name = '/intro';

  /// Creates a new intro page instance.
  const IntroPage({
    super.key,
  });

  @override
  ConsumerState<IntroPage> createState() => IntroPageState();
}

/// The intro page state.
class IntroPageState extends ConsumerState<IntroPage> {
  /// The slides to display.
  List<IntroPageSlide> _slides = [];

  /// The current slide index.
  int _slideIndex = 0;

  /// Whether the "Next" button is enabled.
  bool _canGoToNextSlide = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      List<IntroPageSlide> slides = [];
      for (IntroPageSlideType type in IntroPageSlideType.values) {
        IntroPageSlide slide = type.create();
        if (await slide.shouldSkip(ref)) {
          continue;
        }
        slides.add(slide);
        if (mounted) {
          SvgAssetLoader loader = SvgAssetLoader(slide.imagePath);
          svg.cache.putIfAbsent(loader.cacheKey(context), () => loader.loadBytes(context));
        }
      }
      if (mounted) {
        setState(() {
          _slides = slides;
          if (slides.isNotEmpty) {
            _canGoToNextSlide = _slides.first.canSkip;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StepProgressIndicator(
                steps: _slides.length,
                currentStep: _slideIndex + 1,
              ),
              FilledButton.tonalIcon(
                onPressed: canGoToNextSlide
                    ? () {
                        if (hasFinished) {
                          _finish();
                        } else {
                          _goToNextSlide();
                        }
                      }
                    : null,
                icon: Icon(hasFinished ? Icons.check : Icons.navigate_next),
                label: Text(hasFinished ? translations.intro.button.finish : translations.intro.button.next),
              ),
            ],
          ),
        ),
        body: _slides.isEmpty
            ? const CenteredCircularProgressIndicator()
            : PageTransitionSwitcher(
                transitionBuilder: (child, primaryAnimation, secondaryAnimation) => SharedAxisTransition(
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: child,
                ),
                child: _slides[_slideIndex].createWidget(context, _slides.length - (_slideIndex + 1)),
              ),
      );

  /// Returns whether the intro is finished.
  bool get hasFinished => _slideIndex == _slides.length - 1;

  /// Returns whether the "Next" button is enabled.
  bool get canGoToNextSlide => _canGoToNextSlide;

  /// Sets whether the "Next" button is enabled.
  set canGoToNextSlide(bool canGoToNextSlide) {
    if (mounted) {
      setState(() => _canGoToNextSlide = canGoToNextSlide);
    } else {
      _canGoToNextSlide = canGoToNextSlide;
    }
  }

  /// Finishes the intro.
  Future<void> _finish() async {
    if (mounted) {
      _slides[_slideIndex].onGoToNextSlide(context, ref);
      Navigator.pushNamedAndRemoveUntil(context, HomePage.name, (_) => false);
      ref.read(showIntroSettingsEntryProvider.notifier).changeValue(false);
    }
  }

  /// Goes to the next slide.
  void _goToNextSlide() {
    if (mounted) {
      _slides[_slideIndex].onGoToNextSlide(context, ref);
      setState(() {
        _slideIndex++;
        _canGoToNextSlide = _slides[_slideIndex].canSkip;
      });
    }
  }
}
