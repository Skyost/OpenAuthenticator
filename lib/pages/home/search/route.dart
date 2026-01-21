import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/pages/home/search/extension.dart';
import 'package:open_authenticator/widgets/app_scaffold.dart';
import 'package:open_authenticator/widgets/clickable.dart';
import 'package:open_authenticator/widgets/error.dart';
import 'package:open_authenticator/widgets/totp/widget.dart';

/// Shows a full screen search page and returns the search result selected by
/// the user when the page is closed.
/// Adapted from the Flutter library.
Future<Totp?> showTotpSearch(
  BuildContext context, {
  bool useRootNavigator = false,
  bool maintainState = false,
}) =>
    Navigator.of(
      context,
      rootNavigator: useRootNavigator,
    ).push(
      _SearchPageRoute(maintainState: maintainState),
    );

class _SearchPageRoute extends PageRoute<Totp> {
  @override
  final bool maintainState;

  _SearchPageRoute({
    required this.maintainState,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => FadeTransition(opacity: animation, child: child);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => Consumer(
    builder: (context, ref, child) {
      AsyncValue<TotpList> totps = ref.watch(totpRepositoryProvider);
      return switch (totps) {
        AsyncValue(:final value?) => _SearchPage(
          totps: value,
          animation: animation,
        ),
        AsyncError(:final error, :final stackTrace) => ErrorDisplayWidget(
          error: error,
          stackTrace: stackTrace,
        ),
        _ => const CircularProgressIndicator(),
      };
    },
  );
}

class _SearchPage extends StatefulWidget {
  final TotpList totps;
  final Animation<double> animation;

  const _SearchPage({
    required this.totps,
    required this.animation,
  });

  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<_SearchPage> {
  late final FocusNode focusNode = FocusNode(
    onKeyEvent: (FocusNode node, KeyEvent event) {
      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.pop(context);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    },
  );

  final FocusNode queryFocusNode = FocusNode();

  late final TextEditingController queryController = TextEditingController()
    ..addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => queryFocusNode.requestFocus());
    widget.animation.addStatusListener(onAnimationStatusChanged);
  }

  @override
  Widget build(BuildContext context) => AppScaffold.scrollable(
    header: FHeader.nested(
      prefixes: [
        ClickableHeaderAction.x(
          onPress: () => Navigator.pop(context),
        ),
      ],
      title: FTextField(
        suffixBuilder: (_, _, _) => ClickableButton.icon(
          style: FButtonStyle.ghost(),
          onPress: null,
          child: const Icon(FIcons.search),
        ),
        style: (style) => style.copyWith(
          filled: true,
          fillColor: context.theme.tileStyle.decoration.resolve({})?.color,
        ),
        control: .managed(controller: queryController),
        focusNode: queryFocusNode,
        hint: MaterialLocalizations.of(context).searchFieldLabel,
        onSubmit: (_) => queryFocusNode.unfocus(),
      ),
    ),
    children: buildResults(context),
  );

  @override
  void dispose() {
    super.dispose();
    widget.animation.removeStatusListener(onAnimationStatusChanged);
    focusNode.dispose();
    queryFocusNode.dispose();
    queryController.dispose();
  }

  List<Widget> buildResults(BuildContext context) {
    List<Totp> searchResults = widget.totps.search(queryController.text);
    List<Widget> result = [];
    for (int i = 0; i < searchResults.length; i++) {
      Totp totp = searchResults[i];
      result.add(
        TotpWidget(
          key: ValueKey(totp.uuid),
          totp: totp,
          onTap: (context) => Navigator.pop(context, totp),
        ),
      );
    }
    return result;
  }

  void onAnimationStatusChanged(AnimationStatus status) {
    if (!status.isCompleted) {
      return;
    }
    widget.animation.removeStatusListener(onAnimationStatusChanged);
    queryFocusNode.requestFocus();
  }
}
