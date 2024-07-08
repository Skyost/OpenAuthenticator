import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The shared preferences provider.
final sharedPreferencesProvider = FutureProvider.autoDispose<SharedPreferences>((ref) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences;
});

/// Represents a settings entry, which can be user configured (directly or not).
class SettingsEntry<T> extends AutoDisposeAsyncNotifier<T> {
  /// The preferences key.
  final String key;

  /// The default value.
  final T defaultValue;

  /// Creates a new settings entry instance.
  SettingsEntry({
    required this.key,
    required this.defaultValue,
  });

  @override
  FutureOr<T> build() async {
    SharedPreferences preferences = await ref.watch(sharedPreferencesProvider.future);
    if (preferences.containsKey(key)) {
      return await loadFromPreferences(preferences);
    }
    return defaultValue;
  }

  /// Changes the entry value.
  Future<void> changeValue(T value) async {
    if (value != state.valueOrNull) {
      state = AsyncData(value);
      SharedPreferences preferences = await ref.read(sharedPreferencesProvider.future);
      await saveToPreferences(preferences, value);
    }
  }

  /// Loads the value from preferences.
  Future<T> loadFromPreferences(SharedPreferences preferences) async {
    assert(T == String || T == bool || T == int || T == double || T == List<String>);
    return preferences.get(key) as T;
  }

  /// Saves the value to preferences.
  Future<void> saveToPreferences(SharedPreferences preferences, T value) async {
    assert(T == String || T == bool || T == int || T == double || T == List<String>);
    if (T == String) {
      await preferences.setString(key, value as String);
    } else if (T == bool) {
      await preferences.setBool(key, value as bool);
    } else if (T == int) {
      await preferences.setInt(key, value as int);
    } else if (T == double) {
      await preferences.setDouble(key, value as double);
    } else if (T == List<String>) {
      await preferences.setStringList(key, value as List<String>);
    }
  }
}

/// Allows to easily use enums in settings entry.
abstract class EnumSettingsEntry<T extends Enum> extends SettingsEntry<T> {
  /// Creates a new enum settings entry instance.
  EnumSettingsEntry({
    required super.key,
    required super.defaultValue,
  });

  @override
  Future<T> loadFromPreferences(SharedPreferences preferences) async {
    String? value = preferences.getString(key);
    return values.firstWhereOrNull((theme) => theme.name == value) ?? defaultValue;
  }

  @override
  Future<void> saveToPreferences(SharedPreferences preferences, T value) async {
    await preferences.setString(key, value.name);
  }

  /// Should return the enum values.
  List<T> get values;
}
