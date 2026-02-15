import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:forui/forui.dart';

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
  final FScaffoldStyleDelta scaffoldStyle;

  /// Creates a new app scaffold instance.
  const AppScaffold({
    super.key,
    this.header,
    required this.children,
    this.footer,
    this.center = false,
    this.widgetBuilder = defaultWidgetBuilder,
    this.scaffoldStyle = const .context(),
  });

  /// Creates a new scrollable app scaffold instance.
  const AppScaffold.scrollable({
    super.key,
    this.header,
    required this.children,
    this.footer,
    this.center = false,
    this.widgetBuilder = defaultScrollableWidgetBuilder,
    this.scaffoldStyle = const .context(),
  });

  @override
  Widget build(BuildContext context) {
    Widget child = widgetBuilder.call(children);
    return FScaffold(
      scaffoldStyle: scaffoldStyle,
      childPad: false,
      header: header,
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
