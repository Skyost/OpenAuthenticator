import 'package:equatable/equatable.dart';

class PushOperationResult with EquatableMixin {
  final String operationUuid;
  final String totpUuid;
  final String? errorCode;
  final String? errorDetails;
  final DateTime createdAt;

  PushOperationResult({
    required this.operationUuid,
    required this.totpUuid,
    this.errorCode,
    this.errorDetails,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  PushOperationResult.fromJson(Map<String, dynamic> json)
    : this(
        operationUuid: json['operationUuid'],
        totpUuid: json['totpUuid'],
        errorCode: json['errorCode'],
        errorDetails: json['errorDetails'],
      );

  PushOperationErrorKind? get errorKind => success
      ? null
      : PushOperationErrorKind.values.firstWhere(
          (value) => value.name == errorCode,
          orElse: () => PushOperationErrorKind.genericError,
        );

  bool get success => errorCode == null;

  PushOperationResult copyWith({
    String? operationUuid,
    String? totpUuid,
    String? errorCode,
    String? errorDetails,
    DateTime? createdAt,
  }) => PushOperationResult(
    operationUuid: operationUuid ?? this.operationUuid,
    totpUuid: totpUuid ?? this.totpUuid,
    errorCode: errorCode ?? this.errorCode,
    errorDetails: errorDetails ?? this.errorDetails,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  List<Object?> get props => [
    operationUuid,
    totpUuid,
    errorCode,
    errorDetails,
    createdAt,
  ];
}

enum PushOperationErrorKind {
  invalidUuid(isPermanent: true),
  invalidTotp(isPermanent: true),
  invalidUpdateTimestamp(isPermanent: true),
  maxCountExceeded,
  genericError
  ;

  final bool isPermanent;

  const PushOperationErrorKind({
    this.isPermanent = false,
  });
}
