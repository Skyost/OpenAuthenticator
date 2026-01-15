import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:open_authenticator/spacing.dart';
import 'package:open_authenticator/utils/brightness_listener.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/widgets/clickable.dart';

/// A scrollable full-width app-styled and adaptive alert dialog.
class AppDialog extends StatelessWidget {
  /// The classic content padding.
  static const EdgeInsets kDefaultContentPadding = EdgeInsets.symmetric(
    vertical: kSpace,
    horizontal: kBigSpace,
  );

  /// The dialog style.
  final FDialogStyle? style;

  /// The dialog animation.
  final Animation<double>? animation;

  /// The dialog title.
  final Widget? title;

  /// Whether to ellipsis title on overflow.
  final bool? ellipsisTitleOnOverflow;

  /// The dialog children.
  final List<Widget> children;

  /// The dialog actions.
  final List<Widget>? actions;

  /// Whether to display a close button.
  final bool? displayCloseButton;

  /// The content padding.
  final EdgeInsets? contentPadding;

  /// Whether to put the content in a [ListView] instead of a [Column].
  final bool scrollable;

  /// Creates a new app dialog instance.
  const AppDialog({
    super.key,
    this.style,
    this.animation,
    this.title,
    this.ellipsisTitleOnOverflow,
    this.children = const [],
    this.actions,
    this.displayCloseButton,
    this.contentPadding,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsets? listViewPadding = contentPadding;
    if (listViewPadding == null) {
      listViewPadding = kDefaultContentPadding;
      if (title != null && currentPlatform.isMobile) {
        listViewPadding = listViewPadding.copyWith(top: 0);
      }
    }
    List<Widget> children = [
      for (int i = 0; i < this.children.length; i++)
        Padding(
          padding: listViewPadding.copyWith(
            top: i == 0 ? null : kSpace / 2,
            bottom: i == this.children.length - 1 ? null : kSpace / 2,
          ),
          child: this.children[i],
        ),
    ];
    return FDialog.adaptive(
      title: Transform.translate(
        offset: const Offset(0, -1),
        child: _AppDialogTitle(
          title: title!,
          ellipsisTitleOnOverflow: ellipsisTitleOnOverflow,
          displayCloseButton: displayCloseButton,
        ),
      ),
      body: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: scrollable
            ? ListView(
                shrinkWrap: true,
                children: children,
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
      ),
      style: (style) => (this.style ?? style).copyWith(
        horizontalStyle: (horizontalStyle) => horizontalStyle.copyWith(
          padding: EdgeInsets.zero,
        ),
        verticalStyle: (verticalStyle) => verticalStyle.copyWith(
          padding: EdgeInsets.zero,
        ),
      ),
      animation: animation,
      actions: [
        for (int i = 0; i < (actions?.length ?? 0); i++)
          _AdaptiveActionPadding(
            actionIndex: i,
            actionsCount: actions!.length,
            action: actions![i],
          ),
      ],
    );
  }
}

class _AdaptiveActionPadding extends StatelessWidget {
  final int actionIndex;
  final int actionsCount;
  final Widget action;
  final double gap;
  final double additionalGap;

  const _AdaptiveActionPadding({
    super.key,
    required this.actionIndex,
    required this.actionsCount,
    required this.action,
    this.gap = kSpace / 2,
    this.additionalGap = kBigSpace,
  });

  @override
  Widget build(BuildContext context) => switch (MediaQuery.sizeOf(context).width) {
    final width when width < context.theme.breakpoints.sm => Padding(
      padding: EdgeInsets.only(
        top: actionIndex == 0 ? (gap + additionalGap) : gap,
        right: gap + additionalGap,
        bottom: actionIndex == actionsCount - 1 ? (gap + additionalGap) : gap,
        left: gap + additionalGap,
      ),
      child: action,
    ),
    _ => Padding(
      padding: EdgeInsets.only(
        top: gap + additionalGap,
        right: actionIndex == actionsCount - 1 ? (gap + additionalGap) : gap,
        bottom: gap + additionalGap,
        left: actionIndex == 0 ? (gap + additionalGap) : gap,
      ),
      child: action,
    ),
  };
}

/// The app dialog title widget.
class _AppDialogTitle extends ConsumerStatefulWidget {
  /// The dialog title.
  final Widget title;

  /// Whether to ellipsis title on overflow.
  final bool? ellipsisTitleOnOverflow;

  /// Whether to display a close button.
  final bool? displayCloseButton;

  /// Creates a new app dialog title instance.
  const _AppDialogTitle({
    required this.title,
    this.ellipsisTitleOnOverflow,
    this.displayCloseButton,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppDialogTitleState();
}

/// The app dialog title state.
class _AppDialogTitleState extends ConsumerState<_AppDialogTitle> with BrightnessListener {
  @override
  Widget build(BuildContext context) {
    Widget child = widget.title;
    if (currentPlatform.isDesktop && widget.displayCloseButton != false) {
      child = Row(
        children: [
          Expanded(child: child),
          Tooltip(
            message: MaterialLocalizations.of(context).closeButtonLabel,
            child: ClickableButton.icon(
              style: currentBrightness == Brightness.dark ? FButtonStyle.secondary() : FButtonStyle.ghost(),
              child: Icon(
                FIcons.x,
                color: textColor?.withValues(alpha: 0.75),
              ),
              onPress: () => Navigator.pop(context),
            ),
          ),
        ],
      );
    }
    return Container(
      padding: AppDialog.kDefaultContentPadding,
      decoration: boxDecoration,
      child: DefaultTextStyle(
        style: context.theme.typography.lg.copyWith(color: textColor),
        maxLines: widget.ellipsisTitleOnOverflow != false ? null : 1,
        overflow: widget.ellipsisTitleOnOverflow != false ? TextOverflow.clip : TextOverflow.ellipsis,
        child: child,
      ),
    );
  }

  /// Returns the text color.
  Color? get textColor => currentPlatform.isMobile ? null : Colors.white;

  /// Creates the box decoration.
  BoxDecoration? get boxDecoration => BoxDecoration(
    borderRadius: context.theme.style.borderRadius.copyWith(
      bottomLeft: Radius.zero,
      bottomRight: Radius.zero,
    ),
    color: currentPlatform.isMobile || currentBrightness == Brightness.dark ? null : context.theme.colors.primary,
  );
}
