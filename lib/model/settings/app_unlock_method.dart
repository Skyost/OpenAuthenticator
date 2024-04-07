import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/app_unlock/method.dart';
import 'package:open_authenticator/model/settings/entry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_secure_storage/simple_secure_storage.dart';

/// The app unlock method settings entry provider.
final appUnlockMethodSettingsEntryProvider = AsyncNotifierProvider.autoDispose<AppUnlockMethodSettingsEntry, AppUnlockMethod>(AppUnlockMethodSettingsEntry.new);

/// A settings entry that allows to get and set the app unlock method.
class AppUnlockMethodSettingsEntry extends SettingsEntry<AppUnlockMethod> {
  /// Creates a new app unlock settings entry instance.
  AppUnlockMethodSettingsEntry()
      : super(
          key: 'appUnlockMethod',
          defaultValue: NoneAppUnlockMethod(),
        );

  @override
  Future<AppUnlockMethod> loadFromPreferences(SharedPreferences preferences) async {
    if (!preferences.containsKey(key)) {
      return defaultValue;
    }
    AppUnlockMethod value = _Serialize.deserialize(preferences.getString(key)!);
    if (value is! NoneAppUnlockMethod) {
      return value;
    }
    String? secureValueName = await SimpleSecureStorage.read(key);
    if (secureValueName == null) {
      return value;
    }
    AppUnlockMethod secureValue = _Serialize.deserialize(secureValueName);
    if (secureValue is! NoneAppUnlockMethod) {
      saveToPreferences(preferences, secureValue);
      return secureValue;
    }
    return value;
  }

  @override
  Future<void> saveToPreferences(SharedPreferences preferences, AppUnlockMethod value) async => await preferences.setString(key, value.serialize());

  /// Changes the entry value but check for unlock success before.
  Future<bool> changeValueIfUnlockSucceed(AppUnlockMethod newMethod, BuildContext context) async {
    AppUnlockMethod currentMethod = await future;
    if (!context.mounted || (currentMethod is NoneAppUnlockMethod && !(await newMethod.tryUnlock(context, ref, UnlockReason.enable)))) {
      return false;
    }
    if (!context.mounted || (newMethod is NoneAppUnlockMethod && !(await currentMethod.tryUnlock(context, ref, UnlockReason.disable)))) {
      return false;
    }
    await changeValue(newMethod);
    return true;
  }

  @override
  Future<void> changeValue(AppUnlockMethod value) async {
    if (value is NoneAppUnlockMethod) {
      await SimpleSecureStorage.delete(key);
    } else {
      await SimpleSecureStorage.write(key, true.toString());
    }
    await value.onMethodChosen(ref);
    await (await future).onMethodChanged(ref);
    await super.changeValue(value);
  }
}

/// Serializes and Deserializes [AppUnlockMethod]s.
extension _Serialize on AppUnlockMethod {
  /// A string representing the [LocalAuthenticationAppUnlockMethod] class.
  static const kLocalAuthentication = 'localAuthentication';

  /// A string representing the [MasterPasswordAppUnlockMethod] class.
  static const kMasterPassword = 'masterPassword';

  /// A string representing the [NoneAppUnlockMethod] class.
  static const kNone = 'none';

  /// Serializes the current instance.
  String serialize() {
    switch (this) {
      case LocalAuthenticationAppUnlockMethod():
        return kLocalAuthentication;
      case MasterPasswordAppUnlockMethod():
        return kMasterPassword;
      case NoneAppUnlockMethod():
        return kNone;
    }
  }

  /// Deserializes the [string].
  static AppUnlockMethod deserialize(String string) {
    switch (string) {
      case kLocalAuthentication:
        return LocalAuthenticationAppUnlockMethod();
      case kMasterPassword:
        return MasterPasswordAppUnlockMethod();
      case kNone:
      default:
        return NoneAppUnlockMethod();
    }
  }
}
