import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/settings/entry.dart';

/// The theme settings entry provider.
final themeSettingsEntryProvider = AsyncNotifierProvider.autoDispose<ThemeSettingsEntry, ThemeMode>(ThemeSettingsEntry.new);

/// A settings entry that allows to change the theme.
class ThemeSettingsEntry extends EnumSettingsEntry<ThemeMode> {
  /// Creates a new theme settings entry instance.
  ThemeSettingsEntry()
      : super(
          key: 'theme',
          defaultValue: ThemeMode.system,
        );

  @override
  List<ThemeMode> get values => ThemeMode.values;
}
