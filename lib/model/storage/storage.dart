import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/backup.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/settings/storage_type.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/model/totp/algorithm.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';
import 'package:open_authenticator/model/totp/deleted_totps.dart';
import 'package:open_authenticator/model/totp/totp.dart';

/// The provider instance.
final storageProvider = AsyncNotifierProvider.autoDispose<StorageNotifier, Storage>(StorageNotifier.new);

/// The storage notifier.
class StorageNotifier extends AutoDisposeAsyncNotifier<Storage> {
  @override
  FutureOr<Storage> build() async {
    StorageType storageType = await ref.watch(storageTypeSettingsEntryProvider.future);
    Storage storage = storageType.create(ref);
    ref.onDispose(storage.close);
    return storage;
  }

  /// Changes the storage type.
  /// Please consider doing a backup by passing a [backupPassword], and restore it in case of failure.
  Future<StorageMigrationResult> changeStorageType(
    String masterPassword,
    StorageType newType, {
    String? backupPassword,
    String? newStorageMasterPassword,
    StorageMigrationDeletedTotpPolicy storageMigrationDeletedTotpPolicy = StorageMigrationDeletedTotpPolicy.ask,
  }) async {
    try {
      if (!(await ref.read(cryptoStoreProvider.notifier).checkPasswordValidity(masterPassword))) {
        return StorageMigrationResult.currentStoragePasswordMismatch;
      }

      newStorageMasterPassword ??= masterPassword;

      Storage currentStorage = await future;
      if (currentStorage.type == newType) {
        return StorageMigrationResult.success;
      }

      Uint8List? oldSalt = await currentStorage.readSecretsSalt();
      if (oldSalt == null) {
        return StorageMigrationResult.saltError;
      }

      CryptoStore? currentCryptoStore = await CryptoStore.fromPassword(masterPassword, salt: oldSalt);
      if (currentCryptoStore == null) {
        return StorageMigrationResult.genericError;
      }

      if (backupPassword != null) {
        await ref.read(backupStoreProvider.notifier).doBackup(backupPassword);
        return StorageMigrationResult.backupError;
      }

      Storage newStorage = newType.create(ref);
      DeletedTotpsDatabase deletedTotpsDatabase = ref.read(deletedTotpsProvider);
      Future<void> close() async {
        await newStorage.close();
        // await deletedTotpsDatabase.close();
      }

      List<String> toDelete = [];
      List<Totp> newStorageTotps = await newStorage.listTotps();
      for (Totp totp in newStorageTotps) {
        if (await deletedTotpsDatabase.isDeleted(totp.uuid)) {
          switch (storageMigrationDeletedTotpPolicy) {
            case StorageMigrationDeletedTotpPolicy.keep:
              deletedTotpsDatabase.cancelDeletion(totp.uuid);
              break;
            case StorageMigrationDeletedTotpPolicy.delete:
              toDelete.add(totp.uuid);
              break;
            case StorageMigrationDeletedTotpPolicy.ask:
              await close();
              return StorageMigrationResult.askForDifferentDeletedTotpPolicy;
          }
        }
      }

      Uint8List? salt = await newStorage.readSecretsSalt();
      List<Totp> totps = await currentStorage.listTotps();
      List<Totp> toAdd = [];
      if (salt == null) {
        if (!(await newStorage.saveSecretsSalt(oldSalt))) {
          await close();
          return StorageMigrationResult.saltError;
        }

        bool canDecryptAll = await newStorage.canDecryptAll(currentCryptoStore);
        if (!canDecryptAll) {
          await close();
          return StorageMigrationResult.newStoragePasswordMismatch;
        }

        toAdd.addAll(totps.where((totp) => totp.isDecrypted));
      } else {
        CryptoStore? newCryptoStore = await CryptoStore.fromPassword(newStorageMasterPassword, salt: salt);
        if (newCryptoStore == null) {
          await close();
          return StorageMigrationResult.genericError;
        }

        bool canDecryptAll = await newStorage.canDecryptAll(currentCryptoStore);
        if (!canDecryptAll) {
          await close();
          return StorageMigrationResult.newStoragePasswordMismatch;
        }

        for (Totp totp in totps) {
          DecryptedTotp? decryptedTotp = await totp.changeEncryptionKey(currentCryptoStore, newCryptoStore);
          if (decryptedTotp == null) {
            await close();
            return StorageMigrationResult.encryptionKeyChangeFailed;
          }
          toAdd.add(decryptedTotp);
        }
        await ref.read(cryptoStoreProvider.notifier).saveAndUse(newCryptoStore);
      }

      if (!await newStorage.addTotps(toAdd)) {
        await close();
        return StorageMigrationResult.genericError;
      }
      await newStorage.deleteTotps(toDelete);

      await close();

      await currentStorage.onStorageTypeChanged(close: false);
      await ref.read(storageTypeSettingsEntryProvider.notifier).changeValue(newType);

      return StorageMigrationResult.success;
    } catch (ex, stacktrace) {
      if (kDebugMode) {
        print(ex);
        print(stacktrace);
      }
    }
    return StorageMigrationResult.genericError;
  }
}

/// Allows to return various results from the storage migration.
enum StorageMigrationResult {
  /// When it's a success.
  success,

  /// Whether we should ask for a different [StorageMigrationDeletedTotpPolicy].
  askForDifferentDeletedTotpPolicy,

  /// When there is a salt error.
  saltError,

  /// When we haven't succeeded the asked backup.
  backupError,

  /// When the provided password don't match the one that has been using on the old storage.
  currentStoragePasswordMismatch,

  /// When the provided password don't match the one that has been using on the new storage.
  newStoragePasswordMismatch,

  /// When there is an error while trying to change the encryption key of the old storage.
  encryptionKeyChangeFailed,

  /// An unknown error occured.
  genericError;
}

/// Allows to control the behavior when a TOTP has locally been deleted, but not on a different storage.
enum StorageMigrationDeletedTotpPolicy {
  /// Whether we should keep the TOTPs.
  keep,

  /// Whether we should delete the TOTPs.
  delete,

  /// Whether we should return and ask for deletion.
  ask;
}

/// A common interface to store TOTPs either locally or remotely.
mixin Storage {
  /// Returns the storage type.
  StorageType get type;

  /// The storage dependencies.
  List<NotifierProvider> get dependencies => [];

  /// Stores the given [totp].
  Future<bool> addTotp(Totp totp);

  /// Stores the given [totps].
  Future<bool> addTotps(List<Totp> totps);

  /// Updates the TOTP associated with the specified [uuid].
  Future<bool> updateTotp(
    String uuid, {
    String? label,
    String? issuer,
    Algorithm? algorithm,
    int? digits,
    int? validity,
    String? imageUrl,
  });

  /// Deletes the TOTP associated to the given [uuid].
  Future<bool> deleteTotp(String uuid);

  /// Deletes the TOTP associated to the given [uuids].
  Future<bool> deleteTotps(List<String> uuids);

  /// Clears all TOTPs.
  Future<bool> clearTotps();

  /// Returns the TOTP associated to the given [uuid].
  Future<Totp?> getTotp(String uuid);

  /// Lists all TOTPs.
  Future<List<Totp>> listTotps();

  /// Whether the given [cryptoStore] is able to decrypt all stored TOTPs.
  Future<bool> canDecryptAll(CryptoStore cryptoStore);

  /// Loads the salt that allows to encrypt secrets.
  Future<Uint8List?> readSecretsSalt();

  /// Saves the salt that allows to encrypt secrets.
  Future<bool> saveSecretsSalt(Uint8List salt);

  /// Closes this storage instance.
  Future<void> close();

  /// Ran when the user choose another storage method.
  @mustCallSuper
  Future<void> onStorageTypeChanged({bool close = true}) async {
    if (close) {
      await this.close();
    }
  }
}
