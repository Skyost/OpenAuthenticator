// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local.dart';

// ignore_for_file: type=lint
class $TotpsTable extends Totps with TableInfo<$TotpsTable, Totp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TotpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _secretMeta = const VerificationMeta('secret');
  @override
  late final GeneratedColumnWithTypeConverter<Uint8List, String> secret =
      GeneratedColumn<String>('secret', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Uint8List>($TotpsTable.$convertersecret);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _issuerMeta = const VerificationMeta('issuer');
  @override
  late final GeneratedColumn<String> issuer = GeneratedColumn<String>(
      'issuer', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _algorithmMeta =
      const VerificationMeta('algorithm');
  @override
  late final GeneratedColumnWithTypeConverter<Algorithm?, String> algorithm =
      GeneratedColumn<String>('algorithm', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Algorithm?>($TotpsTable.$converteralgorithmn);
  static const VerificationMeta _digitsMeta = const VerificationMeta('digits');
  @override
  late final GeneratedColumn<int> digits = GeneratedColumn<int>(
      'digits', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _validityMeta =
      const VerificationMeta('validity');
  @override
  late final GeneratedColumn<int> validity = GeneratedColumn<int>(
      'validity', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [secret, uuid, label, issuer, algorithm, digits, validity, imageUrl];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'totps';
  @override
  VerificationContext validateIntegrity(Insertable<Totp> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    context.handle(_secretMeta, const VerificationResult.success());
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('issuer')) {
      context.handle(_issuerMeta,
          issuer.isAcceptableOrUnknown(data['issuer']!, _issuerMeta));
    }
    context.handle(_algorithmMeta, const VerificationResult.success());
    if (data.containsKey('digits')) {
      context.handle(_digitsMeta,
          digits.isAcceptableOrUnknown(data['digits']!, _digitsMeta));
    }
    if (data.containsKey('validity')) {
      context.handle(_validityMeta,
          validity.isAcceptableOrUnknown(data['validity']!, _validityMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Totp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Totp(
      secret: $TotpsTable.$convertersecret.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}secret'])!),
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      issuer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}issuer']),
      algorithm: $TotpsTable.$converteralgorithmn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}algorithm'])),
      digits: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}digits']),
      validity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}validity']),
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
    );
  }

  @override
  $TotpsTable createAlias(String alias) {
    return $TotpsTable(attachedDatabase, alias);
  }

  static TypeConverter<Uint8List, String> $convertersecret =
      const Uint8ListConverter();
  static JsonTypeConverter2<Algorithm, String, String> $converteralgorithm =
      const EnumNameConverter<Algorithm>(Algorithm.values);
  static JsonTypeConverter2<Algorithm?, String?, String?> $converteralgorithmn =
      JsonTypeConverter2.asNullable($converteralgorithm);
}

class Totp extends DataClass implements Insertable<Totp> {
  /// Maps to [oa_totp.Totp.secret].
  final Uint8List secret;

  /// Maps to [oa_totp.Totp.uuid].
  final String uuid;

  /// Maps to [oa_totp.Totp.label].
  final String label;

  /// Maps to [oa_totp.Totp.issuer].
  final String? issuer;

  /// Maps to [oa_totp.Totp.algorithm].
  final Algorithm? algorithm;

  /// Maps to [oa_totp.Totp.digits].
  final int? digits;

  /// Maps to [oa_totp.Totp.validity].
  final int? validity;

  /// Maps to [oa_totp.Totp.imageUrl].
  final String? imageUrl;
  const Totp(
      {required this.secret,
      required this.uuid,
      required this.label,
      this.issuer,
      this.algorithm,
      this.digits,
      this.validity,
      this.imageUrl});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['secret'] =
          Variable<String>($TotpsTable.$convertersecret.toSql(secret));
    }
    map['uuid'] = Variable<String>(uuid);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || issuer != null) {
      map['issuer'] = Variable<String>(issuer);
    }
    if (!nullToAbsent || algorithm != null) {
      map['algorithm'] =
          Variable<String>($TotpsTable.$converteralgorithmn.toSql(algorithm));
    }
    if (!nullToAbsent || digits != null) {
      map['digits'] = Variable<int>(digits);
    }
    if (!nullToAbsent || validity != null) {
      map['validity'] = Variable<int>(validity);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    return map;
  }

  TotpsCompanion toCompanion(bool nullToAbsent) {
    return TotpsCompanion(
      secret: Value(secret),
      uuid: Value(uuid),
      label: Value(label),
      issuer:
          issuer == null && nullToAbsent ? const Value.absent() : Value(issuer),
      algorithm: algorithm == null && nullToAbsent
          ? const Value.absent()
          : Value(algorithm),
      digits:
          digits == null && nullToAbsent ? const Value.absent() : Value(digits),
      validity: validity == null && nullToAbsent
          ? const Value.absent()
          : Value(validity),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
    );
  }

  factory Totp.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Totp(
      secret: serializer.fromJson<Uint8List>(json['secret']),
      uuid: serializer.fromJson<String>(json['uuid']),
      label: serializer.fromJson<String>(json['label']),
      issuer: serializer.fromJson<String?>(json['issuer']),
      algorithm: $TotpsTable.$converteralgorithmn
          .fromJson(serializer.fromJson<String?>(json['algorithm'])),
      digits: serializer.fromJson<int?>(json['digits']),
      validity: serializer.fromJson<int?>(json['validity']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'secret': serializer.toJson<Uint8List>(secret),
      'uuid': serializer.toJson<String>(uuid),
      'label': serializer.toJson<String>(label),
      'issuer': serializer.toJson<String?>(issuer),
      'algorithm': serializer
          .toJson<String?>($TotpsTable.$converteralgorithmn.toJson(algorithm)),
      'digits': serializer.toJson<int?>(digits),
      'validity': serializer.toJson<int?>(validity),
      'imageUrl': serializer.toJson<String?>(imageUrl),
    };
  }

  Totp copyWith(
          {Uint8List? secret,
          String? uuid,
          String? label,
          Value<String?> issuer = const Value.absent(),
          Value<Algorithm?> algorithm = const Value.absent(),
          Value<int?> digits = const Value.absent(),
          Value<int?> validity = const Value.absent(),
          Value<String?> imageUrl = const Value.absent()}) =>
      Totp(
        secret: secret ?? this.secret,
        uuid: uuid ?? this.uuid,
        label: label ?? this.label,
        issuer: issuer.present ? issuer.value : this.issuer,
        algorithm: algorithm.present ? algorithm.value : this.algorithm,
        digits: digits.present ? digits.value : this.digits,
        validity: validity.present ? validity.value : this.validity,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
      );
  @override
  String toString() {
    return (StringBuffer('Totp(')
          ..write('secret: $secret, ')
          ..write('uuid: $uuid, ')
          ..write('label: $label, ')
          ..write('issuer: $issuer, ')
          ..write('algorithm: $algorithm, ')
          ..write('digits: $digits, ')
          ..write('validity: $validity, ')
          ..write('imageUrl: $imageUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      secret, uuid, label, issuer, algorithm, digits, validity, imageUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Totp &&
          other.secret == this.secret &&
          other.uuid == this.uuid &&
          other.label == this.label &&
          other.issuer == this.issuer &&
          other.algorithm == this.algorithm &&
          other.digits == this.digits &&
          other.validity == this.validity &&
          other.imageUrl == this.imageUrl);
}

class TotpsCompanion extends UpdateCompanion<Totp> {
  final Value<Uint8List> secret;
  final Value<String> uuid;
  final Value<String> label;
  final Value<String?> issuer;
  final Value<Algorithm?> algorithm;
  final Value<int?> digits;
  final Value<int?> validity;
  final Value<String?> imageUrl;
  final Value<int> rowid;
  const TotpsCompanion({
    this.secret = const Value.absent(),
    this.uuid = const Value.absent(),
    this.label = const Value.absent(),
    this.issuer = const Value.absent(),
    this.algorithm = const Value.absent(),
    this.digits = const Value.absent(),
    this.validity = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TotpsCompanion.insert({
    required Uint8List secret,
    required String uuid,
    required String label,
    this.issuer = const Value.absent(),
    this.algorithm = const Value.absent(),
    this.digits = const Value.absent(),
    this.validity = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : secret = Value(secret),
        uuid = Value(uuid),
        label = Value(label);
  static Insertable<Totp> custom({
    Expression<String>? secret,
    Expression<String>? uuid,
    Expression<String>? label,
    Expression<String>? issuer,
    Expression<String>? algorithm,
    Expression<int>? digits,
    Expression<int>? validity,
    Expression<String>? imageUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (secret != null) 'secret': secret,
      if (uuid != null) 'uuid': uuid,
      if (label != null) 'label': label,
      if (issuer != null) 'issuer': issuer,
      if (algorithm != null) 'algorithm': algorithm,
      if (digits != null) 'digits': digits,
      if (validity != null) 'validity': validity,
      if (imageUrl != null) 'image_url': imageUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TotpsCompanion copyWith(
      {Value<Uint8List>? secret,
      Value<String>? uuid,
      Value<String>? label,
      Value<String?>? issuer,
      Value<Algorithm?>? algorithm,
      Value<int?>? digits,
      Value<int?>? validity,
      Value<String?>? imageUrl,
      Value<int>? rowid}) {
    return TotpsCompanion(
      secret: secret ?? this.secret,
      uuid: uuid ?? this.uuid,
      label: label ?? this.label,
      issuer: issuer ?? this.issuer,
      algorithm: algorithm ?? this.algorithm,
      digits: digits ?? this.digits,
      validity: validity ?? this.validity,
      imageUrl: imageUrl ?? this.imageUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (secret.present) {
      map['secret'] =
          Variable<String>($TotpsTable.$convertersecret.toSql(secret.value));
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (issuer.present) {
      map['issuer'] = Variable<String>(issuer.value);
    }
    if (algorithm.present) {
      map['algorithm'] = Variable<String>(
          $TotpsTable.$converteralgorithmn.toSql(algorithm.value));
    }
    if (digits.present) {
      map['digits'] = Variable<int>(digits.value);
    }
    if (validity.present) {
      map['validity'] = Variable<int>(validity.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TotpsCompanion(')
          ..write('secret: $secret, ')
          ..write('uuid: $uuid, ')
          ..write('label: $label, ')
          ..write('issuer: $issuer, ')
          ..write('algorithm: $algorithm, ')
          ..write('digits: $digits, ')
          ..write('validity: $validity, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalStorage extends GeneratedDatabase {
  _$LocalStorage(QueryExecutor e) : super(e);
  late final $TotpsTable totps = $TotpsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [totps];
}
