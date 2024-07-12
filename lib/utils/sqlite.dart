import 'dart:io' hide Platform;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

/// Contains some useful functions to use alongside SQLite.
class SqliteUtils {
  /// Opens a connection to a local database.
  static LazyDatabase openConnection(String dbFileName, { bool addDebugModeSuffix = true }) => LazyDatabase(
        () async {
          if (currentPlatform == Platform.android) {
            await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
          }

          if (addDebugModeSuffix && kDebugMode) {
            dbFileName += '_debug';
          }

          String cacheBase = (await getTemporaryDirectory()).path;
          sqlite3.tempDirectory = cacheBase;

          return NativeDatabase.createInBackground(await getDatabaseFilePath(dbFileName));
        },
      );

  /// Returns the file to use.
  static Future<File> getDatabaseFilePath(String dbFileName) async {
    Directory directory = await getApplicationSupportDirectory();
    return File(join(directory.path, '$dbFileName.sqlite'));
  }
}
