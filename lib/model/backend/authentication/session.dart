import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/backend/backend.dart';
import 'package:open_authenticator/model/backend/request/error.dart';
import 'package:open_authenticator/model/backend/request/request.dart';
import 'package:open_authenticator/model/backend/request/response.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:simple_secure_storage/simple_secure_storage.dart';

class Session {
  final String? accessToken;
  final String refreshToken;

  const Session({
    required this.accessToken,
    required this.refreshToken,
  });

  Future<Result<Session>> sendRefreshRequest(Backend backend) async {
    try {
      Result<RefreshTokenResponse> result = await backend.sendHttpRequest(
        RefreshTokenRequest(
          refreshToken: refreshToken,
        ),
        session: this,
      );
      return result.to(
        (response) => Session(
          accessToken: response!.accessToken,
          refreshToken: response.refreshToken,
        ),
      );
    } catch (ex, stackTrace) {
      return ResultError(
        exception: ex,
        stackTrace: stackTrace,
      );
    }
  }

  static bool hasExpired(Object? error) => error is BackendRequestError && error.errorCode == BackendRequestError.kExpiredSessionError;
}

final storedSessionProvider = AsyncNotifierProvider<StoredSessionNotifier, Session?>(StoredSessionNotifier.new);

class StoredSessionNotifier extends AsyncNotifier<Session?> {
  static const String _kRefreshToken = 'refreshToken';

  @override
  Future<Session?> build() async {
    String? refreshToken = await SimpleSecureStorage.read(_kRefreshToken);
    return refreshToken == null
        ? null
        : Session(
            accessToken: null,
            refreshToken: refreshToken,
          );
  }

  Future<Result> refresh({ Session? session }) async {
    try {
      session ??= await future;
      if (session == null) {
        throw const NoSessionException();
      }
      Backend backend = await ref.read(backendProvider.notifier);
      Result<Session> result = await session.sendRefreshRequest(backend);
      if (result is! ResultSuccess<Session>) {
        return result;
      }
      await storeAndUse(result.value);
      return const ResultSuccess();
    } catch (ex, stackTrace) {
      if (ex is BackendRequestError && (ex.errorCode == BackendRequestError.kInvalidPayloadError || ex.errorCode == BackendRequestError.kInvalidTokenError)) {
        await clear();
      }
      return ResultError(
        exception: ex,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> storeAndUse(Session session) async {
    await SimpleSecureStorage.write(_kRefreshToken, session.refreshToken);
    state = AsyncData(
      Session(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      ),
    );
  }

  Future<Result> clear() async {
    await SimpleSecureStorage.delete(_kRefreshToken);
    state = const AsyncData(null);
    return const ResultSuccess();
  }
}

class NoSessionException implements Exception {
  const NoSessionException();

  @override
  String toString() => 'The user must be logged-in to proceed';
}
