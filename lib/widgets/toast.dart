import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:open_authenticator/widgets/clickable.dart';

/// Creates the SnackBar and shows it.
FToasterEntry showSuccessToast(BuildContext context, {required String text}) => _showToast(
  context,
  background: context.theme.colors.primary,
  foreground: context.theme.colors.primaryForeground,
  title: 'Success',
  text: text,
  icon: FIcons.check,
);

/// Creates the SnackBar and shows it.
FToasterEntry showErrorToast(BuildContext context, {required String text}) => _showToast(
  context,
  background: context.theme.colors.destructive,
  foreground: context.theme.colors.destructiveForeground,
  title: 'An error occurred',
  text: text,
  icon: FIcons.circleAlert,
);

/// Creates the SnackBar and shows it.
FToasterEntry _showToast(
  BuildContext context, {
  required String title,
  required String text,
  Color? background,
  Color? foreground,
  required IconData icon,
}) => showFToast(
  context: context,
  style: (style) => style.copyWith(
    decoration: style.decoration.copyWith(
      color: background,
    ),
    titleTextStyle: style.titleTextStyle.copyWith(
      color: foreground,
    ),
    descriptionTextStyle: style.descriptionTextStyle.copyWith(
      color: foreground,
    ),
    iconStyle: style.iconStyle.copyWith(
      color: foreground,
    ),
  ),
  title: Text(title),
  description: Text(text),
  icon: Icon(icon),
  suffixBuilder: (context, entry) => ClickableButton.icon(
    style: FButtonStyle.ghost(
      (style) => style.copyWith(
        decoration: style.decoration.map(
          (decoration) => decoration.copyWith(
            color: background,
          ),
        ),
      ),
    ),
    onPress: entry.dismiss,
    child: Icon(FIcons.x, color: foreground),
  ),
  duration: const Duration(seconds: 1),
);
