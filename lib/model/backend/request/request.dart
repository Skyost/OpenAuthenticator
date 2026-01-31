import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:open_authenticator/model/backend/authentication/providers/provider.dart';
import 'package:open_authenticator/model/backend/request/error.dart';
import 'package:open_authenticator/model/backend/request/response.dart';
import 'package:open_authenticator/model/backend/synchronization/operation.dart';

sealed class BackendRequest<T extends BackendResponse> {
  final String route;
  final bool needsAuthorization;

  const BackendRequest({
    required this.route,
    this.needsAuthorization = false,
  });

  Future<http.Response> execute(http.Client client, Uri url, {Map<String, String>? headers});

  T toResponse(http.Response response) {
    Map<String, dynamic> json = jsonDecode(response.body);
    if (!json['success']) {
      throw BackendRequestError(
        route: route,
        statusCode: response.statusCode,
        errorCode: json['data']['errorCode'],
        message: json['data']['message'],
      );
    }
    return _toResponseIfNoError(json['data']);
  }

  T _toResponseIfNoError(dynamic data);
}

mixin BackendWithBodyRequest<T extends BackendResponse> on BackendRequest<T> {
  Object? get body => null;

  Encoding? get encoding => null;
}

abstract class BackendGetRequest<T extends BackendResponse> extends BackendRequest<T> {
  const BackendGetRequest({
    required super.route,
    super.needsAuthorization,
  });

  @override
  Future<http.Response> execute(http.Client client, Uri url, {Map<String, String>? headers}) => client.get(
    url,
    headers: headers,
  );
}

abstract class BackendPostRequest<T extends BackendResponse> extends BackendRequest<T> with BackendWithBodyRequest<T> {
  const BackendPostRequest({
    required super.route,
    super.needsAuthorization,
  });

  @override
  Future<http.Response> execute(http.Client client, Uri url, {Map<String, String>? headers}) => client.post(
    url,
    headers: {
      if (headers != null) ...headers,
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
    encoding: encoding,
  );
}

abstract class BackendDeleteRequest<T extends BackendResponse> extends BackendRequest<T> with BackendWithBodyRequest<T> {
  const BackendDeleteRequest({
    required super.route,
    super.needsAuthorization,
  });

  @override
  Future<http.Response> execute(http.Client client, Uri url, {Map<String, String>? headers}) => client.delete(
    url,
    headers: {
      if (headers != null) ...headers,
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
    encoding: encoding,
  );
}

class GetUserInfoRequest extends BackendGetRequest<GetUserInfoResponse> {
  const GetUserInfoRequest()
    : super(
        route: '/user',
        needsAuthorization: true,
      );

  @override
  GetUserInfoResponse _toResponseIfNoError(dynamic data) => GetUserInfoResponse.fromJson(data);
}

class DeleteUserRequest extends BackendDeleteRequest<DeleteUserResponse> {
  const DeleteUserRequest()
    : super(
        route: '/user',
        needsAuthorization: true,
      );

  @override
  DeleteUserResponse _toResponseIfNoError(dynamic data) => DeleteUserResponse.fromJson(data);
}

class GetUserTotpsRequest extends BackendGetRequest<GetUserTotpsResponse> {
  const GetUserTotpsRequest()
    : super(
        route: '/totps',
        needsAuthorization: true,
      );

  @override
  GetUserTotpsResponse _toResponseIfNoError(dynamic data) => GetUserTotpsResponse.fromJson(data);
}

class RefreshTokenRequest extends BackendPostRequest<RefreshTokenResponse> {
  final String refreshToken;

  RefreshTokenRequest({
    required this.refreshToken,
  }) : super(
         route: '/auth/refresh',
         needsAuthorization: false,
       );

  @override
  Object? get body => {'refreshToken': refreshToken};

  @override
  RefreshTokenResponse _toResponseIfNoError(dynamic data) => RefreshTokenResponse.fromJson(data);
}

class UserLogoutRequest extends BackendPostRequest<UserLogoutResponse> {
  final String refreshToken;

  UserLogoutRequest({
    required this.refreshToken,
  }) : super(
         route: '/auth/logout',
         needsAuthorization: false,
       );

  @override
  Object? get body => {'refreshToken': refreshToken};

  @override
  UserLogoutResponse _toResponseIfNoError(dynamic data) => UserLogoutResponse.fromJson(data);
}

class EmailConfirmRequest extends BackendPostRequest<EmailConfirmResponse> {
  final String email;
  final String code;

  EmailConfirmRequest({
    required this.email,
    required this.code,
  }) : super(
         route: '/auth/provider/email/callback',
         needsAuthorization: false,
       );

  @override
  Object? get body => {
    'email': email,
    'code': code,
  };

  @override
  EmailConfirmResponse _toResponseIfNoError(dynamic data) => EmailConfirmResponse.fromJson(data);
}

class EmailCancelRequest extends BackendPostRequest<EmailCancelResponse> {
  final String email;
  final String cancelCode;

  EmailCancelRequest({
    required this.email,
    required this.cancelCode,
  }) : super(
         route: '/auth/provider/email/cancel',
         needsAuthorization: false,
       );

  @override
  Object? get body => {
    'email': email,
    'cancelCode': cancelCode,
  };

  @override
  EmailCancelResponse _toResponseIfNoError(dynamic data) => EmailCancelResponse.fromJson(data);
}

class ProviderLoginRequest extends BackendPostRequest<ProviderLoginResponse> {
  final String authorizationCode;
  final String? codeVerifier;

  ProviderLoginRequest({
    required AuthenticationProvider provider,
    required this.authorizationCode,
    this.codeVerifier,
  }) : super(
         route: '/auth/provider/${provider.id}/login',
       );

  @override
  Object? get body => {
    'authorizationCode': authorizationCode,
    if (codeVerifier != null) 'codeVerifier': codeVerifier,
  };

  @override
  ProviderLoginResponse _toResponseIfNoError(dynamic data) => ProviderLoginResponse.fromJson(data);
}

class ProviderLinkRequest extends BackendPostRequest<ProviderLinkResponse> {
  final String authorizationCode;
  final String? codeVerifier;

  ProviderLinkRequest({
    required AuthenticationProvider provider,
    required this.authorizationCode,
    this.codeVerifier,
  }) : super(
         route: '/auth/provider/${provider.id}/link',
         needsAuthorization: true,
       );

  @override
  Object? get body => {
    'authorizationCode': authorizationCode,
    if (codeVerifier != null) 'codeVerifier': codeVerifier,
  };

  @override
  ProviderLinkResponse _toResponseIfNoError(dynamic data) => ProviderLinkResponse.fromJson(data);
}

class ProviderUnlinkRequest extends BackendPostRequest<ProviderUnlinkResponse> {
  ProviderUnlinkRequest({
    required AuthenticationProvider provider,
  }) : super(
         route: '/auth/provider/${provider.id}/unlink',
         needsAuthorization: true,
       );

  @override
  ProviderUnlinkResponse _toResponseIfNoError(dynamic data) => ProviderUnlinkResponse.fromJson(data);
}

class SynchronizationPushRequest extends BackendPostRequest<SynchronizationPushResponse> {
  final List<PushOperation> operations;

  const SynchronizationPushRequest({
    this.operations = const [],
  }) : super(
         route: '/totps/sync/push',
         needsAuthorization: true,
       );

  @override
  Object? get body => [
    for (PushOperation operation in operations) operation.toJson(httpRequest: true),
  ];

  @override
  SynchronizationPushResponse _toResponseIfNoError(dynamic data) => SynchronizationPushResponse.fromJson(data);
}

class SynchronizationPullRequest extends BackendPostRequest<SynchronizationPullResponse> {
  final Map<String, DateTime> timestamps;

  const SynchronizationPullRequest({
    this.timestamps = const {},
  }) : super(
         route: '/totps/sync/pull',
         needsAuthorization: true,
       );

  @override
  Object? get body => {
    for (String uuid in timestamps.keys) uuid: timestamps[uuid]!.millisecondsSinceEpoch,
  };

  @override
  SynchronizationPullResponse _toResponseIfNoError(dynamic data) => SynchronizationPullResponse.fromJson(data);
}
