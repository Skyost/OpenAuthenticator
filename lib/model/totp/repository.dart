import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/model/backup.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/purchases/contributor_plan.dart';
import 'package:open_authenticator/model/settings/storage_type.dart';
import 'package:open_authenticator/model/storage/storage.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';
import 'package:open_authenticator/model/totp/deleted_totps.dart';
import 'package:open_authenticator/model/totp/image_cache.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/utils/utils.dart';

/// The provider instance.
final totpRepositoryProvider = AsyncNotifierProvider.autoDispose<TotpRepository, TotpList>(TotpRepository.new);

/// Allows to query, register, update and delete TOTPs.
class TotpRepository extends AutoDisposeAsyncNotifier<TotpList> {
  @override
  FutureOr<TotpList> build() async {
    Storage storage = await ref.watch(storageProvider.future);
    CryptoStore? cryptoStore = await ref.watch(cryptoStoreProvider.future);
    return TotpList._fromListAndStorage(
      list: await (await storage.listTotps()).decrypt(cryptoStore),
      storage: storage,
    );
  }

  /// Tries to decrypt all TOTPs with the given [cryptoStore].
  /// Returns all newly decrypted TOTPs.
  Future<Set<DecryptedTotp>> tryDecryptAll(CryptoStore? cryptoStore) async {
    TotpList totpList = await future;
    state = const AsyncLoading();
    TotpList newTotpList = TotpList._(
      list: await totpList._list.decrypt(cryptoStore),
      operationThreshold: totpList.operationThreshold,
    );
    Set<DecryptedTotp> difference = newTotpList.decryptedTotps.toSet().difference(totpList.decryptedTotps.toSet());
    state = AsyncData(newTotpList);
    return difference;
  }

  /// Refreshes the current state.
  Future<void> refresh() async {
    AsyncValue<TotpList> currentState = state;
    Future<void> refresh([TotpList? totpList]) async {
      state = const AsyncLoading();
      try {
        await totpList?.waitBeforeNextOperation();
        Storage storage = await ref.read(storageProvider.future);
        CryptoStore? cryptoStore = await ref.read(cryptoStoreProvider.future);
        state = AsyncData(await _queryTotpsFromStorage(storage, cryptoStore));
      } catch (ex, stacktrace) {
        handleException(ex, stacktrace);
        state = AsyncError(ex, stacktrace);
      }
    }

    switch (currentState) {
      case AsyncData(:final value):
        await refresh(value);
        break;
      case AsyncError():
        await refresh();
        break;
      default:
        break;
    }
  }

  /// Queries TOTPs (and decrypt them) from storage.
  Future<TotpList> _queryTotpsFromStorage(Storage storage, CryptoStore? cryptoStore) async {
    List<Totp> totps = await storage.listTotps();
    TotpImageCacheManager totpImageCacheManager = ref.read(totpImageCacheManagerProvider.notifier);
    totpImageCacheManager.fillCache();
    return TotpList._fromListAndStorage(
      list: await totps.decrypt(cryptoStore),
      storage: storage,
    );
  }

  /// Adds the given [totp].
  Future<Result<Totp>> addTotp(Totp totp) async {
    try {
      TotpList totpList = await future;
      await totpList.waitBeforeNextOperation();
      Storage storage = await ref.read(storageProvider.future);
      await storage.addTotp(totp);
      TotpImageCacheManager totpImageCacheManager = ref.read(totpImageCacheManagerProvider.notifier);
      totpImageCacheManager.cacheImage(totp);
      CryptoStore? cryptoStore = await ref.read(cryptoStoreProvider.future);
      state = AsyncData(
        TotpList._fromListAndStorage(
          list: _mergeToCurrentList(totpList, totp: await totp.decrypt(cryptoStore)),
          storage: storage,
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
  Future<Result<List<Totp>>> replaceBy(List<Totp> totps) async {
    try {
      TotpList totpList = await future;
      await totpList.waitBeforeNextOperation();
      Storage storage = await ref.read(storageProvider.future);
      await storage.replaceTotps(totps);
      CryptoStore? cryptoStore = await ref.read(cryptoStoreProvider.future);
      List<Totp> decrypted = await totps.decrypt(cryptoStore);
      TotpImageCacheManager totpImageCacheManager = ref.read(totpImageCacheManagerProvider.notifier);
      for (Totp updatedTotp in decrypted) {
        await totpImageCacheManager.cacheImage(updatedTotp);
      }
      state = AsyncData(
        TotpList._fromListAndStorage(
          list: _mergeToCurrentList(totpList, totps: decrypted),
          storage: storage,
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
  Future<Result<Totp>> updateTotp(DecryptedTotp totp) async => await _updateTotps([totp]);

  /// Updates the [totps].
  Future<Result<Totp>> updateTotps(List<Totp> totps) async => await _updateTotps(totps);

  /// Updates the [totps].
  Future<Result<Totp>> _updateTotps(List<Totp> totps) async {
    try {
      if (totps.isEmpty) {
        return const ResultSuccess();
      }
      TotpList totpList = await future;
      await totpList.waitBeforeNextOperation();
      Storage storage = await ref.read(storageProvider.future);
      if (totps.length > 1) {
        await storage.updateTotps(totps);
      } else {
        await storage.updateTotp(totps.first);
      }
      TotpImageCacheManager totpImageCacheManager = ref.read(totpImageCacheManagerProvider.notifier);
      for (Totp totp in totps) {
        await totpImageCacheManager.cacheImage(totp);
      }
      state = AsyncData(
        TotpList._fromListAndStorage(
          list: _mergeToCurrentList(totpList, totps: totps),
          storage: storage,
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
  Future<Result> deleteTotp(String uuid) async {
    try {
      TotpList totpList = await future;
      await totpList.waitBeforeNextOperation();
      Storage storage = await ref.read(storageProvider.future);
      await storage.deleteTotp(uuid);
      await ref.read(deletedTotpsProvider).markDeleted(uuid);
      TotpImageCacheManager totpImageCacheManager = ref.read(totpImageCacheManagerProvider.notifier);
      totpImageCacheManager.deleteCachedImage(uuid);
      state = AsyncData(
        TotpList._fromListAndStorage(
          list: totpList._list..removeWhere((totp) => totp.uuid == uuid),
          storage: storage,
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
        Storage storage = await ref.read(storageProvider.future);
        List<Totp> newTotps = [];
        for (Totp totp in totpList) {
          DecryptedTotp? decryptedTotp = await totp.changeEncryptionKey(currentCryptoStore, newCryptoStore);
          newTotps.add(decryptedTotp ?? totp);
        }
        await storage.replaceTotps(newTotps);
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

  /// The time to wait between two operations.
  final Duration operationThreshold;

  /// Creates a new TOTP list instance.
  TotpList._({
    required List<Totp> list,
    DateTime? updated,
    required this.operationThreshold,
    bool sort = true,
  }) : updated = updated ?? DateTime.now() {
    if (sort) {
      _list = list..sort();
    } else {
      _list = list;
    }
  }

  /// Creates a new TOTP list from the [list] and the [storage].
  TotpList._fromListAndStorage({
    required List<Totp> list,
    required Storage storage,
    DateTime? updated,
  }) : this._(
          list: list,
          updated: updated,
          operationThreshold: storage.operationThreshold,
        );

  /// Returns the object at the given [index] in the list.
  Totp operator [](int index) => _list[index];

  @override
  Iterator<Totp> get iterator => _list.iterator;

  /// Returns the index of the given [totp].
  int indexOf(Totp totp) => _list.indexOf(totp);

  /// The next possible operation time.
  DateTime get nextPossibleOperationTime => updated.add(operationThreshold);

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

/// The TOTP limit provider.
final totpLimitProvider = FutureProvider<TotpLimit>((ref) async {
  StorageType storageType = await ref.watch(storageTypeSettingsEntryProvider.future);
  ContributorPlanState contributorPlanState = await ref.watch(contributorPlanStateProvider.future);
  TotpList totps = await ref.watch(totpRepositoryProvider.future);
  return TotpLimit(
    storageType: storageType,
    contributorPlanState: contributorPlanState,
    currentTotpCount: totps.length,
  );
});

/// The class that allows to check whether TOTP limit has been reached.
class TotpLimit {
  /// The storage type.
  final StorageType storageType;

  /// The contributor plan state.
  final ContributorPlanState contributorPlanState;

  /// The current TOTP count.
  final int currentTotpCount;

  /// Creates a new TOTP limit instance.
  const TotpLimit({
    required this.storageType,
    required this.contributorPlanState,
    required this.currentTotpCount,
  });

  /// Returns whether the limit will be exceeded if one more TOTP is added.
  bool _willExceedIfAddMore({
    int count = 1,
    StorageType? storageType,
  }) {
    if ((storageType ?? this.storageType) == StorageType.local || contributorPlanState == ContributorPlanState.active) {
      return false;
    }
    return currentTotpCount + count > App.freeTotpsLimit;
  }

  /// Returns whether the limit will be exceeded if one more TOTP is added.
  bool willExceedIfAddMore({int count = 1}) => _willExceedIfAddMore(
        count: count,
      );

  /// Returns whether the user should be able to change the current storage type.
  bool canChangeStorageType(StorageType currentStorageType) {
    if (currentStorageType == StorageType.online) {
      return true;
    }
    return !_willExceedIfAddMore(
      count: 0,
      storageType: currentStorageType == StorageType.online ? StorageType.local : StorageType.online,
    );
  }

  /// Returns whether the TOTP limit is exceeded.
  bool get isExceeded => willExceedIfAddMore(count: 0);
}
