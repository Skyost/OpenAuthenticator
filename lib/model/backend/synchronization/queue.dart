import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:open_authenticator/model/backend/backend.dart';
import 'package:open_authenticator/model/backend/request/request.dart';
import 'package:open_authenticator/model/backend/request/response.dart';
import 'package:open_authenticator/model/backend/synchronization/operation.dart';
import 'package:open_authenticator/model/backend/synchronization/status.dart';
import 'package:open_authenticator/model/settings/storage_type.dart';
import 'package:open_authenticator/model/totp/database/database.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/utils/result.dart';

final pushOperationsQueueProvider = AsyncNotifierProvider<PushOperationsQueue, List<PushOperation>>(PushOperationsQueue.new);

class PushOperationsQueue extends AsyncNotifier<List<PushOperation>> {
  @override
  Future<List<PushOperation>> build() async {
    TotpDatabase database = ref.watch(totpsDatabaseProvider);
    return await database.listPendingBackendPushOperations();
  }

  Future<void> enqueue(
    PushOperation operation, {
    bool checkSettings = true,
    bool andRun = true,
  }) async {
    TotpDatabase database = ref.read(totpsDatabaseProvider);
    await database.addPendingBackendPushOperation(operation);
    ref.invalidateSelf();
    if (andRun) {
      ref.read(synchronizationControllerProvider.notifier).notifyLocalChange();
    }
  }

  Future<void> _pushAndPull({ bool checkSettings = true }) async {
    if ((await _push(checkSettings: checkSettings)) is ResultSuccess) {
      await _pull(checkSettings: checkSettings);
    }
  }

  Future<Result> _push({ bool checkSettings = true }) async {
    if (checkSettings) {
      StorageType storageType = await ref.read(storageTypeSettingsEntryProvider.future);
      if (storageType == StorageType.localOnly) {
        return const ResultCancelled();
      }
    }
    List<PushOperation> operations = await future;
    if (operations.isEmpty) {
      return const ResultSuccess();
    }

    Result<SynchronizationPushResponse> result = await ref
        .read(backendProvider.notifier)
        .sendHttpRequest(
          SynchronizationPushRequest(
            operations: operations,
          ),
        );
    if (result is! ResultSuccess<SynchronizationPushResponse>) {
      return result;
    }

    TotpDatabase database = ref.read(totpsDatabaseProvider);
    await database.applyPushResponse(result.value);
    ref.invalidateSelf();
    return const ResultSuccess();
  }

  Future<Result> _pull({ bool checkSettings = true }) async {
    if (checkSettings) {
      StorageType storageType = await ref.read(storageTypeSettingsEntryProvider.future);
      if (storageType == StorageType.localOnly) {
        return const ResultCancelled();
      }
    }
    TotpList totps = await ref.read(totpRepositoryProvider.future);
    Result<SynchronizationPullResponse> result = await ref
        .read(backendProvider.notifier)
        .sendHttpRequest(
          SynchronizationPullRequest(
            timestamps: {
              for (Totp totp in totps) totp.uuid: totp.updatedAt,
            },
          ),
        );
    if (result is! ResultSuccess<SynchronizationPullResponse>) {
      return result;
    }

    TotpRepository repository = ref.read(totpRepositoryProvider.notifier);
    await repository.addTotps(
      result.value.inserts,
      fromNetwork: true,
    );
    await repository.updateTotps(
      result.value.updates,
      fromNetwork: true,
    );
    await repository.deleteTotps(
      result.value.deletes,
      fromNetwork: true,
    );
    return const ResultSuccess();
  }
}

final synchronizationControllerProvider = NotifierProvider<SynchronizationController, SynchronizationStatus>(SynchronizationController.new);

class SynchronizationController extends Notifier<SynchronizationStatus> with WidgetsBindingObserver {
  static const Duration _kPeriodicInterval = Duration(minutes: 10);

  static const Duration _kCoalesceDelay = Duration(milliseconds: 300);

  final Connectivity _connectivity = Connectivity();
  final Random _random = Random();

  Timer? _coalesceTimer;
  Timer? _retryTimer;

  @override
  SynchronizationStatus build() {
    StorageType? storageType = ref.read(storageTypeSettingsEntryProvider).value;
    if (storageType == StorageType.localOnly) {
      return SynchronizationStatus();
    }

    // WidgetsBinding.instance.addObserver(this);
    ref.onDispose(_dispose);

    StreamSubscription<List<ConnectivityResult>>? subscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    ref.onDispose(subscription.cancel);

    Timer periodicTimer = Timer.periodic(_kPeriodicInterval, (_) => notifyLocalChange());
    ref.onDispose(periodicTimer.cancel);

    notifyLocalChange();

    return SynchronizationStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      notifyLocalChange();
    }
  }

  void _dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _coalesceTimer?.cancel();
    _retryTimer?.cancel();

    _coalesceTimer = null;
    _retryTimer = null;
  }

  void _onConnectivityChanged(List<ConnectivityResult> result) {
    if (result.firstOrNull == ConnectivityResult.none) {
      state = state.update(
        phase: const SynchronizationPhaseOffline(),
      );
    } else {
      notifyLocalChange();
    }
  }

  void notifyLocalChange() {
    if (_retryTimer != null) {
      return;
    }

    _coalesceTimer?.cancel();
    _coalesceTimer = Timer(
      _kCoalesceDelay,
      () {
        _coalesceTimer = null;
        _runOnce();
      },
    );
  }

  Future<void> forceSync() async {
    _coalesceTimer?.cancel();
    _coalesceTimer = null;
    await _runOnce();
  }

  Future<void> _runOnce() async {
    bool retry = true;
    try {
      if (state.phase is SynchronizationPhaseSyncing) {
        return;
      }

      state = state.update(
        retryAttempt: state.retryAttempt + 1,
      );

      List<ConnectivityResult> result = await _connectivity.checkConnectivity();
      if (result.firstOrNull == ConnectivityResult.none) {
        state = state.update(
          phase: const SynchronizationPhaseOffline(),
        );
      } else {
        state = state.update(
          phase: const SynchronizationPhaseSyncing(),
        );

        await ref.read(pushOperationsQueueProvider.notifier)._pushAndPull();

        List<PushOperation> pendingAfter = await ref.read(pushOperationsQueueProvider.future);
        retry = pendingAfter.isNotEmpty;
        state = state.update(
          phase: const SynchronizationPhaseUpToDate(),
          retryAttempt: retry ? state.retryAttempt : 0,
        );
      }
    } catch (ex, stackTrace) {
      state = state.update(
        phase: SynchronizationPhaseError(
          exception: ex,
          stackTrace: stackTrace,
        ),
      );
    }
    if (retry) {
      _scheduleRetry();
    } else {
      _retryTimer?.cancel();
      _retryTimer = null;
    }
  }

  void _scheduleRetry() {
    int jitterMs = _random.nextInt(250);

    _retryTimer?.cancel();
    _retryTimer = Timer(
      Duration(
        seconds: state.calculateRetrySeconds(),
        milliseconds: jitterMs,
      ),
      () {
        _retryTimer = null;
        _runOnce();
      },
    );
  }
}

extension WithErrors on AsyncNotifierProvider<PushOperationsQueue, List<PushOperation>> {
  ProviderListenable<AsyncValue<List<PushOperation>>> selectWithErrors() => select(
    (value) => switch (value) {
      AsyncData(:final value) => AsyncData(value.where((operation) => operation.lastError != null).toList()),
      _ => value,
    },
  );
}
