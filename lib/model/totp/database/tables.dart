part of 'database.dart';

/// Represents a [Totp].
@DataClassName('_DriftTotp')
class Totps extends Table {
  /// Maps to [Totp.uuid].
  TextColumn get uuid => text()();

  /// Maps to [Totp.encryptedData.encryptedSecret].
  TextColumn get secret => text().map(const Uint8ListConverter())();

  /// Maps to [Totp.encryptedData.encryptedLabel].
  TextColumn get label => text().map(const Uint8ListConverter()).nullable()();

  /// Maps to [Totp.encryptedData.encryptedIssuer].
  TextColumn get issuer => text().map(const Uint8ListConverter()).nullable()();

  /// Maps to [Totp.algorithm].
  TextColumn get algorithm => textEnum<Algorithm>().nullable()();

  /// Maps to [Totp.digits].
  IntColumn get digits => integer().nullable()();

  /// Maps to [Totp.validity].
  IntColumn get validity => integer().map(const DurationConverter()).nullable()();

  /// Maps to [Totp.encryptedData.encryptedImageUrl].
  TextColumn get imageUrl => text().map(const Uint8ListConverter()).nullable()();

  /// Maps to [Totp.encryptedData.encryptionSalt].
  TextColumn get encryptionSalt => text().map(const Uint8ListConverter())();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {uuid};
}

@DataClassName('_DriftDeletedTotp')
class DeletedTotps extends Table {
  /// Maps to [Totp.uuid].
  TextColumn get uuid => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}

@DataClassName('_DriftBackendPushOperation')
class PendingBackendPushOperation extends Table {
  TextColumn get uuid => text()();

  TextColumn get kind => textEnum<OperationKind>()();

  TextColumn get jsonPayload => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  IntColumn get attempt => integer().withDefault(const Constant(0))();

  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {uuid};
}
