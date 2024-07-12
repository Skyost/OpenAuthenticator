import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:open_authenticator/model/settings/cache_totp_pictures.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/utils/utils.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// The TOTP image cache manager provider.
final totpImageCacheManagerProvider = AsyncNotifierProvider.autoDispose<TotpImageCacheManager, Map<String, String>>(TotpImageCacheManager.new);

/// Manages the cache of TOTPs images.
class TotpImageCacheManager extends AutoDisposeAsyncNotifier<Map<String, String>> {
  @override
  FutureOr<Map<String, String>> build() async {
    File index = await _getIndexFile();
    return index.existsSync() ? jsonDecode(index.readAsStringSync()).cast<String, String>() : {};
  }

  /// Caches the TOTP image.
  Future<void> cacheImage(Totp totp, {bool checkSettings = true}) async {
    try {
      if (!totp.isDecrypted) {
        return;
      }
      if (checkSettings) {
        bool cacheEnabled = await ref.read(cacheTotpPicturesSettingsEntryProvider.future);
        if (!cacheEnabled) {
          return;
        }
      }
      String? imageUrl = (totp as DecryptedTotp).imageUrl;
      if (imageUrl == null) {
        await deleteCachedImage(totp.uuid);
      } else {
        Map<String, String> cached = Map.from(await future);
        String? previousImageUrl = cached[totp.uuid];
        File file = await _getTotpCachedImageFile(totp.uuid, createDirectory: true);
        if (previousImageUrl == imageUrl && file.existsSync()) {
          return;
        }
        http.Response response = await http.get(Uri.parse(imageUrl));
        await file.writeAsBytes(response.bodyBytes);
        cached[totp.uuid] = imageUrl;
        state = AsyncData(cached);
        imageCache.clear();
        _saveIndex(content: cached);
      }
    } catch (ex, stacktrace) {
      handleException(ex, stacktrace);
    }
  }

  /// Returns the cached image that corresponds to the TOTP UUID and current image URL.
  static Future<File?> getCachedImage(Map<String, String> cached, String uuid, String? imageUrl) async {
    if (!cached.containsKey(uuid)) {
      return null;
    }
    String? cachedImageUrl = cached[uuid];
    if (cachedImageUrl != imageUrl) {
      return null;
    }
    return _getTotpCachedImageFile(uuid);
  }

  /// Deletes the cached image, if possible.
  Future<void> deleteCachedImage(String uuid) async {
    Map<String, String> cached = Map.from(await future);
    File file = await _getTotpCachedImageFile(uuid);
    await file.deleteIfExists();
    cached.remove(uuid);
    state = AsyncData(cached);
    _saveIndex(content: cached);
  }

  /// Fills the cache with all TOTPs that can be read from the TOTP repository.
  Future<void> fillCache({bool checkSettings = true}) async {
    if (checkSettings) {
      bool cacheEnabled = await ref.read(cacheTotpPicturesSettingsEntryProvider.future);
      if (!cacheEnabled) {
        return;
      }
    }
    TotpList totps = await ref.read(totpRepositoryProvider.future);
    for (Totp totp in totps) {
      await cacheImage(totp, checkSettings: false);
    }
  }

  /// Clears the cache.
  Future<void> clearCache() async {
    Directory directory = await _getTotpImagesDirectory();
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
    state = const AsyncData({});
  }

  /// Returns the cache index.
  Future<File> _getIndexFile() async => File(join((await _getTotpImagesDirectory()).path, 'index.json'));

  /// Saves the content to the index.
  Future<void> _saveIndex({Map<String, String>? content}) async {
    content ??= await future;
    (await _getIndexFile()).writeAsStringSync(jsonEncode(content));
  }

  /// Returns the TOTP cached image file.
  static Future<File> _getTotpCachedImageFile(String uuid, {bool createDirectory = false}) async => File(join((await _getTotpImagesDirectory(create: createDirectory)).path, uuid));

  /// Returns the totp images directory, creating it if doesn't exist yet.
  static Future<Directory> _getTotpImagesDirectory({bool create = false}) async {
    Directory directory = Directory(join((await getApplicationCacheDirectory()).path, 'totps_images'));
    if (create && !directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    return directory;
  }
}

/// Allows to easily delete a file without checking if it exists.
extension _DeleteIfExists on File {
  /// Deletes the current file if it exists.
  Future<void> deleteIfExists() async {
    if (await exists()) {
      await delete();
    }
  }
}
