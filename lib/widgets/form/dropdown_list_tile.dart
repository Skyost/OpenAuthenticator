import 'package:flutter/material.dart';
import 'package:open_authenticator/utils/utils.dart';

/// A list tile with a dropdown menu.
class DropdownListTile<T> extends StatelessWidget {
  /// The leading widget.
  final Widget? leading;

  /// The title widget.
  final Widget? title;

  /// The current value.
  final T? value;

  /// Whether the list tile is enabled.
  final bool enabled;

  /// The choices.
  final List<DropdownListTileChoice<T>> choices;

  /// Called when a choice is selected.
  final Function(DropdownListTileChoice<T>)? onChoiceSelected;

  /// Creates a new dropdown list tile instance.
  const DropdownListTile({
    super.key,
    this.leading,
    this.title,
    this.value,
    this.enabled = true,
    this.choices = const [],
    this.onChoiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    DropdownListTileChoice<T>? choice = choices.firstWhereOrNull((choice) => choice.value == value);
    return enabled
        ? MenuAnchor(
            alignmentOffset: Offset(MediaQuery.sizeOf(context).width, 0),
            menuChildren: [
              for (DropdownListTileChoice<T> choice in choices)
                MenuItemButton(
                  leadingIcon: choice.icon == null ? null : Icon(choice.icon),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 150),
                    child: Text(choice.title),
                  ),
                  onPressed: () => onChoiceSelected?.call(choice),
                ),
            ],
            builder: (context, controller, child) => _buildChild(
              choice,
              controller: controller,
            ),
          )
        : _buildChild(choice);
  }

  /// Builds the child widget.
  Widget _buildChild(DropdownListTileChoice<T>? choice, {MenuController? controller}) => ListTile(
    leading: leading ?? (choice?.icon == null ? null : Icon(choice!.icon)),
    trailing: const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Icon(Icons.chevron_right),
    ),
    enabled: controller != null,
    title: title,
    subtitle: choice?.title == null ? null : Text(choice!.title),
    onTap: controller == null
        ? null
        : () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
  );
}

/// A dropdown list tile choice.
class DropdownListTileChoice<T> {
  /// The title.
  final String title;

  /// The icon.
  final IconData? icon;

  /// The value.
  final T value;

  /// Creates a new dropdown list tile choice instance.
  const DropdownListTileChoice({
    required this.title,
    this.icon,
    required this.value,
  });
}
