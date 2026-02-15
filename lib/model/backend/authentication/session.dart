import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/backend/backend.dart';
import 'package:open_authenticator/model/backend/request/error.dart';
import 'package:open_authenticator/model/backend/request/request.dart';
import 'package:open_authenticator/model/backend/request/response.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:simple_secure_storage/simple_secure_storage.dart';

class Session with EquatableMixin {
  final String? accessToken;
  final String refreshToken;

  const Session({
    required this.accessToken,
    required this.refreshToken,
  });

  Session copyWith({
    String? accessToken,
    String? refreshToken,
    bool? isValid,
  }) => Session(
    accessToken: accessToken ?? this.accessToken,
    refreshToken: refreshToken ?? this.refreshToken,
  );

  @override
  List<Object?> get props => [
    accessToken,
    refreshToken,
  ];

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

final sessionRefreshRequestsQueueProvider = NotifierProvider<SessionRefreshRequestsQueue, SessionRefreshState>(SessionRefreshRequestsQueue.new);

class SessionRefreshRequestsQueue extends Notifier<SessionRefreshState> {
  @override
  SessionRefreshState build() {
    ref.watch(storedSessionProvider); // TODO: not refreshed on login
    return .idle;
  }

  Future<Result> refresh({Session? session}) async {
    if (state == .inProgress || state == .invalidSession) {
      return const ResultCancelled();
    }
    state = .inProgress;
    try {
      Backend backend = await ref.read(backendProvider.notifier);
      Result<Session> result = await _sendRefreshRequest(backend, session: session);
      if (result is! ResultSuccess<Session>) {
        if (result is ResultError) {
          Error.throwWithStackTrace((result as ResultError).exception, (result as ResultError).stackTrace);
        }
        return result;
      }
      await ref.read(storedSessionProvider.notifier).storeAndUse(result.value);
      state = .success;
      return const ResultSuccess();
    } catch (ex, stackTrace) {
      List<String> invalidSessionCodes = [
        BackendRequestError.kInvalidPayloadError,
        BackendRequestError.kInvalidTokenError,
        BackendRequestError.kInvalidSessionError,
        BackendRequestError.kExpiredSessionError,
      ];
      if (ex is BackendRequestError && invalidSessionCodes.contains(ex.errorCode)) {
        state = .invalidSession;
      }
      return ResultError(
        exception: ex,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Result<Session>> _sendRefreshRequest(Backend backend, {Session? session}) async {
    try {
      session ??= await ref.read(storedSessionProvider.future);
      if (session == null) {
        throw const NoSessionException();
      }
      Result<RefreshTokenResponse> result = await backend.sendHttpRequest(
        RefreshTokenRequest(
          refreshToken: session.refreshToken,
        ),
        session: session,
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
}

class NoSessionException implements Exception {
  const NoSessionException();

  @override
  String toString() => 'The user must be logged-in to proceed';
}

enum SessionRefreshState { idle, inProgress, success, invalidSession }
