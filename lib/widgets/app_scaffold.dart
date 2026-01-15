import 'dart:async';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:open_authenticator/spacing.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/clickable.dart';
import 'package:open_authenticator/widgets/error.dart';
import 'package:window_manager/window_manager.dart';

/// Builds a list of widgets from an async value.
List<Widget> buildAppScaffoldChildrenFromAsyncValue<T>({
  required BuildContext context,
  required AsyncValue<T> value,
  required List<Widget> Function(BuildContext, T) builder,
  List<Widget> Function(Object, StackTrace)? errorBuilder,
  VoidCallback? onRetryPressed,
}) => switch (value) {
  AsyncData() => builder(context, value.value),
  AsyncLoading() => [
    const CenteredCircularProgressIndicator(),
  ],
  AsyncError(:final error, :final stackTrace) =>
    errorBuilder?.call(error, stackTrace) ??
        [
          ErrorDetails(
            error: error,
            stackTrace: stackTrace,
            onRetryPressed: onRetryPressed,
          ),
        ],
};

/// Allows to build a scaffold with a refresh indicator.
Widget Function(List<Widget> children) scrollableWidgetWithRefreshIndicator({
  required AsyncCallback onRefresh,
}) =>
    (children) => CustomRefreshIndicator(
      onRefresh: onRefresh,
      builder: (context, child, controller) {
        double iconSize = 30;
        return Stack(
          alignment: Alignment.center,
          children: [
            if (!controller.isIdle)
              Positioned(
                top: 35 * controller.value,
                left: context.theme.style.pagePadding.left,
                right: context.theme.style.pagePadding.right,
                child: controller.isLoading
                    ? FCircularProgress(
                        style: (style) => style.copyWith(
                          iconStyle: style.iconStyle.copyWith(size: iconSize),
                        ),
                      )
                    : Icon(
                        FIcons.loaderCircle,
                        size: iconSize,
                      ),
              ),
            Transform.translate(
              offset: Offset(0, 3 * iconSize * controller.value),
              child: child,
            ),
          ],
        );
      },
      child: ScrollConfiguration(
        behavior: _ScrollBehavior(),
        child: Builder(
          builder: (context) => ListView(
            padding: context.theme.style.pagePadding,
            children: children,
          ),
        ),
      ),
    );

/// Scaffold for the app.
class AppScaffold extends StatelessWidget {
  /// The header of the scaffold.
  final Widget? header;

  /// The children of the scaffold.
  final List<Widget> children;

  /// The footer of the scaffold.
  final Widget? footer;

  /// Whether to center the list.
  final bool center;

  /// Builds a list of widgets.
  final Widget Function(List<Widget> children) widgetBuilder;

  /// The scaffold style.
  final FScaffoldStyle Function(FScaffoldStyle style)? scaffoldStyle;

  /// Creates a new app scaffold instance.
  const AppScaffold({
    super.key,
    this.header,
    required this.children,
    this.footer,
    this.center = false,
    this.widgetBuilder = defaultWidgetBuilder,
    this.scaffoldStyle,
  });

  /// Creates a new scrollable app scaffold instance.
  const AppScaffold.scrollable({
    super.key,
    this.header,
    required this.children,
    this.footer,
    this.center = false,
    this.widgetBuilder = defaultScrollableWidgetBuilder,
    this.scaffoldStyle,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = widgetBuilder.call(children);
    return FScaffold(
      scaffoldStyle: scaffoldStyle,
      childPad: false,
      header: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentPlatform.isDesktop)
            Padding(
              padding: const EdgeInsets.all(kSpace),
              child: _DragArea(),
            ),
          if (header != null) header!,
        ],
      ),
      footer: footer,
      child: center
          ? Center(
              child: child,
            )
          : child,
    );
  }

  /// Builds the non-scrollable widget.
  static Widget defaultWidgetBuilder(List<Widget> children) => children.length == 1
      ? children.first
      : Column(
          mainAxisSize: .min,
          children: children,
        );

  /// Builds the scrollable widget.
  static Widget defaultScrollableWidgetBuilder(List<Widget> children) => children.length == 1
      ? Builder(
          builder: (context) {
            return SingleChildScrollView(
              padding: context.theme.style.pagePadding,
              child: children.first,
            );
          },
        )
      : Builder(
          builder: (context) {
            return ListView(
              shrinkWrap: true,
              padding: context.theme.style.pagePadding,
              children: children,
            );
          },
        );
}

/// Drag area for the app.
class _DragArea extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DragAreaState();
}

/// The drag area widget state.
class _DragAreaState extends State<_DragArea> with WindowListener {
  /// Whether the drag area is loading.
  bool isLoading = false;

  /// Whether the window is maximized.
  bool? isMaximized;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool isMaximized = await windowManager.isMaximized();
      if (mounted) {
        setState(() => this.isMaximized = isMaximized);
      }
    });
    windowManager.addListener(this);
  }

  @override
  Widget build(BuildContext context) => DragToMoveArea(
    child: SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: kSpace / 2,
        runSpacing: kSpace / 2,
        children: [
          ClickableButton.icon(
            style: FButtonStyle.secondary(),
            onPress: windowManager.minimize,
            child: Transform.translate(
              offset: const Offset(0, 5),
              child: Icon(
                FIcons.minus,
                size: context.theme.typography.sm.fontSize,
              ),
            ),
          ),
          if (isMaximized == true)
            ClickableButton.icon(
              style: FButtonStyle.secondary(),
              onPress: () => doFuture(windowManager.unmaximize),
              child: Transform.flip(
                flipX: true,
                child: Icon(
                  FIcons.copy,
                  size: context.theme.typography.sm.fontSize,
                ),
              ),
            )
          else
            ClickableButton.icon(
              style: FButtonStyle.secondary(),
              onPress: isMaximized == null ? null : () => doFuture(windowManager.maximize),
              child: Icon(
                FIcons.square,
                size: context.theme.typography.sm.fontSize,
              ),
            ),
          ClickableButton.icon(
            style: FButtonStyle.destructive(),
            onPress: () => doFuture(windowManager.close),
            child: Icon(
              FIcons.x,
              size: context.theme.typography.sm.fontSize,
            ),
          ),
        ],
      ),
    ),
  );

  /// Executes the given future and sets the loading state accordingly.
  void doFuture<T>(Future<T> Function() future) async {
    setState(() => isLoading = true);
    await future();
    if (mounted) {
      setState(() => isLoading = true);
    }
  }

  @override
  void onWindowMaximize() {
    super.onWindowMaximize();
    if (mounted) {
      setState(() => isMaximized = true);
    }
  }

  @override
  void onWindowUnmaximize() {
    super.onWindowUnmaximize();
    if (mounted) {
      setState(() => isMaximized = false);
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }
}

/// Allows to display a refresh indicator on desktop platforms as well.
class _ScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => kDebugMode
      ? {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        }
      : super.dragDevices;
}
