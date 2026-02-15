import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class Clickable extends StatelessWidget with FTileMixin, FItemMixin {
  final Widget child;

  const Clickable({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: child,
  );
}

extension MakeClickable on Widget {
  Widget clickable({bool clickable = true}) => clickable ? Clickable(child: this) : this;
}

class ClickableTile extends FTile {
  ClickableTile({
    super.key,
    required super.title,
    super.variants,
    super.style,
    super.enabled,
    super.selected = false,
    super.semanticsLabel,
    super.autofocus = false,
    super.focusNode,
    super.onFocusChange,
    super.onHoverChange,
    super.onVariantChange,
    super.onPress,
    super.onLongPress,
    super.onSecondaryPress,
    super.onSecondaryLongPress,
    super.shortcuts,
    super.actions,
    super.prefix,
    super.subtitle,
    super.details,
    super.suffix,
  });

  ClickableTile.raw({
    super.key,
    required super.child,
    super.variants,
    super.style,
    super.enabled,
    super.selected = false,
    super.semanticsLabel,
    super.autofocus = false,
    super.focusNode,
    super.onFocusChange,
    super.onHoverChange,
    super.onVariantChange,
    super.onPress,
    super.onLongPress,
    super.onSecondaryPress,
    super.onSecondaryLongPress,
    super.shortcuts,
    super.actions,
    Widget? prefix,
  }) : super.raw();

  @override
  Widget build(BuildContext context) => super
      .build(context)
      .clickable(
        clickable: enabled != false && (onPress != null || onLongPress != null),
      );
}

class ClickableButton extends FButton {
  ClickableButton({
    super.key,
    required super.onPress,
    required super.child,
    super.variant,
    super.style,
    super.onLongPress,
    super.onSecondaryPress,
    super.onSecondaryLongPress,
    super.autofocus,
    super.focusNode,
    super.onFocusChange,
    super.onHoverChange,
    super.onVariantChange,
    super.selected,
    super.shortcuts,
    super.actions,
    super.mainAxisSize,
    super.mainAxisAlignment,
    super.crossAxisAlignment,
    super.textBaseline,
    super.prefix,
    super.suffix,
  });

  ClickableButton.icon({
    super.key,
    required super.onPress,
    required super.child,
    super.variant,
    super.style,
    super.onLongPress,
    super.onSecondaryPress,
    super.onSecondaryLongPress,
    super.autofocus,
    super.focusNode,
    super.onFocusChange,
    super.onHoverChange,
    super.onVariantChange,
    super.selected,
    super.shortcuts,
    super.actions,
  }) : super.icon();

  const ClickableButton.raw({
    super.key,
    required super.onPress,
    required super.child,
    super.variant,
    super.style,
    super.onLongPress,
    super.onSecondaryPress,
    super.onSecondaryLongPress,
    super.autofocus,
    super.focusNode,
    super.onFocusChange,
    super.onHoverChange,
    super.onVariantChange,
    super.selected,
    super.shortcuts,
    super.actions,
  }) : super.raw();

  @override
  Widget build(BuildContext context) => super
      .build(context)
      .clickable(
        clickable: onPress != null || onLongPress != null,
      );
}

class ClickableHeaderAction extends FHeaderAction {
  const ClickableHeaderAction({
    super.key,
    required super.icon,
    required super.onPress,
    super.style,
    super.semanticsLabel,
    super.selected = false,
    super.autofocus = false,
    super.focusNode,
    super.onFocusChange,
    super.onHoverChange,
    super.onVariantChange,
    super.onLongPress,
    super.onSecondaryPress,
    super.onSecondaryLongPress,
    super.shortcuts,
    super.actions,
  });

  const ClickableHeaderAction.back({
    Key? key,
    required VoidCallback? onPress,
    FHeaderActionStyle? style,
    bool autofocus = false,
    FocusNode? focusNode,
    ValueChanged<bool>? onFocusChange,
    ValueChanged<bool>? onHoverChange,
    FTappableVariantChangeCallback? onVariantChange,
    VoidCallback? onLongPress,
    VoidCallback? onSecondaryPress,
    VoidCallback? onSecondaryLongPress,
    Map<ShortcutActivator, Intent>? shortcuts,
    Map<Type, Action<Intent>>? actions,
  }) : this(
         key: key,
         icon: const Icon(FIcons.arrowLeft),
         onPress: onPress,
         style: style,
         autofocus: autofocus,
         focusNode: focusNode,
         onFocusChange: onFocusChange,
         onHoverChange: onHoverChange,
         onVariantChange: onVariantChange,
         onLongPress: onLongPress,
         onSecondaryPress: onSecondaryPress,
         onSecondaryLongPress: onSecondaryLongPress,
         shortcuts: shortcuts,
         actions: actions,
       );

  const ClickableHeaderAction.x({
    Key? key,
    required VoidCallback? onPress,
    FHeaderActionStyle? style,
    bool autofocus = false,
    FocusNode? focusNode,
    ValueChanged<bool>? onFocusChange,
    ValueChanged<bool>? onHoverChange,
    FTappableVariantChangeCallback? onVariantChange,
    VoidCallback? onLongPress,
    VoidCallback? onSecondaryPress,
    VoidCallback? onSecondaryLongPress,
    Map<ShortcutActivator, Intent>? shortcuts,
    Map<Type, Action<Intent>>? actions,
  }) : this(
         key: key,
         icon: const Icon(FIcons.x),
         onPress: onPress,
         style: style,
         autofocus: autofocus,
         focusNode: focusNode,
         onFocusChange: onFocusChange,
         onHoverChange: onHoverChange,
         onVariantChange: onVariantChange,
         onLongPress: onLongPress,
         onSecondaryPress: onSecondaryPress,
         onSecondaryLongPress: onSecondaryLongPress,
         shortcuts: shortcuts,
         actions: actions,
       );

  @override
  Widget build(BuildContext context) => super
      .build(context)
      .clickable(
        clickable: onPress != null || onLongPress != null,
      );
}
