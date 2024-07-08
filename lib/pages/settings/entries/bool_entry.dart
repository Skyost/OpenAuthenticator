import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/settings/entry.dart';

/// Allows to configure boolean values.
class BoolSettingsEntryWidget<T extends SettingsEntry<bool>> extends CheckboxSettingsEntryWidget<T, bool> {
  /// Creates a new bool settings entry widget instance.
  const BoolSettingsEntryWidget({
    super.key,
    required super.provider,
    required super.title,
    super.subtitle,
    super.icon,
  });

  @override
  bool isEnabled(bool? value) => value == true;

  @override
  void changeValue(BuildContext context, WidgetRef ref, bool newValue) => ref.read(provider.notifier).changeValue(newValue);
}

/// A settings entry that can be configured using a checkbox.
abstract class CheckboxSettingsEntryWidget<T extends SettingsEntry<U>, U> extends ConsumerWidget {
  /// The boolean provider.
  final AutoDisposeAsyncNotifierProvider<T, U> provider;

  /// The entry widget title.
  final String title;

  /// The entry widget subtitle.
  final String? subtitle;

  /// The icon.
  final IconData? icon;

  /// The tile padding.
  final EdgeInsets? contentPadding;

  /// Creates a new checkbox settings entry widget instance.
  const CheckboxSettingsEntryWidget({
    super.key,
    required this.provider,
    required this.title,
    this.subtitle,
    this.icon,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<U> value = ref.watch(provider);
    return switch (value) {
      AsyncData(:final value) => createListTile(context, ref, value: value),
      AsyncError() => const SizedBox.shrink(),
      _ => createListTile(context, ref, enabled: false),
    };
  }

  /// Creates the list tile widget.
  Widget createListTile(BuildContext context, WidgetRef ref, {U? value, bool enabled = true}) => ListTile(
        leading: icon == null ? null : Icon(icon),
        title: Text(title),
        subtitle: buildSubtitle(context, ref, value),
        enabled: enabled,
        contentPadding: contentPadding,
        onTap: () => changeValue(context, ref, !isEnabled(value)),
        trailing: Checkbox(
          value: isEnabled(value),
          onChanged: enabled
              ? (value) {
                  if (value != null) {
                    changeValue(context, ref, value);
                  }
                }
              : null,
        ),
      );

  /// Whether the checkbox is enabled.
  bool isEnabled(U? value);

  /// Builds the subtitle widget.
  Widget? buildSubtitle(BuildContext context, WidgetRef ref, U? value) => subtitle == null ? null : Text(subtitle!);

  /// Changes the value.
  void changeValue(BuildContext context, WidgetRef ref, bool newValue);
}
