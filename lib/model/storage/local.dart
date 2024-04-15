import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/storage/storage.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/model/totp/algorithm.dart';
import 'package:open_authenticator/model/totp/totp.dart' as oa_totp;
import 'package:open_authenticator/utils/sqlite.dart';

part 'local.g.dart';

/// Represents a [oa_totp.Totp].
class Totps extends Table {
  /// Maps to [oa_totp.Totp.secret].
  TextColumn get secret => text().map(const Uint8ListConverter())();

  /// Maps to [oa_totp.Totp.uuid].
  TextColumn get uuid => text()();

  /// Maps to [oa_totp.Totp.label].
  TextColumn get label => text()();

  /// Maps to [oa_totp.Totp.issuer].
  TextColumn get issuer => text().nullable()();

  /// Maps to [oa_totp.Totp.algorithm].
  TextColumn get algorithm => textEnum<Algorithm>().nullable()();

  /// Maps to [oa_totp.Totp.digits].
  IntColumn get digits => integer().nullable()();

  /// Maps to [oa_totp.Totp.validity].
  IntColumn get validity => integer().nullable()();

  /// Maps to [oa_totp.Totp.imageUrl].
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
  Future<bool> addTotp(oa_totp.Totp totp) async {
    await into(totps).insert(totp.asDriftTotp);
    return true;
  }

  @override
  Future<bool> addTotps(List<oa_totp.Totp> totps) async {
    await batch((batch) {
      batch.insertAll(
        this.totps,
        totps.map((totp) => totp.asDriftTotp),
        mode: InsertMode.insertOrReplace,
      );
    });
    return true;
  }

  @override
  Future<bool> deleteTotp(String uuid) async {
    await (delete(totps)..where((totp) => totp.uuid.isValue(uuid))).go();
    return true;
  }

  @override
  Future<bool> deleteTotps(List<String> uuids) async {
    await (delete(totps)..where((totp) => totp.uuid.isIn(uuids))).go();
    return true;
  }

  @override
  Future<bool> clearTotps() async {
    await (delete(totps)).go();
    return true;
  }

  @override
  Future<bool> updateTotp(
    String uuid, {
    String? label,
    String? issuer,
    Algorithm? algorithm,
    int? digits,
    int? validity,
    String? imageUrl,
  }) async {
    await (update(totps)..where((totp) => totp.uuid.isValue(uuid))).write(TotpsCompanion(
      label: Value.absentIfNull(label),
      issuer: Value.absentIfNull(issuer),
      algorithm: Value.absentIfNull(algorithm),
      digits: Value.absentIfNull(digits),
      validity: Value.absentIfNull(validity),
      imageUrl: Value.absentIfNull(imageUrl),
    ));
    return true;
  }

  @override
  Future<oa_totp.Totp?> getTotp(String uuid) async {
    Totp? totp = await (select(totps)
          ..where((totp) => totp.uuid.isValue(uuid))
          ..limit(1))
        .getSingleOrNull();
    return totp?.asTotp;
  }

  @override
  Future<List<oa_totp.Totp>> listTotps() async {
    List<Totp> list = await (select(totps)).get();
    return list.map((totp) => totp.asTotp).toList();
  }

  @override
  Future<bool> canDecryptAll(CryptoStore cryptoStore) async {
    List<Totp> list = await (select(totps)).get();
    for (Totp totp in list) {
      if (!await cryptoStore.canDecrypt(totp.secret)) {
        return false;
      }
    }
    return true;
  }

  @override
  Future<Uint8List?> readSecretsSalt() => StoredCryptoStore.readSaltFromLocalStorage();

  @override
  Future<bool> saveSecretsSalt(Uint8List salt) async {
    await StoredCryptoStore.saveSaltToLocalStorage(salt);
    return true;
  }

  @override
  Future<void> onStorageTypeChanged({ bool close = false }) async {
    await clearTotps();
    await super.onStorageTypeChanged(close: close);
  }
}

/// Allows to store [Uint8List] into Drift databases.
class Uint8ListConverter extends TypeConverter<Uint8List, String> {
  /// Creates a new Uint8List converter instance.
  const Uint8ListConverter();

  @override
  Uint8List fromSql(String fromDb) => Uint8List.fromList((json.decode(fromDb) as List).cast<int>());

  @override
  String toSql(Uint8List value) => json.encode(value);
}

/// Contains some useful methods from the generated [Secret] class.
extension OA on Totp {
  /// Converts this instance to a [oa_totp.Totp].
  oa_totp.Totp get asTotp => oa_totp.Totp(
        secret: secret,
        uuid: uuid,
        label: label,
        issuer: issuer,
        algorithm: algorithm,
        digits: digits,
        validity: validity,
        imageUrl: imageUrl,
      );
}

/// Contains some useful methods to use [oa_totp.Totp] with Drift.
extension Drift on oa_totp.Totp {
  /// Converts this instance to a Drift generated [Secret].
  Totp get asDriftTotp => Totp(
        secret: secret,
        uuid: uuid,
        label: label,
        issuer: issuer,
        algorithm: algorithm,
        digits: digits,
        validity: validity,
        imageUrl: imageUrl,
      );
}
