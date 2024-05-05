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
import 'package:path/path.dart';

/// The provider instance.
final totpRepositoryProvider = AsyncNotifierProvider.autoDispose<TotpRepository, TotpList>(TotpRepository.new);

/// Allows to query, register, update and delete TOTPs.
class TotpRepository extends AutoDisposeAsyncNotifier<TotpList> {
  @override
  FutureOr<TotpList> build() async {
    Storage storage = await ref.watch(storageProvider.future);
    storage.dependencies.forEach(ref.watch);
    CryptoStore? cryptoStore = await ref.watch(cryptoStoreProvider.future);
    return _queryTotpsFromStorage(storage, cryptoStore);
  }

  /// Tries to decrypt all TOTPs with the given [cryptoStore].
  Future<void> tryDecryptAll(CryptoStore? cryptoStore) async {
    TotpList totpList = await future;
    state = const AsyncLoading();
    state = AsyncData(TotpList._(
      list: [
        for (Totp totp in totpList) //
          await totp.decrypt(cryptoStore),
      ],
      operationThreshold: totpList.operationThreshold,
    ));
  }

  /// Refreshes the current state.
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      Storage storage = await ref.read(storageProvider.future);
      CryptoStore? cryptoStore = await ref.read(cryptoStoreProvider.future);
      state = AsyncData(await _queryTotpsFromStorage(storage, cryptoStore));
    } catch (ex, stacktrace) {
      handleException(ex, stacktrace);
      state = AsyncError(ex, stacktrace);
    }
  }

  /// Queries TOTPs (and decrypt them) from storage.
  Future<TotpList> _queryTotpsFromStorage(Storage storage, CryptoStore? cryptoStore) async {
    List<Totp> totps = await storage.listTotps();
    for (Totp totp in totps) {
      totp.cacheImage();
    }
    return TotpList._fromListAndStorage(
      list: [
        for (Totp totp in totps) //
          await totp.decrypt(cryptoStore),
      ],
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
      if (await ref.read(cacheTotpPicturesSettingsEntryProvider.future)) {
        await totp.cacheImage();
      }
      CryptoStore? cryptoStore = await ref.read(cryptoStoreProvider.future);
      state = AsyncData(
        TotpList._fromListAndStorage(
          list: [
            ...totpList,
            await totp.decrypt(cryptoStore),
          ],
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
      if (await ref.read(cacheTotpPicturesSettingsEntryProvider.future)) {
        Map<String, String?> previousImages = {
          for (Totp totp in await future)
            if (totp.isDecrypted) totp.uuid: (totp as DecryptedTotp).imageUrl,
        };
        for (Totp totp in totps) {
          await totp.cacheImage(previousImageUrl: previousImages[totp.uuid]);
        }
      }
      CryptoStore? cryptoStore = await ref.read(cryptoStoreProvider.future);
      state = AsyncData(
        TotpList._fromListAndStorage(
          list: [
            for (Totp totp in totps) //
              await totp.decrypt(cryptoStore),
          ],
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

  /// Updates the TOTP associated with the specified [uuid].
  Future<Result<Totp>> updateTotp(String uuid, DecryptedTotp totp) async {
    try {
      TotpList totpList = await future;
      await totpList.waitBeforeNextOperation();
      Storage storage = await ref.read(storageProvider.future);
      await storage.updateTotp(uuid, totp);
      List<Totp> totps = totpList._list;
      Totp? previous = totps.firstWhereOrNull((totp) => totp.uuid == uuid);
      if (previous != null) {
        if (!totp.isDecrypted && previous.isDecrypted) {
          totp = DecryptedTotp.fromTotp(
            totp: totp,
            decryptedData: (current as DecryptedTotp).decryptedData,
          );
        }
        totps.remove(previous);
      }
      totps.add(totp);
      if (await ref.read(cacheTotpPicturesSettingsEntryProvider.future)) {
        await totp.cacheImage(previousImageUrl: previous != null && previous.isDecrypted ? (previous as DecryptedTotp).imageUrl : null);
      }
      state = AsyncData(
        TotpList._fromListAndStorage(
          list: totps,
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

  /// Deletes the TOTP associated to the given [uuid].
  Future<Result> deleteTotp(Totp totp) async {
    try {
      TotpList totpList = await future;
      await totpList.waitBeforeNextOperation();
      Storage storage = await ref.read(storageProvider.future);
      await storage.deleteTotp(totp.uuid);
      await ref.read(deletedTotpsProvider).markDeleted(totp.uuid);
      state = AsyncData(
        TotpList._fromListAndStorage(
          list: totpList._list..removeWhere((currentTotp) => currentTotp.uuid == totp.uuid),
          storage: storage,
        ),
      );
      totp.deleteCachedImage();
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

/// Thrown when we can't get the current crypto store instance.
class _NoCryptoStoreException implements Exception {
  @override
  String toString() => 'Failed to get current crypto store';
}
