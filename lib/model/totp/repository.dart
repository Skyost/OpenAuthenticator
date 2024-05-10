import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/model/backup.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/purchases/contributor_plan.dart';
import 'package:open_authenticator/model/settings/cache_totp_pictures.dart';
import 'package:open_authenticator/model/settings/storage_type.dart';
import 'package:open_authenticator/model/storage/storage.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';
import 'package:open_authenticator/model/totp/deleted_totps.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/utils/utils.dart';

/// The provider instance.
final totpRepositoryProvider = AsyncNotifierProvider.autoDispose<TotpRepository, TotpList>(TotpRepository.new);

/// Allows to query, register, update and delete TOTPs.
class TotpRepository extends AutoDisposeAsyncNotifier<TotpList> with StorageListener {
  @override
  FutureOr<TotpList> build() async {
    Storage storage = await ref.watch(storageProvider.future);
    await ref.watch(cryptoStoreProvider.future);
    storage.addListener(this);
    ref.onDispose(() => storage.removeListener(this));
    return TotpList._fromListAndStorage(
      list: await storage.firstRead(),
      storage: storage,
    );
  }

  /// Tries to decrypt all TOTPs with the given [cryptoStore].
  Future<void> tryDecryptAll(CryptoStore? cryptoStore) async {
    TotpList totpList = await future;
    state = const AsyncLoading();
    state = AsyncData(TotpList._(
      list: await totpList._list.decrypt(cryptoStore),
      operationThreshold: totpList.operationThreshold,
    ));
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
    for (Totp totp in totps) {
      totp.cacheImage();
    }
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
      return const ResultSuccess();
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }

  /// Updates the TOTP associated with the specified [uuid].
  Future<Result<Totp>> updateTotp(String uuid, DecryptedTotp totp) async {
    try {
      TotpList totpList = await future;
      await totpList.waitBeforeNextOperation();
      Storage storage = await ref.read(storageProvider.future);
      await storage.updateTotp(uuid, totp);
      return const ResultSuccess();
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }

  /// Deletes the TOTP associated with the given [uuid].
  Future<Result> deleteTotp(Totp totp) async {
    try {
      TotpList totpList = await future;
      await totpList.waitBeforeNextOperation();
      Storage storage = await ref.read(storageProvider.future);
      await storage.deleteTotp(totp.uuid);
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
  Future<Result> changeMasterPassword(
    String password, {
    String? backupPassword,
    Uint8List? salt,
    updateTotps = true,
  }) async {
    try {
      TotpList totpList = await future;
      await totpList.waitBeforeNextOperation();
      StoredCryptoStore storedCryptoStore = ref.read(cryptoStoreProvider.notifier);
      CryptoStore? currentCryptoStore = await storedCryptoStore.future;
      if (currentCryptoStore == null) {
        return totpList.isEmpty ? const ResultSuccess() : ResultError();
      }
      Storage storage = await ref.read(storageProvider.future);
      CryptoStore newCryptoStore = await CryptoStore.fromPassword(password, currentCryptoStore.salt);
      if (backupPassword != null) {
        Result<Backup> backupResult = await ref.read(backupStoreProvider.notifier).doBackup(backupPassword);
        if (backupResult is! ResultSuccess) {
          return backupResult.to((value) => null);
        }
      }
      if (updateTotps) {
        List<Totp> newTotps = [];
        for (Totp totp in totpList) {
          DecryptedTotp? decryptedTotp = await totp.changeEncryptionKey(currentCryptoStore, newCryptoStore);
          newTotps.add(decryptedTotp ?? totp);
        }
        await storage.replaceTotps(newTotps);
        await storedCryptoStore.saveAndUse(newCryptoStore);
      } else {
        await storedCryptoStore.saveAndUse(newCryptoStore);
      }
      return const ResultSuccess();
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }

  @override
  Future<void> onTotpsAdded(List<Totp> totps) async {
    if (await ref.read(cacheTotpPicturesSettingsEntryProvider.future)) {
      for (Totp totp in totps) {
        totp.cacheImage();
      }
    }
    CryptoStore? cryptoStore = await ref.read(cryptoStoreProvider.future);
    state = AsyncData(
      TotpList._fromListAndStorage(
        list: await _mergeToCurrentList(await totps.decrypt(cryptoStore)),
        storage: await ref.read(storageProvider.future),
      ),
    );
  }

  @override
  Future<void> onTotpsDeleted(List<String> uuids) async {
    for (String uuid in uuids) {
      await ref.read(deletedTotpsProvider).markDeleted(uuid);
      (await TotpImageCache.getTotpCachedImage(uuid)).deleteIfExists();
    }
    state = AsyncData(
      TotpList._fromListAndStorage(
        list: (await future)._list..removeWhere((totp) => uuids.contains(totp.uuid)),
        storage: await ref.read(storageProvider.future),
      ),
    );
  }

  @override
  Future<void> onTotpsUpdated(List<Totp> totps) async {
    CryptoStore? cryptoStore = await ref.read(cryptoStoreProvider.future);
    List<Totp> decrypted = await totps.decrypt(cryptoStore);
    if (await ref.read(cacheTotpPicturesSettingsEntryProvider.future)) {
      TotpList totpList = await future;
      Map<String, String> previousImages = {
        for (Totp currentTotp in totpList)
          if (currentTotp.isDecrypted && (currentTotp as DecryptedTotp).imageUrl != null)
            currentTotp.uuid: currentTotp.imageUrl!,
      };
      for (Totp updatedTotp in decrypted) {
        await updatedTotp.cacheImage(previousImageUrl: previousImages[updatedTotp.uuid]);
      }
    }

    state = AsyncData(
      TotpList._fromListAndStorage(
        list: await _mergeToCurrentList(decrypted),
        storage: await ref.read(storageProvider.future),
      ),
    );
  }

  /// Merges the [from] list to the current TOTP list.
  Future<List<Totp>> _mergeToCurrentList(List<Totp> from) async {
    Set<String> uuids = from.map((totp) => totp.uuid).toSet();
    TotpList totpList = await future;
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
}

/// The TOTP limit reached provider.
final totpLimitExceededProvider = AsyncNotifierProvider.autoDispose<TotpLimitExceededNotifier, bool>(TotpLimitExceededNotifier.new);

/// The TOTP limit reached notifier.
class TotpLimitExceededNotifier extends AutoDisposeAsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    StorageType storageType = await ref.watch(storageTypeSettingsEntryProvider.future);
    ContributorPlanState contributorPlanState = await ref.watch(contributorPlanStateProvider.future);
    TotpList totps = await ref.watch(totpRepositoryProvider.future);
    return await willExceedIfAddMore(
      count: 0,
      storageType: storageType,
      contributorPlanState: contributorPlanState,
      currentTotpCount: totps.length,
    );
  }

  /// Returns whether the limit will be exceeded if one more TOTP is added.
  Future<bool> willExceedIfAddMore({
    int count = 1,
    StorageType? storageType,
    ContributorPlanState? contributorPlanState,
    int? currentTotpCount,
  }) async {
    storageType ??= await ref.read(storageTypeSettingsEntryProvider.future);
    if (storageType == StorageType.local) {
      return false;
    }
    contributorPlanState ??= await ref.read(contributorPlanStateProvider.future);
    if (contributorPlanState == ContributorPlanState.active) {
      return false;
    }
    currentTotpCount ??= (await ref.read(totpRepositoryProvider.future)).length;
    return currentTotpCount + count > App.freeTotpsLimit;
  }

  /// Returns whether the user should be able to change the current storage type.
  Future<bool> canChangeStorageType(StorageType currentStorageType) async {
    if (currentStorageType == StorageType.online) {
      return true;
    }
    return !(await willExceedIfAddMore(
      count: 0,
      storageType: currentStorageType == StorageType.online ? StorageType.local : StorageType.online,
    ));
  }
}
