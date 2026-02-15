class BackendRequestError implements Exception {
  static const String kExpiredSessionError = 'expiredSession';
  static const String kInvalidPayloadError = 'invalidPayload';
  static const String kInvalidTokenError = 'invalidToken';
  static const String kInvalidSessionError = 'invalidSession';

  final String route;
  final int statusCode;
  final String? errorCode;
  final String? message;

  const BackendRequestError({
    required this.route,
    required this.statusCode,
    this.errorCode,
    this.message,
  });

  BackendRequestError.fromJson(String route, Map<String, dynamic> json)
    : this(
        route: route,
        statusCode: json['statusCode'],
        errorCode: json['errorCode'],
        message: json['message'],
      );

  @override
  String toString() => '$route gave returned error "$errorCode" (HTTP $statusCode). $message';
}
