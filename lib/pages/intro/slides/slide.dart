import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_authenticator/pages/intro/slides/log_in.dart';
import 'package:open_authenticator/pages/intro/slides/password.dart';
import 'package:open_authenticator/pages/intro/slides/welcome.dart';

/// A "slide" of the intro page.
class IntroPageSlide {
  /// The slide name.
  final String name;

  /// Creates a new intro page content instance.
  const IntroPageSlide({
    required this.name,
  });

  /// Whether this page content can be skipped.
  bool get canSkip => true;

  /// Whether this page content should be skipped.
  Future<bool> shouldSkip(WidgetRef ref) => Future.value(false);

  /// Returns the image SVG path.
  String get imagePath => 'assets/images/intro/$name.svg';

  /// Triggered when the user clicks on "Next".
  Future<bool> onGoToNextSlide(BuildContext context, WidgetRef ref) => Future.value(true);

  /// Creates the widget for showing this slide.
  Widget createWidget(BuildContext context, int remainingSteps) => IntroPageSlideWidget(
        slide: this,
      );
}

/// Contains all intro page slide types.
enum IntroPageSlideType {
  /// The very first slide shown to the user.
  welcome(create: WelcomeIntroPageSlide.new),

  /// The slide that allows the user to login to Firebase.
  login(create: LoginIntroPageSlide.new),

  /// The slide that allows the user to define a master password.
  password(create: PasswordIntroPageSlide.new);

  /// Allows to create a new intro page slide instance.
  final IntroPageSlide Function() create;

  /// Creates a new intro page slide type instance.
  const IntroPageSlideType({
    required this.create,
  });
}

/// An intro page slide widget.
class IntroPageSlideWidget extends StatefulWidget {
  /// The slide instance.
  final IntroPageSlide slide;

  /// The title widget.
  final Widget titleWidget;

  /// The children.
  final List<Widget> children;

  /// Creates a new intro page slide widget instance.
  IntroPageSlideWidget({
    super.key,
    Widget? titleWidget,
    required this.slide,
    this.children = const [],
  }) : titleWidget = titleWidget ??
            IntroPageSlideTitleWidget(
              slide: slide,
            );

  @override
  State<StatefulWidget> createState() => IntroPageSlideWidgetState();
}

/// An intro page slide widget state.
class IntroPageSlideWidgetState extends State<IntroPageSlideWidget> with TickerProviderStateMixin {
  /// The title animation controller.
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..forward();

  /// The title animation.
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );

  @override
  Widget build(BuildContext context) => DefaultTextStyle.merge(
        style: TextStyle(color: Colors.grey.shade700),
        textAlign: TextAlign.center,
        child: Center(
          child: ListView(
            padding: const EdgeInsets.all(20),
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: DefaultTextStyle.merge(
                  child: widget.titleWidget,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: FadeScaleTransition(
                  animation: _animation,
                  child: SizedBox(
                    height: 200,
                    child: SvgPicture.asset(
                      widget.slide.imagePath,
                    ),
                  ),
                ),
              ),
              for (int i = 0; i < widget.children.length; i++) //
                i == widget.children.length - 1 && widget.children[i] is IntroPageSlideParagraphWidget ? (widget.children[i] as IntroPageSlideParagraphWidget).withoutPadding : widget.children[i],
            ],
          ),
        ),
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// A classic title widget.
class IntroPageSlideTitleWidget extends StatelessWidget {
  /// The slide instance.
  final IntroPageSlide slide;

  /// Creates an title widget instance.
  const IntroPageSlideTitleWidget({
    super.key,
    required this.slide,
  });

  @override
  Widget build(BuildContext context) => Text(slide.name);
}

/// A paragraph text, with a separator.
class IntroPageSlideParagraphWidget extends StatelessWidget {
  /// The paragraph padding.
  static const double kDefaultPadding = 10;

  /// The text to display.
  final String text;

  /// The text style.
  final TextStyle? textStyle;

  /// The bottom padding.
  final double padding;

  /// Creates a paragraph text, with a separator.
  const IntroPageSlideParagraphWidget({
    super.key,
    required this.text,
    this.textStyle,
    this.padding = kDefaultPadding,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: padding),
        child: Text(
          text,
          style: textStyle,
        ),
      );

  /// Returns the same paragraph without padding.
  IntroPageSlideParagraphWidget get withoutPadding => IntroPageSlideParagraphWidget(
        text: text,
        textStyle: textStyle,
        padding: 0,
      );
}
