import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/backup.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/password_verification/password_verification.dart';
import 'package:open_authenticator/model/settings/storage_type.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';
import 'package:open_authenticator/model/totp/deleted_totps.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/utils/result.dart';

/// The provider instance.
final storageProvider = AsyncNotifierProvider.autoDispose<StorageNotifier, Storage>(StorageNotifier.new);

/// The storage notifier.
class StorageNotifier extends AutoDisposeAsyncNotifier<Storage> {
  @override
  FutureOr<Storage> build() async {
    StorageType storageType = await ref.watch(storageTypeSettingsEntryProvider.future);
    Storage storage = ref.watch(storageType.provider);
    return storage;
  }

  /// Changes the storage type.
  /// Please consider doing a backup by passing a [backupPassword], and restore it in case of failure.
  Future<Result> changeStorageType(
    String masterPassword,
    StorageType newType, {
    String? backupPassword,
    StorageMigrationDeletedTotpPolicy storageMigrationDeletedTotpPolicy = StorageMigrationDeletedTotpPolicy.ask,
  }) async {
    try {
      Result<bool> passwordCheckResult = await (await ref.read(passwordVerificationProvider.future)).isPasswordValid(masterPassword);
      if (passwordCheckResult is! ResultSuccess || !(passwordCheckResult as ResultSuccess<bool>).value) {
        throw (passwordCheckResult as ResultError).exception ?? CurrentStoragePasswordMismatchException();
      }

      Storage currentStorage = await future;
      if (currentStorage.type == newType) {
        return const ResultSuccess();
      }

      if (backupPassword != null) {
        Result<Backup> backupResult = await ref.read(backupStoreProvider.notifier).doBackup(backupPassword);
        if (backupResult is! ResultSuccess) {
          throw BackupException();
        }
      }

      Storage newStorage = ref.read(newType.provider);
      DeletedTotpsDatabase deletedTotpsDatabase = ref.read(deletedTotpsProvider);
      List<String> toDelete = [];
      List<String> newStorageUuids = await newStorage.listUuids();
      for (String uuid in newStorageUuids) {
        if (await deletedTotpsDatabase.isDeleted(uuid)) {
          switch (storageMigrationDeletedTotpPolicy) {
            case StorageMigrationDeletedTotpPolicy.keep:
              deletedTotpsDatabase.cancelDeletion(uuid);
              break;
            case StorageMigrationDeletedTotpPolicy.delete:
              toDelete.add(uuid);
              break;
            case StorageMigrationDeletedTotpPolicy.ask:
              throw ShouldAskForDifferentDeletedTotpPolicyException();
          }
        }
      }

      List<Totp> currentTotps = await currentStorage.listTotps();
      Totp? firstTotp = (await newStorage.listTotps(limit: 1)).firstOrNull;
      List<Totp> toAdd = [];
      if (firstTotp == null) {
        toAdd.addAll(currentTotps);
      } else {
        CryptoStore? currentCryptoStore = ref.read(cryptoStoreProvider).value;
        CryptoStore newCryptoStore = await CryptoStore.fromPassword(masterPassword, firstTotp.encryptedData.encryptionSalt);
        for (Totp totp in currentTotps) {
          CryptoStore oldCryptoStore = currentCryptoStore?.salt == totp.encryptedData.encryptionSalt
              ? currentCryptoStore!
              : await CryptoStore.fromPassword(
                  masterPassword,
                  totp.encryptedData.encryptionSalt,
                );
          DecryptedTotp? decryptedTotp = await totp.changeEncryptionKey(oldCryptoStore, newCryptoStore);
          toAdd.add(decryptedTotp ?? totp);
        }
        await ref.read(cryptoStoreProvider.notifier).saveAndUse(newCryptoStore);
      }

      await newStorage.addTotps(toAdd);
      await newStorage.deleteTotps(toDelete);

      await currentStorage.onStorageTypeChanged(close: false);
      await ref.read(storageTypeSettingsEntryProvider.notifier).changeValue(newType);

      return const ResultSuccess();
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }
}

/// Allows to return various results from the storage migration.
sealed class StorageMigrationException implements Exception {
  /// The exception code.
  final String code;

  /// Creates a new storage migration exception instance.
  StorageMigrationException({
    required this.code,
  });
}

/// An generic error occurred.
class GenericMigrationError extends StorageMigrationException {
  /// The error code.
  static const String _code = 'genericError';

  /// Creates a new generic migration error instance.
  GenericMigrationError()
      : super(
          code: _code,
        );

  @override
  String toString() => 'Generic exception occurred';
}

/// Whether we should ask for a different [StorageMigrationDeletedTotpPolicy].
class ShouldAskForDifferentDeletedTotpPolicyException extends StorageMigrationException {
  /// The error code.
  static const String _code = 'shouldAskForDifferentDeletedTotpPolicy';

  /// Creates a new storage migration policy exception instance.
  ShouldAskForDifferentDeletedTotpPolicyException()
      : super(
          code: _code,
        );

  @override
  String toString() => 'Another deleted TOTP policy should be used';
}

/// When we haven't succeeded to do the asked backup.
class BackupException extends StorageMigrationException {
  /// The error code.
  static const String _code = 'backupError';

  /// Creates a new backup exception instance.
  BackupException()
      : super(
          code: _code,
        );

  @override
  String toString() => 'Exception while doing the backup';
}

/// When the provided password don't match the one that has been using on the old storage.
class CurrentStoragePasswordMismatchException extends StorageMigrationException {
  /// The error code.
  static const String _code = 'currentStoragePasswordMismatch';

  /// Creates a new current storage password mismatch exception instance.
  CurrentStoragePasswordMismatchException()
      : super(
          code: _code,
        );

  @override
  String toString() => 'Current storage password is incorrect';
}

/// When there is an error while trying to change the encryption key of the old storage.
class EncryptionKeyChangeFailedError extends StorageMigrationException {
  /// The error code.
  static const String _code = 'encryptionKeyChangeFailed';

  /// Creates a new encryption key change error instance.
  EncryptionKeyChangeFailedError()
      : super(
          code: _code,
        );

  @override
  String toString() => 'Failed to change encryption key';
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

  /// The time to wait between two operations.
  Duration get operationThreshold => Duration.zero;

  /// Stores the given [totp].
  Future<void> addTotp(Totp totp);

  /// Stores the given [totps].
  Future<void> addTotps(List<Totp> totps);

  /// Updates the TOTP associated with the specified [uuid].
  Future<void> updateTotp(String uuid, Totp totp);

  /// Deletes the TOTP associated to the given [uuid].
  Future<void> deleteTotp(String uuid);

  /// Deletes the TOTP associated to the given [uuids].
  Future<void> deleteTotps(List<String> uuids);

  /// Clears all TOTPs.
  Future<void> clearTotps();

  /// Returns the TOTP associated to the given [uuid].
  Future<Totp?> getTotp(String uuid);

  /// Lists all TOTPs.
  Future<List<Totp>> listTotps({int? limit});

  /// Lists all TOTPs UUID.
  Future<List<String>> listUuids({int? limit});

  /// Replace all current TOTPs by [newTotps].
  Future<void> replaceTotps(List<Totp> newTotps) async {
    await clearTotps();
    await addTotps(newTotps);
  }

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
