// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_totps.dart';

// ignore_for_file: type=lint
class $DeletedTotpsTable extends DeletedTotps
    with TableInfo<$DeletedTotpsTable, DeletedTotp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeletedTotpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [uuid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deleted_totps';
  @override
  VerificationContext validateIntegrity(Insertable<DeletedTotp> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  DeletedTotp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeletedTotp(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
    );
  }

  @override
  $DeletedTotpsTable createAlias(String alias) {
    return $DeletedTotpsTable(attachedDatabase, alias);
  }
}

class DeletedTotp extends DataClass implements Insertable<DeletedTotp> {
  /// Maps to [Totp.uuid].
  final String uuid;
  const DeletedTotp({required this.uuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    return map;
  }

  DeletedTotpsCompanion toCompanion(bool nullToAbsent) {
    return DeletedTotpsCompanion(
      uuid: Value(uuid),
    );
  }

  factory DeletedTotp.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeletedTotp(
      uuid: serializer.fromJson<String>(json['uuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
    };
  }

  DeletedTotp copyWith({String? uuid}) => DeletedTotp(
        uuid: uuid ?? this.uuid,
      );
  @override
  String toString() {
    return (StringBuffer('DeletedTotp(')
          ..write('uuid: $uuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => uuid.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeletedTotp && other.uuid == this.uuid);
}

class DeletedTotpsCompanion extends UpdateCompanion<DeletedTotp> {
  final Value<String> uuid;
  final Value<int> rowid;
  const DeletedTotpsCompanion({
    this.uuid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeletedTotpsCompanion.insert({
    required String uuid,
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid);
  static Insertable<DeletedTotp> custom({
    Expression<String>? uuid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeletedTotpsCompanion copyWith({Value<String>? uuid, Value<int>? rowid}) {
    return DeletedTotpsCompanion(
      uuid: uuid ?? this.uuid,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeletedTotpsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$DeletedTotpsDatabase extends GeneratedDatabase {
  _$DeletedTotpsDatabase(QueryExecutor e) : super(e);
  late final $DeletedTotpsTable deletedTotps = $DeletedTotpsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [deletedTotps];
}
