import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/storage/local.dart';
import 'package:open_authenticator/model/storage/online.dart';
import 'package:open_authenticator/model/storage/storage.dart';

/// Contains all storage types.
enum StorageType {
  /// Local storage, using Drift.
  local,

  /// Online storage, using Firebase Firestore.
  online;

  /// Returns the provider associated with the storage type.
  Provider<Storage> get provider => switch (this) {
    StorageType.local => localStorageProvider,
    StorageType.online => onlineStorageProvider,
  };
}
