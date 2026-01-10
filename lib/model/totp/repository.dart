import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/backend/synchronization/operation.dart';
import 'package:open_authenticator/model/backend/synchronization/queue.dart';
import 'package:open_authenticator/model/backup.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/settings/storage_type.dart';
import 'package:open_authenticator/model/totp/database/database.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';
import 'package:open_authenticator/model/totp/image_cache.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/utils/result.dart';

/// The provider instance.
final totpRepositoryProvider = AsyncNotifierProvider.autoDispose<TotpRepository, TotpList>(TotpRepository.new);

/// Allows to query, register, update and delete TOTPs.
class TotpRepository extends AsyncNotifier<TotpList> {
  @override
  FutureOr<TotpList> build() async {
    TotpDatabase database = ref.watch(totpsDatabaseProvider);
    CryptoStore? cryptoStore = await ref.watch(cryptoStoreProvider.future);
    return TotpList._fromListAndStorageType(
      list: await (await database.listTotps()).decrypt(cryptoStore),
      storageType: await ref.watch(storageTypeSettingsEntryProvider.future),
    );
  }

  /// Tries to decrypt all TOTPs with the given [cryptoStore].
  /// Returns all newly decrypted TOTPs.
  Future<Set<DecryptedTotp>> tryDecryptAll(CryptoStore? cryptoStore) async {
    TotpList totpList = await future;
    state = const AsyncLoading();
    TotpList newTotpList = TotpList._(
      list: await totpList._list.decrypt(cryptoStore),
      storageType: totpList.storageType,
    );
    Set<DecryptedTotp> difference = newTotpList.decryptedTotps.toSet().difference(totpList.decryptedTotps.toSet());
    state = AsyncData(newTotpList);
    return difference;
  }

  /// Adds the given [totps].
  Future<Result<Totp>> addTotps(
    List<Totp> totps, {
    bool fromNetwork = false,
  }) => _addTotp(
    totps,
    fromNetwork: fromNetwork,
  );

  /// Adds the given [totp].
  Future<Result<Totp>> addTotp(
    Totp totp, {
    bool fromNetwork = false,
  }) => _addTotp(
    [totp],
    fromNetwork: fromNetwork,
  );

  /// Adds the given [totp].
  Future<Result<Totp>> _addTotp(
    List<Totp> totps, {
    bool fromNetwork = false,
  }) async {
    try {
      TotpList totpList = await future;
      await totpList.waitBeforeNextOperation();
      TotpDatabase database = ref.read(totpsDatabaseProvider);
      totps = [
        for (Totp totp in totps)
          if (!(await database.isMarkedAsDeleted(totp.uuid))) totp,
      ];
      if (totps.length == 1) {
        await database.addTotp(totps.first);
      } else {
        await database.addTotps(totps);
      }
      if (totpList.storageType == StorageType.shared && !fromNetwork) {
        _enqueue(
          PushOperation.setTotps(
            totps: totps,
          ),
        );
      }
      ref.read(totpImageCacheManagerProvider.notifier).fillCache(totps: totps);
      CryptoStore? cryptoStore = await ref.read(cryptoStoreProvider.future);
      state = AsyncData(
        TotpList._fromListAndStorageType(
          list: _mergeToCurrentList(totpList, totps: await totps.decrypt(cryptoStore)),
          storageType: totpList.storageType,
        ),
      );
      return const ResultSuccess();
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }

  /// Clears all TOTPs and then adds the [totps].
  Future<Result<List<Totp>>> replaceBy(List<Totp> totps, {bool fromNetwork = false}) async {
    try {
      TotpList totpList = await future;
      await totpList.waitBeforeNextOperation();
      TotpDatabase database = ref.read(totpsDatabaseProvider);
      await database.replaceTotps(totps);
      if (totpList.storageType == StorageType.shared && !fromNetwork) {
        _enqueue(
          PushOperation.deleteTotps(
            uuids: [
              for (Totp totp in totpList) totp.uuid,
            ],
          ),
          andRun: false,
        );
        _enqueue(
          PushOperation.setTotps(
            totps: totps,
          ),
        );
      }
      CryptoStore? cryptoStore = await ref.read(cryptoStoreProvider.future);
      List<Totp> decrypted = await totps.decrypt(cryptoStore);
      await ref.read(totpImageCacheManagerProvider.notifier).fillCache(totps: decrypted);
      state = AsyncData(
        TotpList._fromListAndStorageType(
          list: _mergeToCurrentList(totpList, totps: decrypted),
          storageType: totpList.storageType,
        ),
      );
      return const ResultSuccess();
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }

  /// Updates the [totp].
  Future<Result<Totp>> updateTotp(
    DecryptedTotp totp, {
    bool fromNetwork = false,
    bool insertIfNonExistent = false,
  }) async => await _updateTotps(
    [totp],
    fromNetwork: fromNetwork,
  );

  /// Updates the [totps].
  Future<Result<Totp>> updateTotps(
    List<Totp> totps, {
    bool fromNetwork = false,
  }) async => await _updateTotps(
    totps,
    fromNetwork: fromNetwork,
  );

  /// Updates the [totps].
  Future<Result<Totp>> _updateTotps(
    List<Totp> totps, {
    bool fromNetwork = false,
  }) async {
    try {
      if (totps.isEmpty) {
        return const ResultSuccess();
      }
      TotpList totpList = await future;
      await totpList.waitBeforeNextOperation();
      TotpDatabase database = ref.read(totpsDatabaseProvider);
      if (totps.length > 1) {
        await database.updateTotps(totps);
      } else {
        await database.updateTotp(totps.first);
      }
      if (totpList.storageType == StorageType.shared && !fromNetwork) {
        _enqueue(
          PushOperation.setTotps(
            totps: totps,
          ),
        );
      }
      await ref.read(totpImageCacheManagerProvider.notifier).fillCache(totps: totps);
      state = AsyncData(
        TotpList._fromListAndStorageType(
          list: _mergeToCurrentList(totpList, totps: totps),
          storageType: totpList.storageType,
        ),
      );
      return const ResultSuccess();
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }

  /// Deletes the TOTP associated with the given [uuid].
  Future<Result> deleteTotp(String uuid, {bool fromNetwork = false}) async {
    try {
      TotpList totpList = await future;
      await totpList.waitBeforeNextOperation();
      TotpDatabase database = ref.read(totpsDatabaseProvider);
      await database.deleteTotp(uuid);
      await database.markAsDeleted(uuid);
      if (totpList.storageType == StorageType.shared && !fromNetwork) {
        _enqueue(
          PushOperation.deleteTotps(
            uuids: [uuid],
          ),
        );
      }
      ref.read(totpImageCacheManagerProvider.notifier).deleteCachedImage(uuid);
      state = AsyncData(
        TotpList._fromListAndStorageType(
          list: totpList._list..removeWhere((totp) => totp.uuid == uuid),
          storageType: totpList.storageType,
        ),
      );
      return const ResultSuccess();
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }

  /// Changes the master password.
  /// Please consider doing a backup by passing a [backupPassword], and restore it in case of failure.
  Future<Result<String>> changeMasterPassword(
    String password, {
    String? backupPassword,
    Uint8List? salt,
    bool updateTotps = true,
  }) async {
    try {
      TotpList totpList = await future;
      await totpList.waitBeforeNextOperation();
      StoredCryptoStore storedCryptoStore = ref.read(cryptoStoreProvider.notifier);
      if (backupPassword != null) {
        Result<Backup> backupResult = await ref.read(backupStoreProvider.notifier).doBackup(backupPassword);
        if (backupResult is! ResultSuccess) {
          return backupResult.to((value) => null);
        }
      }
      CryptoStore? currentCryptoStore = await storedCryptoStore.future;
      if (updateTotps && currentCryptoStore != null) {
        CryptoStore newCryptoStore = await CryptoStore.fromPassword(password, currentCryptoStore.salt);
        List<Totp> newTotps = [];
        for (Totp totp in totpList) {
          DecryptedTotp? decryptedTotp = await totp.changeEncryptionKey(currentCryptoStore, newCryptoStore);
          newTotps.add(decryptedTotp ?? totp);
        }
        TotpDatabase database = ref.read(totpsDatabaseProvider);
        await database.replaceTotps(newTotps);
        if (totpList.storageType == StorageType.shared) {
          _enqueue(
            PushOperation.setTotps(
              totps: newTotps,
            ),
          );
        }
        await storedCryptoStore.changeCryptoStore(password, newCryptoStore: newCryptoStore);
      } else {
        await storedCryptoStore.changeCryptoStore(password);
      }
      return ResultSuccess(value: password);
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }

  /// Enqueues the given [operation].
  void _enqueue(PushOperation operation, {bool andRun = true}) => ref
      .read(pushOperationsQueueProvider.notifier)
      .enqueue(
        operation,
        andRun: andRun,
      );

  /// Merges the [totp] to the current TOTP list.
  List<Totp> _mergeToCurrentList(TotpList totpList, {Totp? totp, List<Totp>? totps}) {
    List<Totp> from = [
      if (totp != null) totp,
      if (totps != null)
        for (Totp totp in totps) totp,
    ];
    Set<String> uuids = {
      for (Totp totp in from) totp.uuid,
    };
    return [
      ...from,
      for (Totp totp in totpList._list)
        if (!uuids.contains(totp.uuid)) totp,
    ];
  }
}

/// Allows to easily decrypt a TOTP list.
extension _DecryptList on List<Totp> {
  /// Decrypts the current list.
  Future<List<Totp>> decrypt(CryptoStore? cryptoStore) async => [
    for (Totp totp in this) //
      await totp.decrypt(cryptoStore),
  ];
}

/// A TOTP list, with a last updated time.
class TotpList extends Iterable<Totp> {
  /// The list.
  late final List<Totp> _list;

  /// The last update time.
  final DateTime updated;

  /// The storage type.
  final StorageType storageType;

  /// Creates a new TOTP list instance.
  TotpList._({
    required List<Totp> list,
    DateTime? updated,
    required this.storageType,
    bool sort = true,
  }) : updated = updated ?? DateTime.now() {
    if (sort) {
      _list = list..sort();
    } else {
      _list = list;
    }
  }

  /// Creates a new TOTP list from the [list] and the [storage].
  TotpList._fromListAndStorageType({
    required List<Totp> list,
    required StorageType storageType,
    DateTime? updated,
  }) : this._(
         list: list,
         updated: updated,
         storageType: storageType,
       );

  /// Returns the object at the given [index] in the list.
  Totp operator [](int index) => _list[index];

  @override
  Iterator<Totp> get iterator => _list.iterator;

  /// Returns whether the list contains a TOTP with the given [uuid].
  bool has(String uuid) => _list.any((totp) => totp.uuid == uuid);

  /// Returns the index of the given [totp].
  int indexOf(Totp totp) => _list.indexOf(totp);

  /// The next possible operation time.
  DateTime get nextPossibleOperationTime => updated.add(storageType.operationThreshold);

  /// Waits before the next operation.
  Future<void> waitBeforeNextOperation() {
    DateTime now = DateTime.now();
    if (now.isAfter(nextPossibleOperationTime)) {
      return Future.value();
    }
    return Future.delayed(nextPossibleOperationTime.difference(now));
  }

  /// Returns the decrypted TOTPs list.
  List<DecryptedTotp> get decryptedTotps => [
    for (Totp totp in _list)
      if (totp.isDecrypted) totp as DecryptedTotp,
  ];
}
