import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/app_unlock/method.dart';
import 'package:open_authenticator/model/settings/entry.dart';
import 'package:open_authenticator/utils/result.dart';
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
  Future<Result> changeValueIfUnlockSucceed(AppUnlockMethod newMethod, BuildContext context) async {
    AppUnlockMethod currentMethod = await future;
    if (!context.mounted) {
      return const ResultCancelled();
    }
    Result disableResult = await currentMethod.tryUnlock(context, ref, UnlockReason.disable);
    if (disableResult is! ResultSuccess) {
      return disableResult;
    }
    if (!context.mounted) {
      return const ResultCancelled();
    }
    Result enableResult = await newMethod.tryUnlock(context, ref, UnlockReason.enable);
    if (enableResult is! ResultSuccess) {
      return enableResult;
    }
    await changeValue(newMethod, enableResult: enableResult, disableResult: disableResult);
    return const ResultSuccess();
  }

  @override
  Future<void> changeValue(AppUnlockMethod value, { ResultSuccess? enableResult, ResultSuccess? disableResult }) async {
    switch (value) {
      case NoneAppUnlockMethod():
        await SimpleSecureStorage.delete(key);
        break;
      case LocalAuthenticationAppUnlockMethod():
      case MasterPasswordAppUnlockMethod():
      default:
        await SimpleSecureStorage.write(key, value.serialize());
        break;
    }
    AppUnlockMethod current = await future;
    await value.onMethodChosen(ref, enableResult: enableResult);
    await current.onMethodChanged(ref, disableResult: disableResult);
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
