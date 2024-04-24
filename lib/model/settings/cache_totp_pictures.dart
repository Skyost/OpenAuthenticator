import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:open_authenticator/model/settings/entry.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// The cache TOTP pictures settings entry provider.
final cacheTotpPicturesSettingsEntryProvider = AsyncNotifierProvider.autoDispose<CacheTotpPicturesSettingsEntry, bool>(CacheTotpPicturesSettingsEntry.new);

/// A settings entry that allows to control whether we have to cache TOTP pictures.
class CacheTotpPicturesSettingsEntry extends SettingsEntry<bool> {
  /// Creates a new cache TOTP pictures settings entry instance.
  CacheTotpPicturesSettingsEntry()
      : super(
          key: 'cacheTotpPictures',
          defaultValue: true,
        );

  @override
  Future<void> changeValue(bool value) async {
    await super.changeValue(value);
    if (value) {
      List<Totp> totps = await ref.read(totpRepositoryProvider.future);
      for (Totp totp in totps) {
        await totp.cacheImage();
      }
    } else {
      Directory cache = await TotpImageCache._getTotpImagesDirectory();
      if (await cache.exists()) {
        await cache.delete(recursive: true);
      }
    }
  }
}

/// Contains various methods for caching TOTP images.
extension TotpImageCache on Totp {
  /// Caches the TOTP image.
  Future<void> cacheImage({String? previousImageUrl}) async {
    try {
      if (imageUrl == null) {
        File file = await getTotpCachedImage(uuid);
        if (await file.exists()) {
          await file.delete();
        }
      } else {
        previousImageUrl ??= imageUrl;
        File file = await getTotpCachedImage(uuid, createDirectory: true);
        if (previousImageUrl == imageUrl && file.existsSync()) {
          return;
        }
        http.Response response = await http.get(Uri.parse(imageUrl!));
        await file.writeAsBytes(response.bodyBytes);
      }
    }
    catch (ex, stacktrace) {
      if (kDebugMode) {
        print(ex);
        print(stacktrace);
      }
    }
  }

  /// Deletes the cached image, if possible.
  Future<void> deleteCachedImage() async {
    File cachedImage = await getTotpCachedImage(uuid);
    if (await cachedImage.exists()) {
      await cachedImage.delete();
    }
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
}
