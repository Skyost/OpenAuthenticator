import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:open_authenticator/spacing.dart';
import 'package:open_authenticator/utils/utils.dart';

/// The light and dark variants of a green theme.
({FThemeData light, FThemeData dark}) get greenTheme {
  FThemeData light = FThemeData(
    colors: FColors(
      brightness: .light,
      systemOverlayStyle: .dark,
      barrier: const Color(0x33000000),
      background: const Color(0xFFF1F1F2),
      foreground: const Color(0xFF09090B),
      primary: Colors.green.shade800,
      primaryForeground: Colors.white,
      secondary: const Color(0xFFF1F1F2),
      secondaryForeground: const Color(0xFF18181B),
      muted: const Color(0xFFF4F4F5),
      mutedForeground: const Color(0xFF71717A),
      destructive: const Color(0xFFEF4444),
      destructiveForeground: const Color(0xFFFAFAFA),
      error: const Color(0xFFEF4444),
      errorForeground: const Color(0xFFFAFAFA),
      border: const Color(0xFFE3E3E6),
    ),
  );
  FThemeData dark = FThemeData(
    colors: const FColors(
      brightness: .dark,
      systemOverlayStyle: .light,
      barrier: Color(0x7A000000),
      background: Color(0xFF0C0A09),
      foreground: Color(0xFFF2F2F2),
      primary: Colors.green,
      primaryForeground: Color(0xFF052E16),
      secondary: Color(0xFF27272A),
      secondaryForeground: Color(0xFFFAFAFA),
      muted: Color(0xFF262626),
      mutedForeground: Color(0xFFA1A1AA),
      destructive: Color(0xFF7F1D1D),
      destructiveForeground: Color(0xFFFEF2F2),
      error: Color(0xFF7F1D1D),
      errorForeground: Color(0xFFFEF2F2),
      border: Color(0xFF27272A),
    ),
  );
  BoxShadow tileShadow = BoxShadow(
    color: Colors.grey.withValues(alpha: 0.3),
    spreadRadius: 1,
    blurRadius: 4,
    offset: const Offset(0, 2),
  );
  return (
    light: light.copyWith(
      headerStyles: (style) => _adaptHeaderStyles(
        style,
        actionHoverColor: Colors.black54,
        bottomBorderColor: const Color(0xFFE3E3E6),
      ),
      tileGroupStyle: (tileGroupStyle) => tileGroupStyle.copyWith(
        decoration: tileGroupStyle.decoration.copyWith(
          boxShadow: [tileShadow],
        ),
        tileStyle: (tileStyle) => _adaptTileStyle(
          tileStyle,
          backgroundColor: Colors.white,
          hoveredBackgroundColor: const Color(0xFF71717A),
        ),
      ),
      tileStyle: (tileStyle) {
        FTileStyle adaptedStyle = _adaptTileStyle(
          tileStyle,
          backgroundColor: Colors.white,
          hoveredBackgroundColor: const Color(0xFF71717A),
        );
        return adaptedStyle.copyWith(
          decoration:
              FWidgetStateMap({
                WidgetState.hovered: adaptedStyle.decoration.resolve({WidgetState.hovered})?.copyWith(color: const Color(0xFFF5F5F5)),
                WidgetState.any: adaptedStyle.decoration.resolve({}),
              }).map(
                (decoration) => decoration?.copyWith(
                  boxShadow: [tileShadow],
                ),
              ),
        );
      },
      buttonStyles: _adaptButtonStyles,
      textFieldStyle: (textFieldStyle) => _adaptTextFieldStyle(
        textFieldStyle,
        labelTextStyle: FThemes.zinc.light.textFieldStyle.labelTextStyle,
        contentTextStyle: FThemes.zinc.light.textFieldStyle.contentTextStyle,
      ),
      selectStyle: (selectStyle) => _adaptSelectStyle(
        selectStyle,
        labelTextStyle: FThemes.zinc.light.textFieldStyle.labelTextStyle,
      ),
      popoverMenuStyle: (popoverMenuStyle) => _adaptPopoverMenuStyle(
        popoverMenuStyle,
        hoveredBackgroundColor: Colors.black12,
        boxShadow: [tileShadow],
      ),
      style: (style) => _adaptGeneralStyle(
        style,
        shadow: [tileShadow],
      ),
    ),
    dark: dark.copyWith(
      headerStyles: (style) => _adaptHeaderStyles(
        style,
        actionHoverColor: Colors.white60,
      ),
      tileGroupStyle: (tileGroupStyle) => tileGroupStyle.copyWith(
        tileStyle: _adaptTileStyle,
      ),
      tileStyle: _adaptTileStyle,
      buttonStyles: _adaptButtonStyles,
      textFieldStyle: (textFieldStyle) => _adaptTextFieldStyle(
        textFieldStyle,
        labelTextStyle: FThemes.zinc.dark.textFieldStyle.labelTextStyle,
        contentTextStyle: FThemes.zinc.dark.textFieldStyle.contentTextStyle,
      ),
      popoverMenuStyle: (popoverMenuStyle) => _adaptPopoverMenuStyle(
        popoverMenuStyle,
        hoveredBackgroundColor: Colors.white12,
      ),
      style: _adaptGeneralStyle,
    ),
  );
}

FHeaderStyles _adaptHeaderStyles(
  FHeaderStyles headerStyles, {
  Color? actionHoverColor,
  Color bottomBorderColor = Colors.transparent,
}) => headerStyles.copyWith(
  nestedStyle: (nestedStyle) => nestedStyle.copyWith(
    actionStyle: (actionStyle) => actionStyle.copyWith(
      iconStyle: FWidgetStateMap({
        WidgetState.hovered: actionStyle.iconStyle.resolve({WidgetState.hovered}).copyWith(color: actionHoverColor),
        WidgetState.any: actionStyle.iconStyle.resolve({}),
      }),
    ),
    padding: EdgeInsets.symmetric(
      vertical: nestedStyle.padding.vertical / 2,
      horizontal: nestedStyle.padding.horizontal / 2,
    ),
    decoration: nestedStyle.decoration.copyWith(
      border: BoxBorder.fromLTRB(
        bottom: BorderSide(color: bottomBorderColor),
      ),
    ),
  ),
);

FTileStyle _adaptTileStyle(
  FTileStyle tileStyle, {
  Color? backgroundColor,
  Color? hoveredBackgroundColor,
}) => tileStyle.copyWith(
  decoration: tileStyle.decoration.replaceFirstWhere(
    {},
    (decoration) => decoration?.copyWith(
      color: backgroundColor,
    ),
  ),
  contentStyle: (contentStyle) => contentStyle.copyWith(
    padding: const EdgeInsets.all(kBigSpace),
    titleTextStyle: contentStyle.titleTextStyle.replaceFirstWhere(
      {WidgetState.disabled},
      (titleTextStyle) => titleTextStyle.copyWith(color: hoveredBackgroundColor),
    ),
  ),
);

FButtonStyles _adaptButtonStyles(FButtonStyles buttonStyles) => buttonStyles.copyWith(
  secondary: (secondaryStyle) => secondaryStyle.copyWith(
    decoration: secondaryStyle.decoration.map(
      (decoration) => decoration.copyWith(
        color: decoration.color?.darken(amount: 0.07),
      ),
    ),
  ),
  ghost: (ghostStyle) => ghostStyle.copyWith(
    decoration: FWidgetStateMap({
      WidgetState.hovered: ghostStyle.decoration.resolve({WidgetState.hovered}).copyWith(color: Colors.black12),
      WidgetState.any: ghostStyle.decoration.resolve({}),
    }),
  ),
);

FTextFieldStyle _adaptTextFieldStyle(
  FTextFieldStyle textFieldStyle, {
  FWidgetStateMap<TextStyle>? labelTextStyle,
  FWidgetStateMap<TextStyle>? contentTextStyle,
}) => textFieldStyle.copyWith(
  labelTextStyle: labelTextStyle,
  contentTextStyle: contentTextStyle,
);

FSelectStyle _adaptSelectStyle(
  FSelectStyle selectStyle, {
  FWidgetStateMap<TextStyle>? labelTextStyle,
}) => selectStyle.copyWith(
  selectFieldStyle: (selectFieldStyle) => selectFieldStyle.copyWith(
    labelTextStyle: labelTextStyle,
  ),
);

FPopoverMenuStyle _adaptPopoverMenuStyle(
  FPopoverMenuStyle popoverMenuStyle, {
  Color? hoveredBackgroundColor,
  List<BoxShadow>? boxShadow,
}) => popoverMenuStyle.copyWith(
  decoration: popoverMenuStyle.decoration.copyWith(
    boxShadow: boxShadow,
  ),
  itemGroupStyle: (itemGroupStyle) => itemGroupStyle.copyWith(
    itemStyle: (itemStyle) => itemStyle.copyWith(
      decoration: FWidgetStateMap({
        WidgetState.hovered: itemStyle.decoration.resolve({WidgetState.hovered})?.copyWith(color: hoveredBackgroundColor),
      }),
    ),
  ),
);

FStyle _adaptGeneralStyle(
  FStyle style, {
  List<BoxShadow>? shadow,
}) => style.copyWith(
  pagePadding: const EdgeInsets.all(kBigSpace),
  shadow: shadow,
);
