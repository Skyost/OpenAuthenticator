import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';
import 'package:open_authenticator/model/totp/json.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// The backup store provider.
final backupStoreProvider = AsyncNotifierProvider<BackupStore, List<Backup>>(BackupStore.new);

/// Contains all backups.
class BackupStore extends AsyncNotifier<List<Backup>> {
  @override
  FutureOr<List<Backup>> build() => _listBackups();

  /// Do a backup with the given password.
  Future<Result<Backup>> doBackup(String password) async {
    Backup backup = Backup._(ref: ref, dateTime: DateTime.now());
    Result result = await backup.save(password);
    if (result is! ResultSuccess) {
      return result as Result<Backup>;
    }
    state = AsyncData([...(await future), backup]..sort());
    return ResultSuccess(value: backup);
  }

  /// Lists available backups.
  Future<List<Backup>> _listBackups() async {
    List<Backup> result = [];
    Directory directory = await _getBackupsDirectory();
    if (!directory.existsSync()) {
      return result;
    }
    RegExp backupRegex = RegExp(r'\d{10}\.bak');
    for (FileSystemEntity entity in directory.listSync(followLinks: false)) {
      String name = entity.uri.pathSegments.last;
      if (backupRegex.hasMatch(name)) {
        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(name.substring(0, name.length - '.bak'.length)));
        result.add(Backup._(ref: ref, dateTime: dateTime));
      }
    }
    return result;
  }

  /// Returns the backup directory.
  static Future<Directory> _getBackupsDirectory({bool create = false}) async {
    Directory directory = Directory(join((await getApplicationDocumentsDirectory()).path, '${App.appName} Backups'));
    if (create && !directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    return directory;
  }
}

/// Represents a backup of a list of TOTPs.
class Backup implements Comparable<Backup> {
  /// The TOTPs JSON key.
  static const String kTotpsKey = 'totps';

  /// The salt JSON key.
  static const String kSaltKey = 'salt';

  /// The Riverpod ref.
  final AsyncNotifierProviderRef _ref;

  /// The backup time.
  final DateTime dateTime;

  /// Creates a new backup instance.
  Backup._({
    required AsyncNotifierProviderRef ref,
    required this.dateTime,
  }) : _ref = ref;

  /// Restore this backup.
  Future<Result> restore(String password) async {
    try {
      File file = await _getBackupPath();
      if (!file.existsSync()) {
        throw _BackupFileDoesNotExistException(path: file.path);
      }
      Map<String, dynamic> jsonData = jsonDecode(file.readAsStringSync());
      if (!jsonData.containsKey(kTotpsKey) || !jsonData.containsKey(kSaltKey)) {
        throw _InvalidBackupContentException();
      }
      CryptoStore? currentCryptoStore = await _ref.read(cryptoStoreProvider.future);
      CryptoStore? cryptoStore = await CryptoStore.fromPassword(password, salt: base64.decode(jsonData[kSaltKey]));
      if (currentCryptoStore == null || cryptoStore == null) {
        throw _EncryptionError(operationName: 'decryption');
      }
      List jsonTotps = jsonData[kTotpsKey];
      List<Totp> totps = [];
      for (dynamic jsonTotp in jsonTotps) {
        Totp? totp = await JsonTotp.fromJson(jsonTotp)?.changeEncryptionKey(cryptoStore, currentCryptoStore);
        if (totp != null) {
          totps.add(totp);
        }
      }
      if (totps.isEmpty) {
        throw _InvalidPasswordException();
      }
      return await _ref.read(totpRepositoryProvider.notifier).replaceBy(totps);
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }

  /// Saves this backup.
  Future<Result> save(String password) async {
    try {
      CryptoStore? newStore = await CryptoStore.fromPassword(password);
      CryptoStore? currentCryptoStore = await _ref.read(cryptoStoreProvider.future);
      if (newStore == null || currentCryptoStore == null) {
        throw _EncryptionError(operationName: 'encryption');
      }
      List<Totp> totps = await _ref.read(totpRepositoryProvider.future);
      List<DecryptedTotp> toBackup = [];
      for (Totp totp in totps) {
        DecryptedTotp? decryptedTotp = await totp.changeEncryptionKey(currentCryptoStore, newStore);
        if (decryptedTotp != null) {
          toBackup.add(decryptedTotp);
        }
      }
      if (toBackup.isEmpty) {
        throw _InvalidPasswordException();
      }
      File file = await _getBackupPath(createDirectory: true);
      file.writeAsString(jsonEncode({
        kSaltKey: base64.encode(newStore.salt),
        kTotpsKey: toBackup.map((totp) => totp.toJson()).toList(),
      }));
      return const ResultSuccess();
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }

  /// Deletes this backup.
  Future<Result> delete() async {
    try {
      File file = await _getBackupPath();
      if (file.existsSync()) {
        file.deleteSync();
      }
      _ref.invalidateSelf();
      return const ResultSuccess();
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }

  /// Returns the backup path (TOTPs and salt).
  Future<File> _getBackupPath({bool createDirectory = false}) async {
    Directory directory = await BackupStore._getBackupsDirectory(create: createDirectory);
    return File(join(directory.path, '${dateTime.millisecondsSinceEpoch}.bak'));
  }

  @override
  int compareTo(Backup other) => dateTime.compareTo(other.dateTime);
}

/// Thrown when the file does not exist.
class _BackupFileDoesNotExistException implements Exception {
  /// The file path.
  final String path;

  /// Creates a new backup file doesn't exist exception instance.
  _BackupFileDoesNotExistException({required this.path,});

  @override
  String toString() => 'Backup file does not exist : "$path"';
}

/// Thrown when an invalid password has been provided.
class _InvalidPasswordException implements Exception {
  @override
  String toString() => 'Invalid password exception';
}

/// Thrown when the backup content is invalid.
class _InvalidBackupContentException implements Exception {
  @override
  String toString() => 'Invalid backup content';
}

/// Thrown when there is an encryption error.
class _EncryptionError implements Exception {
  /// The operation name.
  final String operationName;

  /// Creates a new encryption error instance.
  _EncryptionError({required this.operationName,});

  @override
  String toString() => 'Error while doing $operationName.';
}
