import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';
import 'package:open_authenticator/model/totp/json.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// The backup store provider.
final backupStoreProvider = AsyncNotifierProvider<BackupStore, List<Backup>>(BackupStore.new);

/// Contains all backups.
class BackupStore extends AsyncNotifier<List<Backup>> {
  @override
  FutureOr<List<Backup>> build() => _listBackups();

  /// Do a backup with the given password.
  Future<Backup?> doBackup(String password) async {
    Backup backup = Backup._(ref: ref, dateTime: DateTime.now());
    if(!await backup.save(password)) {
      return null;
    }
    state = AsyncData([...(await future), backup]..sort());
    return backup;
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
    Directory directory = Directory(join((await getApplicationDocumentsDirectory()).path, 'backups'));
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
  Future<bool> restore(String password) async {
    File file = await _getBackupPath();
    if (!file.existsSync()) {
      return false;
    }
    Map<String, dynamic> jsonData = jsonDecode(file.readAsStringSync());
    if (!jsonData.containsKey(kTotpsKey) || !jsonData.containsKey(kSaltKey)) {
      return false;
    }
    CryptoStore? currentCryptoStore = await _ref.read(cryptoStoreProvider.future);
    CryptoStore? cryptoStore = await CryptoStore.fromPassword(password, salt: jsonData[kSaltKey]);
    if (currentCryptoStore == null || cryptoStore == null) {
      return false;
    }
    List jsonTotps = jsonData[kTotpsKey];
    List<Totp> totps = [];
    for (dynamic jsonTotp in jsonTotps) {
      Totp? totp = await JsonTotp.fromJson(jsonTotp).changeEncryptionKey(cryptoStore, currentCryptoStore);
      if (totp != null) {
        totps.add(totp);
      }
    }
    if (totps.isEmpty) {
      return false;
    }
    return await _ref.read(totpRepositoryProvider.notifier).replaceBy(totps);
  }

  /// Saves this backup.
  Future<bool> save(String password) async {
    CryptoStore? newStore = await CryptoStore.fromPassword(password);
    CryptoStore? currentCryptoStore = await _ref.read(cryptoStoreProvider.future);
    if (newStore == null || currentCryptoStore == null) {
      return false;
    }
    List<Totp> totps = await _ref.read(totpRepositoryProvider.future);
    List<DecryptedTotp> toBackup = [];
    for (Totp totp in totps) {
      DecryptedTotp? decryptedTotp = await totp.changeEncryptionKey(currentCryptoStore, newStore);
      if (decryptedTotp != null) {
        toBackup.add(decryptedTotp);
      }
    }
    File file = await _getBackupPath(createDirectory: true);
    file.writeAsString(jsonEncode({
      kSaltKey: base64.encode(newStore.salt),
      kTotpsKey: totps.map((totp) => totp.toJson()).toList(),
    }));
    return true;
  }

  /// Deletes this backup.
  Future<bool> delete() async {
    File file = await _getBackupPath();
    if (file.existsSync()) {
      file.deleteSync();
    }
    _ref.invalidateSelf();
    return true;
  }

  /// Returns the backup path (TOTPs and salt).
  Future<File> _getBackupPath({bool createDirectory = false}) async {
    Directory directory = await BackupStore._getBackupsDirectory(create: createDirectory);
    return File(join(directory.path, '${dateTime.millisecondsSinceEpoch}.bak'));
  }

  @override
  int compareTo(Backup other) => dateTime.compareTo(other.dateTime);
}
