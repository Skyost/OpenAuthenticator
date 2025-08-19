import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/utils/brightness_listener.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/widgets/list/expand_list_tile.dart';
import 'package:open_authenticator/widgets/list/list_tile_padding.dart';

/// The classic content dialog padding on mobile.
const EdgeInsets kClassicContentDialogPaddingMobile = EdgeInsets.symmetric(
  vertical: 12,
  horizontal: 24,
);

/// The classic content dialog padding on desktop.
const EdgeInsets kClassicContentDialogPaddingDesktop = EdgeInsets.symmetric(
  vertical: 12,
  horizontal: 24,
);

/// The classic list dialog padding on mobile.
const EdgeInsets kClassicChoiceDialogPaddingMobile = EdgeInsets.zero;

/// The classic list dialog padding on desktop.
const EdgeInsets kClassicChoiceDialogPaddingDesktop = EdgeInsets.symmetric(
  vertical: 12,
  horizontal: 0,
);

/// A scrollable full-width app-styled and adaptive alert dialog.
class AppDialog extends StatelessWidget {
  /// The classic content padding.
  static final EdgeInsets classicContentDialogPadding = currentPlatform.isMobile ? kClassicContentDialogPaddingMobile : kClassicContentDialogPaddingDesktop;

  /// The classic content padding.
  static final EdgeInsets classicChoiceDialogPadding = currentPlatform.isMobile ? kClassicChoiceDialogPaddingMobile : kClassicChoiceDialogPaddingDesktop;

  /// The dialog title.
  final Widget? title;

  /// Whether to ellipsis title on overflow.
  final bool? ellipsisTitleOnOverflow;

  /// The dialog children.
  final List<Widget> children;

  /// The dialog actions.
  final List<Widget>? actions;

  /// The dialog border radius.
  final double borderRadius;

  /// Whether to display a close button.
  final bool? displayCloseButton;

  /// The content padding.
  final EdgeInsets? contentPadding;

  /// Whether to put the content in a [ListView] instead of a [Column].
  final bool scrollable;

  /// Creates a new app dialog instance.
  const AppDialog({
    super.key,
    this.title,
    this.ellipsisTitleOnOverflow,
    this.children = const [],
    this.actions,
    this.borderRadius = 28,
    this.displayCloseButton,
    this.contentPadding,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsets? listViewPadding = contentPadding;
    int listTileCount = this.children.where((child) => child is ListTile || child is ListTilePadding || child is ExpandListTile).length;
    bool isListDialog = listTileCount == this.children.length;
    if (listViewPadding == null) {
      if (isListDialog) {
        listViewPadding = classicChoiceDialogPadding;
      } else {
        listViewPadding = classicContentDialogPadding;
      }
      if (title != null && currentPlatform.isMobile) {
        listViewPadding = listViewPadding.copyWith(top: 0);
      }
    }
    List<Widget> children = [
      for (int i = 0; i < this.children.length; i++)
        Padding(
          padding: listViewPadding.copyWith(top: i == 0 ? null : 0, bottom: i == this.children.length - 1 ? null : 0),
          child: this.children[i],
        ),
    ];
    children = [
      if (title != null)
        Transform.translate(
          offset: const Offset(0, -1),
          child: _AppDialogTitle(
            title: title!,
            ellipsisTitleOnOverflow: ellipsisTitleOnOverflow,
            displayCloseButton: displayCloseButton,
            borderRadius: borderRadius,
          ),
        ),
      ...children,
    ];
    Widget dialog = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(borderRadius),
        ),
      ),
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
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
      actions: actions,
    );
    ThemeData theme = Theme.of(context);
    return isListDialog && currentPlatform.isMobile
        ? Theme(
            data: theme.copyWith(
              listTileTheme: theme.listTileTheme.copyWith(
                contentPadding: const EdgeInsets.symmetric(horizontal: 30),
              ),
            ),
            child: dialog,
          )
        : dialog;
  }
}

/// The app dialog title widget.
class _AppDialogTitle extends ConsumerStatefulWidget {
  /// The dialog title.
  final Widget title;

  /// Whether to ellipsis title on overflow.
  final bool? ellipsisTitleOnOverflow;

  /// The dialog border radius.
  final double borderRadius;

  /// Whether to display a close button.
  final bool? displayCloseButton;

  /// Creates a new app dialog title instance.
  const _AppDialogTitle({
    required this.title,
    this.ellipsisTitleOnOverflow,
    this.displayCloseButton,
    this.borderRadius = 10,
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
          IconButton(
            color: textColor?.withValues(alpha: 0.75),
            tooltip: MaterialLocalizations.of(context).closeButtonLabel,
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    }
    return Container(
      padding: padding,
      decoration: boxDecoration,
      child: DefaultTextStyle(
        style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle()).copyWith(color: textColor),
        maxLines: widget.ellipsisTitleOnOverflow != false ? null : 1,
        overflow: widget.ellipsisTitleOnOverflow != false ? TextOverflow.clip : TextOverflow.ellipsis,
        child: child,
      ),
    );
  }

  /// Returns the padding.
  EdgeInsets get padding => currentPlatform.isMobile ? const EdgeInsets.all(24) : const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  /// Returns the text color.
  Color? get textColor => currentPlatform.isMobile ? null : Colors.white;

  /// Creates the box decoration.
  BoxDecoration? get boxDecoration => BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(widget.borderRadius),
          topRight: Radius.circular(widget.borderRadius),
        ),
        color: currentPlatform.isMobile || currentBrightness == Brightness.dark ? null : Theme.of(context).colorScheme.primary,
      );
}
