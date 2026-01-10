import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/backend/synchronization/operation.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/totp/algorithm.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/utils/drift.dart';
import 'package:open_authenticator/utils/riverpod.dart';
import 'package:open_authenticator/utils/sqlite.dart';

part 'database.g.dart';
part 'extensions.dart';
part 'tables.dart';

/// The local storage provider.
final totpsDatabaseProvider = Provider.autoDispose<TotpDatabase>((ref) {
  TotpDatabase storage = TotpDatabase();
  ref.onDispose(storage.close);
  ref.cacheFor(const Duration(seconds: 1));
  return storage;
});

/// Stores TOTPs using Drift and SSS.
@DriftDatabase(tables: [Totps, PendingBackendPushOperation, DeletedTotps])
class TotpDatabase extends _$TotpDatabase {
  /// The database file name.
  static const _kDbFileName = 'totps';

  /// Creates a new Drift storage instance.
  TotpDatabase() : super(SqliteUtils.openConnection(_kDbFileName));

  @override
  int get schemaVersion => 2; // TODO: Migration

  /// Stores the given [totp].
  Future<void> addTotp(Totp totp) async {
    await into(totps).insert(totp.asDriftTotp);
  }

  /// Stores the given [totps].
  Future<void> addTotps(List<Totp> totps) async {
    await batch((batch) {
      batch.insertAll(
        this.totps,
        totps.map((totp) => totp.asDriftTotp),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  /// Deletes the TOTP associated to the given [uuid].
  Future<void> deleteTotp(String uuid) async {
    await (delete(totps)..where((totp) => totp.uuid.isValue(uuid))).go();
  }

  /// Deletes the TOTP associated to the given [uuids].
  Future<void> deleteTotps(List<String> uuids) async {
    await (delete(totps)..where((totp) => totp.uuid.isIn(uuids))).go();
  }

  /// Updates the [totp].
  Future<void> updateTotp(Totp totp) async {
    await update(totps).replace(totp.asDriftTotp);
  }

  /// Updates all [totps].
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

  /// Returns the TOTP associated to the given [uuid].
  Future<Totp?> getTotp(String uuid) async {
    _DriftTotp? totp =
        await (select(totps)
              ..where((totp) => totp.uuid.isValue(uuid))
              ..limit(1))
            .getSingleOrNull();
    return totp?.asTotp;
  }

  // @override
  // Stream<List<Totp>> watchTotps() => select(totps).watch().map((list) => [
  //       for (_DriftTotp driftTotp in list) driftTotp.asTotp,
  //     ]);

  /// Lists all TOTPs.
  Future<List<Totp>> listTotps() => _selectAllTotps().map((totp) => totp.asTotp).get();

  /// Lists all TOTPs UUID.
  Future<List<String>> listUuids() => _selectAllTotps().map((totp) => totp.uuid).get();

  /// Selects all TOTPs.
  SimpleSelectStatement<$TotpsTable, _DriftTotp> _selectAllTotps() => select(totps)..orderBy([(table) => OrderingTerm(expression: table.issuer)]);

  /// Replace all current TOTPs by [newTotps].
  Future<void> replaceTotps(List<Totp> newTotps) => batch((batch) {
    batch.deleteAll(totps);
    batch.insertAll(totps, newTotps.map((totp) => totp.asDriftTotp));
  });

  /// Returns all deleted TOTPs.
  Future<List<String>> getDeletedUuids() async {
    return await (select(deletedTotps)).map((deletedTotp) => deletedTotp.uuid).get();
  }

  /// Marks the given [totp] as deleted.
  Future<void> markAsDeleted(String uuid) async {
    await into(deletedTotps).insert(_DriftDeletedTotp(uuid: uuid), mode: InsertMode.insertOrIgnore);
  }

  /// Marks the given [totp] as not deleted.
  Future<void> removeDeletionMark(String uuid) async {
    await (delete(deletedTotps)..where((deletedTotp) => deletedTotp.uuid.isValue(uuid))).go();
  }

  /// Returns whether the given [uuid] is deleted.
  Future<bool> isMarkedAsDeleted(String uuid) async {
    _DriftDeletedTotp? deletedTotp =
        await (select(deletedTotps)
              ..where((deletedTotp) => deletedTotp.uuid.isValue(uuid))
              ..limit(1))
            .getSingleOrNull();
    return deletedTotp != null;
  }

  Future<int> countOutboxOperations() async => (await (select(pendingBackendPushOperation)).get()).length;

  Future<PushOperation?> getPendingBackendPushOperation(String uuid) async {
    _DriftBackendPushOperation? operation =
        await (select(pendingBackendPushOperation)
              ..where((operation) => operation.uuid.isValue(uuid))
              ..limit(1))
            .getSingleOrNull();
    return operation?.asBackendPushOperation;
  }

  Future<List<PushOperation>> listPendingBackendPushOperations() async {
    SimpleSelectStatement<$PendingBackendPushOperationTable, _DriftBackendPushOperation> operations = select(pendingBackendPushOperation)..orderBy([(table) => OrderingTerm.asc(table.createdAt)]);
    return await operations.map((operation) => operation.asBackendPushOperation).get();
  }

  Future<void> addPendingBackendPushOperation(PushOperation operation) async {
    await into(pendingBackendPushOperation).insert(operation.asDriftBackendPushOperation);
  }

  Future<void> updatePendingBackendPushOperation(PushOperation operation) async {
    await update(pendingBackendPushOperation).replace(operation.asDriftBackendPushOperation);
  }

  Future<void> deletePendingBackendPushOperation(String uuid) async {
    await (delete(pendingBackendPushOperation)..where((operation) => operation.uuid.equals(uuid))).go();
  }

  Future<void> clear() => batch((batch) {
    batch.deleteAll(totps);
    batch.deleteAll(pendingBackendPushOperation);
    batch.deleteAll(deletedTotps);
  });
}
