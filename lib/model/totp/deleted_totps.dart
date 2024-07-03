import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/utils/riverpod.dart';
import 'package:open_authenticator/utils/sqlite.dart';

part 'deleted_totps.g.dart';

/// The deleted TOTPs provider.
final deletedTotpsProvider = Provider.autoDispose((ref) {
  DeletedTotpsDatabase database = DeletedTotpsDatabase();
  ref.onDispose(database.close);
  ref.cacheFor(const Duration(seconds: 3));
  return database;
});

/// Allows to store all deleted TOTPs.
class DeletedTotps extends Table {
  /// Maps to [Totp.uuid].
  TextColumn get uuid => text()();
}

/// Stores TOTPs using Drift and SSS.
@DriftDatabase(tables: [DeletedTotps])
class DeletedTotpsDatabase extends _$DeletedTotpsDatabase {
  /// The database file name.
  static const _kDbFileName = 'deleted_totps';

  /// Creates a new deleted TOTPs database instance.
  DeletedTotpsDatabase() : super(SqliteUtils.openConnection(_kDbFileName));

  @override
  int get schemaVersion => 1;

  /// Marks the given [totp] as deleted.
  Future<void> markDeleted(String uuid) async {
    await into(deletedTotps).insert(DeletedTotp(uuid: uuid), mode: InsertMode.insertOrIgnore);
  }

  /// Marks the given [totp] as not deleted.
  Future<void> cancelDeletion(String uuid) async {
    await (delete(deletedTotps)..where((deletedTotp) => deletedTotp.uuid.isValue(uuid))).go();
  }

  /// Returns whether the given [totp] is deleted.
  Future<bool> isDeleted(String uuid) async {
    DeletedTotp? deletedTotp = await (select(deletedTotps)..where((deletedTotp) => deletedTotp.uuid.isValue(uuid))..limit(1)).getSingleOrNull();
    return deletedTotp != null;
  }
}
