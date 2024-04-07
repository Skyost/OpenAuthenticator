import 'package:open_authenticator/model/storage/local.dart';
import 'package:open_authenticator/model/storage/online.dart';
import 'package:open_authenticator/model/storage/storage.dart';

/// Contains all storage types.
enum StorageType {
  /// Local storage, using Drift.
  local(create: LocalStorage.new),

  /// Online storage, using Firebase Firestore.
  online(create: OnlineStorage.new);

  /// Creates a storage instance associated to the current type.
  final Storage Function() create;

  /// The migration quota, if any.
  final Duration? migrationQuota;

  /// Creates a new storage type instance.
  const StorageType({
    required this.create,
    this.migrationQuota,
  });
}
