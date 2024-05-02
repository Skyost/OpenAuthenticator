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
final totpRepositoryProvider = AsyncNotifierProvider.autoDispose<TotpRepository, List<Totp>>(TotpRepository.new);

/// Allows to query, register, update and delete TOTPs.
class TotpRepository extends AutoDisposeAsyncNotifier<List<Totp>> {
  @override
  FutureOr<List<Totp>> build() async {
    Storage storage = await ref.watch(storageProvider.future);
    storage.dependencies.forEach(ref.watch);
    CryptoStore? cryptoStore = await ref.watch(cryptoStoreProvider.future);
    return _queryTotpsFromStorage(storage, cryptoStore);
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
  Future<List<Totp>> _queryTotpsFromStorage(Storage storage, CryptoStore? cryptoStore) async {
    List<Totp> totps = await storage.listTotps();
    for (Totp totp in totps) {
      totp.cacheImage();
    }
    return [
      for (Totp totp in totps) //
        await totp.decrypt(cryptoStore),
    ]..sort();
  }

  /// Adds the given [totp].
  Future<Result<Totp>> addTotp(Totp totp) async {
    try {
      Storage storage = await ref.read(storageProvider.future);
      await storage.addTotp(totp);
      CryptoStore? cryptoStore = await ref.read(cryptoStoreProvider.future);
      if (cryptoStore == null) {
        throw _NoCryptoStoreException();
      }
      if (await ref.read(cacheTotpPicturesSettingsEntryProvider.future)) {
        await totp.cacheImage();
      }
      state = AsyncData([
        ...await future,
        await totp.decrypt(cryptoStore),
      ]..sort());
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
      Storage storage = await ref.read(storageProvider.future);
      await storage.clearTotps();
      await storage.addTotps(totps);
      CryptoStore? cryptoStore = await ref.read(cryptoStoreProvider.future);
      if (cryptoStore == null) {
        throw _NoCryptoStoreException();
      }
      if (await ref.read(cacheTotpPicturesSettingsEntryProvider.future)) {
        Map<String, String?> previousImages = {
          for (Totp totp in await future)
            if (totp.isDecrypted)
              totp.uuid: (totp as DecryptedTotp).imageUrl,
        };
        for (Totp totp in totps) {
          await totp.cacheImage(previousImageUrl: previousImages[totp.uuid]);
        }
      }
      state = AsyncData([for (Totp totp in totps) await totp.decrypt(cryptoStore)]..sort());
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
      Storage storage = await ref.read(storageProvider.future);
      await storage.updateTotp(uuid, totp);
      List<Totp> totps = await future;
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
      state = AsyncData(totps..sort());
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
      Storage storage = await ref.read(storageProvider.future);
      await storage.deleteTotp(totp.uuid);
      await ref.read(deletedTotpsProvider).markDeleted(totp.uuid);
      List<Totp> totps = await future;
      state = AsyncData(totps..removeWhere((currentTotp) => currentTotp.uuid == totp.uuid));
      totp.deleteCachedImage();
      return const ResultSuccess();
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }

  /// Returns whether the limit will be exceeded if one more TOTP is added.
  Future<bool> willExceedIfAddMore({
    int count = 1,
    StorageType? storageType,
    ContributorPlanState? contributorPlanState,
    List<Totp>? totps,
  }) async {
    storageType ??= await ref.read(storageTypeSettingsEntryProvider.future);
    if (storageType == StorageType.local) {
      return false;
    }
    contributorPlanState ??= await ref.read(contributorPlanStateProvider.future);
    if (contributorPlanState == ContributorPlanState.active) {
      return false;
    }
    totps ??= await ref.read(totpRepositoryProvider.future);
    return totps!.length + count >= App.freeTotpsLimit;
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
      StoredCryptoStore storedCryptoStore = ref.read(cryptoStoreProvider.notifier);
      CryptoStore? currentCryptoStore = await storedCryptoStore.future;
      if (currentCryptoStore == null) {
        List<Totp> totps = await ref.read(totpRepositoryProvider.future);
        return totps.isEmpty ? const ResultSuccess() : ResultError();
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
        List<Totp> totps = await future;
        List<Totp> newTotps = [];
        for (Totp totp in totps) {
          DecryptedTotp? decryptedTotp = await totp.changeEncryptionKey(currentCryptoStore, newCryptoStore);
          newTotps.add(decryptedTotp ?? totp);
        }
        await storage.clearTotps();
        await storedCryptoStore.saveAndUse(newCryptoStore);
        await storage.addTotps(newTotps);
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

/// The TOTP limit reached provider.
final totpLimitExceededProvider = AsyncNotifierProvider.autoDispose<TotpLimitExceededNotifier, bool>(TotpLimitExceededNotifier.new);

/// The TOTP limit reached notifier.
class TotpLimitExceededNotifier extends AutoDisposeAsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    StorageType storageType = await ref.watch(storageTypeSettingsEntryProvider.future);
    ContributorPlanState contributorPlanState = await ref.watch(contributorPlanStateProvider.future);
    List<Totp> totps = await ref.watch(totpRepositoryProvider.future);
    return await willExceedIfAddMore(
      count: 0,
      storageType: storageType,
      contributorPlanState: contributorPlanState,
      totps: totps,
    );
  }

  /// Returns whether the limit will be exceeded if one more TOTP is added.
  Future<bool> willExceedIfAddMore({
    int count = 1,
    StorageType? storageType,
    ContributorPlanState? contributorPlanState,
    List<Totp>? totps,
  }) async {
    storageType ??= await ref.read(storageTypeSettingsEntryProvider.future);
    if (storageType == StorageType.local) {
      return false;
    }
    contributorPlanState ??= await ref.read(contributorPlanStateProvider.future);
    if (contributorPlanState == ContributorPlanState.active) {
      return false;
    }
    totps ??= await ref.read(totpRepositoryProvider.future);
    return totps!.length + count > App.freeTotpsLimit;
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
