import 'package:equatable/equatable.dart';
import 'package:open_authenticator/model/totp/json.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:uuid/uuid.dart';

enum PushOperationKind<T> { set<Map<String, dynamic>>(), delete<List<String>>() }

class PushOperation<T> with EquatableMixin {
  final String uuid;
  final PushOperationKind<T> kind;
  final T payload;
  final DateTime createdAt;

  PushOperation({
    String? uuid,
    required this.kind,
    required this.payload,
    DateTime? createdAt,
  }) : uuid = uuid ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  static PushOperation<Map<String, dynamic>> setTotps({
    String? uuid,
    required List<Totp> totps,
    DateTime? createdAt,
  }) => PushOperation(
    uuid: uuid,
    kind: PushOperationKind.set,
    payload: {
      for (Totp totp in totps) totp.uuid: totp.toJson(includeUuid: false),
    },
    createdAt: createdAt,
  );

  static PushOperation<List<String>> deleteTotps({
    String? uuid,
    required List<String> uuids,
    DateTime? createdAt,
  }) => PushOperation(
    uuid: uuid,
    kind: PushOperationKind.delete,
    payload: uuids,
    createdAt: createdAt,
  );

  PushOperation copyWith<U>({
    PushOperationKind<U>? kind,
    U? payload,
    DateTime? createdAt,
    int? attempt,
  }) => PushOperation(
    uuid: uuid,
    kind: kind ?? this.kind,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  List<Object?> get props => [
    uuid,
    kind,
    payload,
    createdAt,
  ];

  Map<String, dynamic> toJson({
    bool httpRequest = false,
  }) => {
    'uuid': uuid,
    'kind': kind.name,
    'payload': payload,
    if (!httpRequest) ...{
      'createdAt': createdAt.millisecondsSinceEpoch,
    },
  };
}
