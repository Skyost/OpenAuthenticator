import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/storage/storage.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/model/totp/algorithm.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/utils/riverpod.dart';
import 'package:open_authenticator/utils/sqlite.dart';

part 'local.g.dart';

/// Represents a [Totp].
@DataClassName('_DriftTotp')
class Totps extends Table {
  /// Maps to [Totp.uuid].
  TextColumn get uuid => text()();

  /// Maps to [Totp.secret].
  TextColumn get secret => text().map(const _Uint8ListConverter())();

  /// Maps to [Totp.label].
  TextColumn get label => text().map(const _Uint8ListConverter()).nullable()();

  /// Maps to [Totp.issuer].
  TextColumn get issuer => text().map(const _Uint8ListConverter()).nullable()();

  /// Maps to [Totp.algorithm].
  TextColumn get algorithm => textEnum<Algorithm>().nullable()();

  /// Maps to [Totp.digits].
  IntColumn get digits => integer().nullable()();

  /// Maps to [Totp.validity].
  IntColumn get validity => integer().map(const _DurationConverter()).nullable()();

  /// Maps to [Totp.imageUrl].
  TextColumn get imageUrl => text().map(const _Uint8ListConverter()).nullable()();

  /// Maps to [Totp.encryptionSalt].
  TextColumn get encryptionSalt => text().map(const _Uint8ListConverter())();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// The local storage provider.
final localStorageProvider = Provider.autoDispose<LocalStorage>((ref) {
  LocalStorage storage = LocalStorage();
  ref.onDispose(storage.close);
  ref.cacheFor(const Duration(seconds: 1));
  return storage;
});

/// Stores TOTPs using Drift and SSS.
@DriftDatabase(tables: [Totps])
class LocalStorage extends _$LocalStorage with Storage {
  /// The database file name.
  static const _kDbFileName = 'totps';

  /// Creates a new Drift storage instance.
  LocalStorage() : super(SqliteUtils.openConnection(_kDbFileName));

  @override
  int get schemaVersion => 1;

  @override
  StorageType get type => StorageType.local;

  @override
  Future<void> addTotp(Totp totp) async {
    await into(totps).insert(totp.asDriftTotp);
  }

  @override
  Future<void> addTotps(List<Totp> totps) async {
    await batch((batch) {
      batch.insertAll(
        this.totps,
        totps.map((totp) => totp.asDriftTotp),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  @override
  Future<void> deleteTotp(String uuid) async {
    await (delete(totps)..where((totp) => totp.uuid.isValue(uuid))).go();
  }

  @override
  Future<void> deleteTotps(List<String> uuids) async {
    await (delete(totps)..where((totp) => totp.uuid.isIn(uuids))).go();
  }

  @override
  Future<void> clearTotps() async {
    await (delete(totps)).go();
  }

  @override
  Future<void> updateTotp(Totp totp) async {
    await update(totps).replace(totp.asDriftTotp);
  }

  @override
  Future<void> updateTotps(List<Totp> totps) async {
    await batch((batch) {
      batch.replaceAll(
        this.totps,
        [
          for (Totp totp in totps) totp.asDriftTotp,
        ],
      );
    });
  }

  @override
  Future<Totp?> getTotp(String uuid) async {
    _DriftTotp? totp = await (select(totps)
          ..where((totp) => totp.uuid.isValue(uuid))
          ..limit(1))
        .getSingleOrNull();
    return totp?.asTotp;
  }

  @override
  Future<List<Totp>> listTotps({int? limit}) async {
    List<_DriftTotp> list = await _listDriftTotps(limit: limit);
    return [
      for (_DriftTotp driftTotp in list) driftTotp.asTotp,
    ];
  }

  @override
  Future<List<String>> listUuids({int? limit}) async {
    List<_DriftTotp> list = await _listDriftTotps(limit: limit);
    return [
      for (_DriftTotp driftTotp in list) driftTotp.uuid,
    ];
  }

  /// List the Drift TOTPs.
  Future<List<_DriftTotp>> _listDriftTotps({int? limit}) async {
    SimpleSelectStatement<$TotpsTable, _DriftTotp> query = select(totps)..orderBy([(table) => OrderingTerm(expression: table.issuer)]);
    if (limit != null) {
      query = query..limit(limit);
    }
    return await query.get();
  }

  @override
  Future<void> replaceTotps(List<Totp> newTotps) => batch((batch) {
        batch.deleteAll(totps);
        batch.insertAll(totps, newTotps.map((totp) => totp.asDriftTotp));
      });

  @override
  Future<void> onStorageTypeChanged({bool close = true}) async {
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

/// Allows to store [Duration] into Drift databases.
class _DurationConverter extends TypeConverter<Duration, int> {
  /// Creates a new Uint8List converter instance.
  const _DurationConverter();

  @override
  Duration fromSql(int fromDb) => Duration(seconds: fromDb);

  @override
  int toSql(Duration value) => value.inSeconds;
}

/// Contains some useful methods from the generated [Secret] class.
extension _OpenAuthenticator on _DriftTotp {
  /// Converts this instance to a [Totp].
  Totp get asTotp => Totp(
        uuid: uuid,
        encryptedData: EncryptedData(
          encryptedSecret: secret,
          encryptedLabel: label,
          encryptedIssuer: issuer,
          encryptedImageUrl: imageUrl,
          encryptionSalt: Salt.fromRawValue(value: encryptionSalt),
        ),
        algorithm: algorithm,
        digits: digits,
        validity: validity,
      );
}

/// Contains some useful methods to use [Totp] with Drift.
extension _Drift on Totp {
  /// Converts this instance to a Drift generated [Secret].
  _DriftTotp get asDriftTotp => _DriftTotp(
        uuid: uuid,
        algorithm: algorithm,
        digits: digits,
        validity: validity,
        secret: encryptedData.encryptedSecret,
        label: encryptedData.encryptedLabel,
        issuer: encryptedData.encryptedIssuer,
        imageUrl: encryptedData.encryptedImageUrl,
        encryptionSalt: encryptedData.encryptionSalt.value,
      );
}
