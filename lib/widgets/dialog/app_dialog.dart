import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/utils/brightness_listener.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/widgets/list/list_tile_padding.dart';

/// The classic content padding.
const EdgeInsets kClassicContentPadding = EdgeInsets.symmetric(vertical: 24, horizontal: 16);

/// The classic content padding.
final EdgeInsets kClassicChoiceDialogPadding = currentPlatform.isMobile ? EdgeInsets.zero : EdgeInsets.symmetric(vertical: 12);

/// A scrollable full-width app-styled and adaptive alert dialog.
class AppDialog extends StatelessWidget {
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
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsets? listViewPadding = contentPadding;
    if (listViewPadding == null) {
      int listTileCount = this.children.where((child) => child is ListTile || child is ListTilePadding).length;
      if (listTileCount == this.children.length) {
        listViewPadding = kClassicChoiceDialogPadding;
      } else {
        listViewPadding = kClassicContentPadding;
      }
    }
    List<Widget> children = [
      for (int i = 0; i < this.children.length; i++)
        Padding(
          padding: listViewPadding.copyWith(top: i == 0 ? null : 0, bottom: i == this.children.length - 1 ? null : 0),
          child: this.children[i],
        ),
    ];
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(borderRadius),
        ),
      ),
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: ListView(
          shrinkWrap: true,
          children: [
            if (title != null)
              Transform.translate(
                offset: Offset(0, -1),
                child: _AppDialogTitle(
                  title: title!,
                  ellipsisTitleOnOverflow: ellipsisTitleOnOverflow,
                  displayCloseButton: displayCloseButton,
                  borderRadius: borderRadius,
                ),
              ),
            ...children,
          ],
        ),
      ),
      actions: actions,
    );
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
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    }
    return Container(
      padding: padding,
      decoration: boxDecoration,
      child: DefaultTextStyle(
        style: (Theme.of(context).textTheme.headlineSmall ?? TextStyle()).copyWith(color: textColor),
        maxLines: widget.ellipsisTitleOnOverflow != false ? null : 1,
        overflow: widget.ellipsisTitleOnOverflow != false ? TextOverflow.clip : TextOverflow.ellipsis,
        child: child,
      ),
    );
  }

  /// Returns the padding.
  EdgeInsets get padding => currentPlatform.isMobile ? EdgeInsets.all(24) : EdgeInsets.symmetric(horizontal: 16, vertical: 12);

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
