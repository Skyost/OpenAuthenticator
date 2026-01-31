import 'package:equatable/equatable.dart';
import 'package:open_authenticator/model/totp/json.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:uuid/uuid.dart';

enum PushOperationKind { set, delete }

class PushOperation<T> with EquatableMixin {
  final String uuid;
  final PushOperationKind kind;
  final T payload;
  final DateTime createdAt;
  final int attempt;
  final PushOperationError? lastError;

  PushOperation({
    String? uuid,
    required this.kind,
    required this.payload,
    DateTime? createdAt,
    this.attempt = 0,
    this.lastError,
  }) : uuid = uuid ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  static PushOperation<Map<String, dynamic>> setTotps({
    String? uuid,
    required List<Totp> totps,
    DateTime? createdAt,
    int attempt = 0,
    PushOperationError? lastError,
  }) => PushOperation(
    uuid: uuid,
    kind: PushOperationKind.set,
    payload: {
      for (Totp totp in totps) totp.uuid: totp.toJson(includeUuid: false),
    },
    createdAt: createdAt,
    attempt: attempt,
    lastError: lastError,
  );

  static PushOperation<List<String>> deleteTotps({
    String? uuid,
    required List<String> uuids,
    DateTime? createdAt,
    int attempt = 0,
    PushOperationError? lastError,
  }) => PushOperation(
    uuid: uuid,
    kind: PushOperationKind.delete,
    payload: uuids,
    createdAt: createdAt,
    attempt: attempt,
    lastError: lastError,
  );

  // PushOperation applyResult(PushOperationResult result) => copyWith(
  //   attempt: attempt + 1,
  //   lastError: (lastError ?? (result.success ? null : PushOperationError._()))?.copyWith(
  //     error: PushOperationErrorKind.values.firstWhere(
  //       (value) => value.name == result.errorCode,
  //       orElse: () => PushOperationErrorKind.genericError,
  //     ),
  //     details: result.errorDetails,
  //   ),
  // );

  PushOperation copyWith({
    PushOperationKind? kind,
    dynamic payload,
    DateTime? createdAt,
    int? attempt,
    PushOperationError? lastError,
  }) => PushOperation(
    uuid: uuid,
    kind: kind ?? this.kind,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    attempt: attempt ?? this.attempt,
    lastError: lastError ?? this.lastError,
  );

  @override
  List<Object?> get props => [
    uuid,
    kind,
    payload,
    createdAt,
    attempt,
    lastError,
  ];

  Map<String, dynamic> toJson({
    bool httpRequest = false,
  }) => {
    'uuid': uuid,
    'kind': kind.name,
    'payload': payload,
    if (!httpRequest) ...{
      'createdAt': createdAt.millisecondsSinceEpoch,
      'attempt': attempt,
      'lastError': lastError?.toJson(),
    },
  };
}

enum PushOperationErrorKind { invalidUuid, invalidTotp, invalidUpdateTimestamp, genericError }

class PushOperationError {
  final PushOperationErrorKind? error;
  final String? details;

  PushOperationError({
    required this.error,
    required this.details,
  });

  PushOperationError._({
    this.error,
    this.details,
  });

  PushOperationError copyWith({
    PushOperationErrorKind? error,
    String? details,
  }) => PushOperationError._(
    error: error ?? this.error,
    details: details ?? this.details,
  );

  Map<String, dynamic> toJson() => {
    'error': error?.name,
    'details': details,
  };
}
