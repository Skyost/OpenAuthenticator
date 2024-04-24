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
      if (kDebugMode) {
        print(ex);
        print(stacktrace);
      }
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

  /// Tries to decrypt all TOTPs.
  Future<bool> tryDecryptAll(CryptoStore? cryptoStore) async {
    List<Totp> totps = await future;
    // List<Totp> decryptedTotps = [];
    for (Totp totp in totps) {
      Totp decryptedTotp = await totp.decrypt(cryptoStore);
      if (!decryptedTotp.isDecrypted) {
        return false;
      }
      // decryptedTotps.add(decryptedTotp);
    }
    // state = AsyncData(decryptedTotps);
    return true;
  }

  /// Adds the given [totp].
  Future<bool> addTotp(Totp totp) async {
    Storage storage = await ref.read(storageProvider.future);
    if (!await storage.addTotp(totp)) {
      return false;
    }
    CryptoStore? cryptoStore = await ref.read(cryptoStoreProvider.future);
    if (cryptoStore == null) {
      return false;
    }
    if (await ref.read(cacheTotpPicturesSettingsEntryProvider.future)) {
      await totp.cacheImage();
    }
    state = AsyncData([
      ...await future,
      await totp.decrypt(cryptoStore),
    ]..sort());
    return true;
  }

  /// Clears all TOTPs and then adds the [totps].
  Future<bool> replaceBy(List<Totp> totps) async {
    Storage storage = await ref.read(storageProvider.future);
    if (!await storage.clearTotps() || !await storage.addTotps(totps)) {
      return false;
    }
    CryptoStore? cryptoStore = await ref.read(cryptoStoreProvider.future);
    if (cryptoStore == null) {
      return false;
    }
    if (await ref.read(cacheTotpPicturesSettingsEntryProvider.future)) {
      Map<String, String?> previousImages = {
        for (Totp totp in await future) //
          totp.uuid: totp.imageUrl,
      };
      for (Totp totp in totps) {
        await totp.cacheImage(previousImageUrl: previousImages[totp.uuid]);
      }
    }
    state = AsyncData([for (Totp totp in totps) await totp.decrypt(cryptoStore)]..sort());
    return true;
  }

  /// Updates the TOTP associated with the specified [uuid].
  Future<bool> updateTotp(String uuid, Totp totp) async {
    Storage storage = await ref.read(storageProvider.future);
    if (!await storage.updateTotp(uuid, totp)) {
      return false;
    }
    List<Totp> totps = await future;
    Totp? previous = totps.firstWhereOrNull((totp) => totp.uuid == uuid);
    if (previous != null) {
      if (!totp.isDecrypted && previous.isDecrypted) {
        totp = DecryptedTotp.fromTotp(
          totp: totp,
          decryptedSecret: (current as DecryptedTotp).decryptedSecret,
        );
      }
      totps.remove(previous);
    }
    totps.add(totp);
    if (await ref.read(cacheTotpPicturesSettingsEntryProvider.future)) {
      await totp.cacheImage(previousImageUrl: previous?.imageUrl);
    }
    state = AsyncData(totps..sort());
    return true;
  }

  /// Deletes the TOTP associated to the given [uuid].
  Future<bool> deleteTotp(Totp totp) async {
    Storage storage = await ref.read(storageProvider.future);
    if (!await storage.deleteTotp(totp.uuid)) {
      return false;
    }
    await ref.read(deletedTotpsProvider).markDeleted(totp.uuid);
    List<Totp> totps = await future;
    state = AsyncData(totps..removeWhere((currentTotp) => currentTotp.uuid == totp.uuid));
    totp.deleteCachedImage();
    return true;
  }

  /// Changes the master password.
  /// Please consider doing a backup by passing a [backupPassword], and restore it in case of failure.
  Future<bool> changeMasterPassword(
    String password, {
    String? backupPassword,
    Uint8List? salt,
    updateTotps = true,
  }) async {
    StoredCryptoStore storedCryptoStore = ref.read(cryptoStoreProvider.notifier);
    CryptoStore? currentCryptoStore = await storedCryptoStore.future;
    if (currentCryptoStore == null) {
      List<Totp> totps = await ref.read(totpRepositoryProvider.future);
      return totps.isEmpty;
    }
    Storage storage = await ref.read(storageProvider.future);
    CryptoStore? newCryptoStore = await CryptoStore.fromPassword(password, salt: await storage.readSecretsSalt());
    if (newCryptoStore == null) {
      return false;
    }
    if (backupPassword != null) {
      Backup? backup = await ref.read(backupStoreProvider.notifier).doBackup(backupPassword);
      if (backup == null) {
        return false;
      }
    }
    if (updateTotps) {
      List<Totp> totps = await future;
      List<Totp> totpsEncryptedWithNewKey = [];
      for (Totp totp in totps) {
        DecryptedTotp? decryptedTotp = await totp.changeEncryptionKey(currentCryptoStore, newCryptoStore);
        if (decryptedTotp == null) {
          return false;
        }
        totpsEncryptedWithNewKey.add(decryptedTotp);
      }
      await storage.clearTotps();
      await storedCryptoStore.saveAndUse(newCryptoStore);
      await storage.addTotps(totpsEncryptedWithNewKey);
    } else {
      await storedCryptoStore.saveAndUse(newCryptoStore);
    }
    return true;
  }
}

/// The TOTP limit reached provider.
final totpLimitReachedProvider = AsyncNotifierProvider.autoDispose<TotpLimitReachedNotifier, bool>(TotpLimitReachedNotifier.new);

/// The TOTP limit reached notifier.
class TotpLimitReachedNotifier extends AutoDisposeAsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    StorageType storageType = await ref.watch(storageTypeSettingsEntryProvider.future);
    ContributorPlanState contributorPlanState = await ref.watch(contributorPlanStateProvider.future);
    List<Totp> totps = await ref.watch(totpRepositoryProvider.future);
    return willExceedIAddMore(
      count: 0,
      storageType: storageType,
      contributorPlanState: contributorPlanState,
      totps: totps,
    );
  }

  /// Returns whether the limit will be exceeded if one more TOTP is added.
  Future<bool> willExceedIAddMore({
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
}
