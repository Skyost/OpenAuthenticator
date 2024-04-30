import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/storage/storage.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/model/totp/algorithm.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/utils/sqlite.dart';

part 'local.g.dart';

/// Represents a [Totp].
@DataClassName('_DriftTotp')
class Totps extends Table {
  /// Maps to [Totp.secret].
  TextColumn get secret => text().map(const _Uint8ListConverter())();

  /// Maps to [Totp.encryptionSalt].
  TextColumn get encryptionSalt => text().map(const _Uint8ListConverter())();

  /// Maps to [Totp.uuid].
  TextColumn get uuid => text()();

  /// Maps to [Totp.label].
  TextColumn get label => text().nullable()();

  /// Maps to [Totp.issuer].
  TextColumn get issuer => text().nullable()();

  /// Maps to [Totp.algorithm].
  TextColumn get algorithm => textEnum<Algorithm>().nullable()();

  /// Maps to [Totp.digits].
  IntColumn get digits => integer().nullable()();

  /// Maps to [Totp.validity].
  IntColumn get validity => integer().nullable()();

  /// Maps to [Totp.imageUrl].
  TextColumn get imageUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// Stores TOTPs using Drift and SSS.
@DriftDatabase(tables: [Totps])
class LocalStorage extends _$LocalStorage with Storage {
  /// The database file name.
  static const _kDbFileName = 'totps';

  /// Creates a new Drift storage instance.
  LocalStorage(AutoDisposeAsyncNotifierProviderRef ref) : super(SqliteUtils.openConnection(_kDbFileName));

  @override
  int get schemaVersion => 1;

  @override
  StorageType get type => StorageType.local;

  @override
  Future<void> addTotp(Totp totp) => into(totps).insert(totp.asDriftTotp);

  @override
  Future<void> addTotps(List<Totp> totps) => batch((batch) {
        batch.insertAll(
          this.totps,
          totps.map((totp) => totp.asDriftTotp),
          mode: InsertMode.insertOrReplace,
        );
      });

  @override
  Future<void> deleteTotp(String uuid) => (delete(totps)..where((totp) => totp.uuid.isValue(uuid))).go();

  @override
  Future<void> deleteTotps(List<String> uuids) => (delete(totps)..where((totp) => totp.uuid.isIn(uuids))).go();

  @override
  Future<void> clearTotps() => (delete(totps)).go();

  @override
  Future<bool> updateTotp(String uuid, Totp totp) => update(totps).replace(totp.asDriftTotp);

  @override
  Future<Totp?> getTotp(String uuid) async {
    _DriftTotp? totp = await (select(totps)
          ..where((totp) => totp.uuid.isValue(uuid))
          ..limit(1))
        .getSingleOrNull();
    return totp?.asTotp;
  }

  @override
  Future<List<Totp>> listTotps() async {
    List<_DriftTotp> list = await (select(totps)..orderBy([(table) => OrderingTerm(expression: table.issuer)])).get();
    return list.map((totp) => totp.asTotp).toList();
  }

  @override
  Future<List<String>> listUuids() async {
    List<_DriftTotp> list = await (select(totps)..orderBy([(table) => OrderingTerm(expression: table.issuer)])).get();
    return list.map((totp) => totp.uuid).toList();
  }

  @override
  Future<bool> canDecryptAll(CryptoStore cryptoStore) async {
    List<_DriftTotp> list = await (select(totps)).get();
    for (_DriftTotp totp in list) {
      if (!await cryptoStore.canDecrypt(totp.secret)) {
        return false;
      }
    }
    return true;
  }

  @override
  Future<Salt?> readSecretsSalt() async => await Salt.readFromLocalStorage();

  @override
  Future<void> saveSecretsSalt(Salt salt) => salt.saveToLocalStorage();

  @override
  Future<void> onStorageTypeChanged({bool close = false}) async {
    await clearTotps();
    await super.onStorageTypeChanged(close: close);
  }
}

/// Allows to store [Uint8List] into Drift databases.
class _Uint8ListConverter extends TypeConverter<Uint8List, String> {
  /// Creates a new Uint8List converter instance.
  const _Uint8ListConverter();

  @override
  Uint8List fromSql(String fromDb) => base64.decode(fromDb);

  @override
  String toSql(Uint8List value) => base64.encode(value);
}

/// Contains some useful methods from the generated [Secret] class.
extension _OpenAuthenticator on _DriftTotp {
  /// Converts this instance to a [Totp].
  Totp get asTotp => Totp(
        secret: secret,
        encryptionSalt: Salt.fromRawValue(value: encryptionSalt),
        uuid: uuid,
        label: label,
        issuer: issuer,
        algorithm: algorithm,
        digits: digits,
        validity: validity,
        imageUrl: imageUrl,
      );
}

/// Contains some useful methods to use [Totp] with Drift.
extension _Drift on Totp {
  /// Converts this instance to a Drift generated [Secret].
  _DriftTotp get asDriftTotp => _DriftTotp(
        secret: secret,
        encryptionSalt: encryptionSalt.value,
        uuid: uuid,
        label: label,
        issuer: issuer,
        algorithm: algorithm,
        digits: digits,
        validity: validity,
        imageUrl: imageUrl,
      );
}