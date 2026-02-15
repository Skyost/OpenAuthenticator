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

  /// Maps to [Totp.updatedAt].
  IntColumn get updatedAt => integer()();

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
class PendingBackendPushOperations extends Table {
  TextColumn get uuid => text()();

  TextColumn get kind => textEnum<PushOperationKind>()();

  TextColumn get jsonPayload => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {uuid};
}

@DataClassName('_DriftBackendPushOperationError')
class BackendPushOperationErrors extends Table {
  TextColumn get operationUuid => text()();

  TextColumn get totpUuid => text()();

  TextColumn get errorKind => textEnum<PushOperationErrorKind>()();

  TextColumn get errorDetails => text().nullable()();

  IntColumn get createdAt => integer()();
}
