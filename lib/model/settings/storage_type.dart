import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/settings/entry.dart';
import 'package:open_authenticator/model/storage/type.dart';

/// The storage type settings entry provider.
final storageTypeSettingsEntryProvider = AsyncNotifierProvider.autoDispose<StorageTypeSettingsEntry, StorageType>(StorageTypeSettingsEntry.new);

/// A settings entry that allows to get and set the storage type.
class StorageTypeSettingsEntry extends EnumSettingsEntry<StorageType> {
  /// Creates a new storage type settings entry instance.
  StorageTypeSettingsEntry()
      : super(
          key: 'storageType',
          defaultValue: StorageType.local,
        );

  @override
  @protected
  List<StorageType> get values => StorageType.values;
}
