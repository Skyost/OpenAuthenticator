import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/model/backend/authentication/session.dart';
import 'package:open_authenticator/model/backend/request/request.dart';
import 'package:open_authenticator/model/backend/request/response.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:retry/retry.dart';
import 'package:simple_secure_storage/simple_secure_storage.dart';

final backendProvider = AsyncNotifierProvider<Backend, Map<String, String>>(Backend.new);

class Backend extends AsyncNotifier<Map<String, String>> {
  final http.Client _client = http.Client();

  @override
  FutureOr<Map<String, String>> build() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String? appClientId = await SimpleSecureStorage.read('appClientId');
    return {
      'App-Version': packageInfo.version,
      if (appClientId != null) 'App-Client-Id': appClientId,
    };
  }

  Future<Map<String, String>> _writeAppClientIdIfNeeded() async {
    Map<String, String> headers = Map.of(await future);
    if (!headers.containsKey('App-Client-Id')) {
      String appClientId = currentPlatform.generateAppClientId();
      headers['App-Client-Id'] = appClientId;
      await SimpleSecureStorage.write('appClientId', appClientId);
      state = AsyncData(headers);
    }
    return headers;
  }

  Future<Result<T>> sendHttpRequest<T extends BackendResponse>(
    BackendRequest<T> request, {
    Session? session,
    bool autoRefreshAccessToken = true,
    int? retries,
  }) async {
    try {
      return ResultSuccess(
        value: await _sendHttpRequest(
          request,
          session: session,
          retries: retries,
        ),
      );
    } catch (ex, stacktrace) {
      if (autoRefreshAccessToken && (Session.hasExpired(ex) || ex is _NoAccessTokenException)) {
        Result result = await ref.read(storedSessionProvider.notifier).refresh();
        if (result is! ResultSuccess) {
          return result.to((value) => null);
        }
        return await sendHttpRequest(
          request,
          autoRefreshAccessToken: false,
        );
      }
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }

  Future<T> _sendHttpRequest<T extends BackendResponse>(
    BackendRequest<T> request, {
    Session? session,
    int? retries,
  }) async {
    Map<String, String> headers = await _writeAppClientIdIfNeeded();
    if (request.needsAuthorization) {
      session ??= await ref.read(storedSessionProvider.future);
      if (session == null) {
        throw const NoSessionException();
      }
      if (session.accessToken == null) {
        throw const _NoAccessTokenException();
      }
      headers[HttpHeaders.authorizationHeader] = 'Bearer ${session.accessToken}';
    }

    http.Response response = await retry(
      () => request.execute(
        _client,
        Uri.parse(App.backendUrl + request.route),
        headers: headers,
      ),
      maxAttempts: retries ?? (request is BackendGetRequest ? 1 : 3),
      retryIf: (ex) => ex is SocketException || ex is TimeoutException,
    );
    return request.toResponse(response);
  }
}

class _NoAccessTokenException implements Exception {
  const _NoAccessTokenException();

  @override
  String toString() => 'The session contains no access token.';
}
