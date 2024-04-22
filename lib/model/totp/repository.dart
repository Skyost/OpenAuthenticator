import 'dart:async';
import 'dart:io';

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
import 'package:open_authenticator/model/totp/algorithm.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';
import 'package:open_authenticator/model/totp/deleted_totps.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/utils/utils.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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
      _cacheTotpImage(totp, checkExists: true);
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
  Future<bool> addTotp(Totp totp, {bool? cacheTotpImage}) async {
    Storage storage = await ref.read(storageProvider.future);
    if (!await storage.addTotp(totp)) {
      return false;
    }
    CryptoStore? cryptoStore = await ref.read(cryptoStoreProvider.future);
    if (cryptoStore == null) {
      return false;
    }
    List<Totp> totps = await future;
    cacheTotpImage ??= await ref.read(cacheTotpPicturesSettingsEntryProvider.future);
    if (cacheTotpImage!) {
      await _cacheTotpImage(totp);
    }
    state = AsyncData([
      ...totps,
      await totp.decrypt(cryptoStore),
    ]..sort());
    return true;
  }

  /// Clears all TOTPs and then add the [totps].
  Future<bool> replaceBy(List<Totp> totps, {bool? cacheTotpImages}) async {
    Storage storage = await ref.read(storageProvider.future);
    if (!await storage.clearTotps() || !await storage.addTotps(totps)) {
      return false;
    }
    CryptoStore? cryptoStore = await ref.read(cryptoStoreProvider.future);
    if (cryptoStore == null) {
      return false;
    }
    cacheTotpImages ??= await ref.read(cacheTotpPicturesSettingsEntryProvider.future);
    if (cacheTotpImages!) {
      for (Totp totp in totps) {
        await _cacheTotpImage(totp);
      }
    }
    state = AsyncData([for (Totp totp in totps) await totp.decrypt(cryptoStore)]..sort());
    return true;
  }

  /// Updates the TOTP associated with the specified [uuid].
  Future<bool> updateTotp(
    String uuid, {
    String? label,
    String? issuer,
    Algorithm? algorithm,
    int? digits,
    int? validity,
    String? imageUrl,
    bool? cacheTotpImage,
  }) async {
    Storage storage = await ref.read(storageProvider.future);
    if (!await storage.updateTotp(
      uuid,
      label: label,
      issuer: issuer,
      algorithm: algorithm,
      digits: digits,
      validity: validity,
      imageUrl: imageUrl,
    )) {
      return false;
    }
    Totp? result = await storage.getTotp(uuid);
    if (result == null) {
      return false;
    }
    List<Totp> totps = await future;
    Totp? current = totps.firstWhereOrNull((totp) => totp.uuid == uuid);
    if (current != null && current.isDecrypted) {
      result = DecryptedTotp.fromTotp(
        totp: result,
        decryptedSecret: (current as DecryptedTotp).decryptedSecret,
      );
    }
    totps.removeWhere((totp) => totp.uuid == uuid);
    totps.add(result);
    cacheTotpImage ??= await ref.read(cacheTotpPicturesSettingsEntryProvider.future);
    if (cacheTotpImage!) {
      await _cacheTotpImage(result);
    }
    state = AsyncData(totps..sort());
    return true;
  }

  /// Deletes the TOTP associated to the given [uuid].
  Future<bool> deleteTotp(String uuid) async {
    Storage storage = await ref.read(storageProvider.future);
    if (!await storage.deleteTotp(uuid)) {
      return false;
    }
    await ref.read(deletedTotpsProvider).markDeleted(uuid);
    List<Totp> totps = await future;
    totps.removeWhere((totp) => totp.uuid == uuid);
    state = AsyncData(totps);
    File cachedImage = await getTotpCachedImage(uuid);
    if (cachedImage.existsSync()) {
      cachedImage.deleteSync();
    }
    return true;
  }

  /// Caches the TOTP image.
  static Future<void> _cacheTotpImage(Totp totp, {bool checkExists = false}) async {
    if (totp.imageUrl == null) {
      return;
    }
    File file = await getTotpCachedImage(totp.uuid, createDirectory: true);
    if (checkExists && file.existsSync()) {
      return;
    }
    HttpClientRequest request = await HttpClient().getUrl(Uri.parse(totp.imageUrl!));
    HttpClientResponse response = await request.close();
    Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    await file.writeAsBytes(bytes);
  }

  /// Returns the TOTP cached image file.
  static Future<File> getTotpCachedImage(String uuid, {bool createDirectory = false}) async => File(join((await _getTotpImagesDirectory(create: createDirectory)).path, uuid));

  /// Returns the totp images directory, creating it if doesn't exist yet.
  static Future<Directory> _getTotpImagesDirectory({bool create = false}) async {
    Directory directory = Directory(join((await getApplicationCacheDirectory()).path, 'totps_images'));
    if (create && !directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    return directory;
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
