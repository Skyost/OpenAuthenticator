import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/backend/backend.dart';
import 'package:open_authenticator/model/backend/connectivity.dart';
import 'package:open_authenticator/model/backend/request/request.dart';
import 'package:open_authenticator/model/backend/request/response.dart';
import 'package:open_authenticator/model/backend/synchronization/push/operation.dart';
import 'package:open_authenticator/model/backend/synchronization/push/result.dart';
import 'package:open_authenticator/model/backend/synchronization/status.dart';
import 'package:open_authenticator/model/database/database.dart';
import 'package:open_authenticator/model/settings/storage_type.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/utils/result.dart';

final pushOperationsErrorsProvider = StreamProvider<List<PushOperationResult>>((ref) => ref.watch(appDatabaseProvider).watchBackendPushOperationErrors());

final pushOperationsQueueProvider = AsyncNotifierProvider<PushOperationsQueue, List<PushOperation>>(PushOperationsQueue.new);

class PushOperationsQueue extends AsyncNotifier<List<PushOperation>> {
  @override
  Future<List<PushOperation>> build() async {
    AppDatabase database = ref.watch(appDatabaseProvider);
    StreamSubscription<List<PushOperation>> subscription = database.watchPendingBackendPushOperations().listen(_onDatabaseUpdate);
    ref.onDispose(subscription.cancel);

    return await database.listPendingBackendPushOperations();
  }

  Future<void> enqueue(
    PushOperation operation, {
    bool checkSettings = true,
    bool andRun = true,
  }) async {
    AppDatabase database = ref.read(appDatabaseProvider);
    await database.addPendingBackendPushOperation(operation);
    if (andRun) {
      ref.read(synchronizationControllerProvider.notifier).notifyLocalChange();
    }
  }

  Future<Result> _push({bool checkSettings = true}) async {
    if (checkSettings) {
      StorageType storageType = await ref.read(storageTypeSettingsEntryProvider.future);
      if (storageType == StorageType.localOnly) {
        return const ResultCancelled();
      }
    }
    List<PushOperation> operations = await future;
    List<PushOperation> compactedOperations = _compact(operations);
    AppDatabase database = ref.read(appDatabaseProvider);
    if (compactedOperations.length != operations.length) {
      await database.replacePendingBackendPushOperations(compactedOperations);
    }

    if (compactedOperations.isEmpty) {
      return const ResultSuccess();
    }

    Result<SynchronizationPushResponse> result = await ref
        .read(backendProvider.notifier)
        .sendHttpRequest(
          SynchronizationPushRequest(
            operations: compactedOperations,
          ),
        );
    if (result is! ResultSuccess<SynchronizationPushResponse>) {
      return result;
    }

    await database.applyPushResponse(result.value);
    return const ResultSuccess();
  }

  Future<Result> _pull({bool checkSettings = true}) async {
    if (checkSettings) {
      StorageType storageType = await ref.read(storageTypeSettingsEntryProvider.future);
      if (storageType == StorageType.localOnly) {
        return const ResultCancelled();
      }
    }
    List<Totp> totps = await ref.read(totpRepositoryProvider.future);
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

  List<PushOperation> _compact(List<PushOperation> operations) {
    if (operations.isEmpty) {
      return [];
    }

    Set<String> processedTotpUuids = {};
    List<PushOperation> result = [];

    for (PushOperation operation in operations.reversed) {
      switch (operation.kind) {
        case PushOperationKind.set:
          Map<String, dynamic> payload = operation.payload as Map<String, dynamic>;
          Map<String, dynamic> newPayload = {
            for (MapEntry<String, dynamic> entry in payload.entries)
              if (processedTotpUuids.add(entry.key)) entry.key: entry.value,
          };
          if (newPayload.isNotEmpty) {
            result.add(operation.copyWith(payload: newPayload));
          }
          break;
        case PushOperationKind.delete:
          List<String> payload = operation.payload as List<String>;
          List<String> newPayload = payload.where((uuid) => processedTotpUuids.add(uuid)).toList();
          if (newPayload.isNotEmpty) {
            result.add(operation.copyWith(payload: newPayload));
          }
          break;
      }
    }

    return result.reversed.toList();
  }

  void _onDatabaseUpdate(List<PushOperation> operations) {
    state = AsyncData(operations);
  }
}

final synchronizationControllerProvider = NotifierProvider<SynchronizationController, SynchronizationStatus>(SynchronizationController.new);

class SynchronizationController extends Notifier<SynchronizationStatus> {
  static const Duration _kPeriodicInterval = Duration(minutes: 10);

  static const Duration _kCoalesceDelay = Duration(milliseconds: 300);

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

    Timer periodicTimer = Timer.periodic(_kPeriodicInterval, (_) => notifyLocalChange());
    ref.onDispose(periodicTimer.cancel);

    notifyLocalChange();

    AsyncValue<bool> connectivityState = ref.watch(connectivityStateProvider);
    return SynchronizationStatus(
      phase: connectivityState.value == true ? const SynchronizationPhaseIdle() : const SynchronizationPhaseOffline(),
    );
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     notifyLocalChange();
  //   }
  // }

  void _dispose() {
    // WidgetsBinding.instance.removeObserver(this);

    _coalesceTimer?.cancel();
    _retryTimer?.cancel();

    _coalesceTimer = null;
    _retryTimer = null;
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
        _run();
      },
    );
  }

  Future<void> forceSync() async {
    _retryTimer?.cancel();
    _retryTimer = null;
    _coalesceTimer?.cancel();
    _coalesceTimer = null;
    await _run();
  }

  Future<void> _run() async {
    bool retry = true;
    try {
      if (state.phase is SynchronizationPhaseSyncing) {
        return;
      }

      state = state.copyWith(
        phase: const SynchronizationPhaseSyncing(),
      );
      await state.waitBeforeNextOperation();
      state = state.update(
        retryAttempt: state.retryAttempt + 1,
      );

      bool canReachBackend = await ref.read(connectivityStateProvider.future);
      if (canReachBackend) {
        void onFinish({bool retry = true}) => state = state.update(
          phase: const SynchronizationPhaseUpToDate(),
          retryAttempt: retry ? state.retryAttempt : 0,
        );
        Result pushResult = await ref.read(pushOperationsQueueProvider.notifier)._push();
        if (pushResult is! ResultSuccess) {
          if (pushResult is ResultCancelled) {
            onFinish(retry: false);
          } else {
            (Object, StackTrace) error = pushResult is ResultError ? (pushResult.exception, pushResult.stackTrace) : (Exception('An error occurred while pushing.'), StackTrace.current);
            Error.throwWithStackTrace(error.$1, error.$2);
          }
        } else {
          Result pullResult = await ref.read(pushOperationsQueueProvider.notifier)._pull();
          if (pullResult is! ResultSuccess) {
            if (pullResult is ResultCancelled) {
              onFinish(retry: false);
            } else {
              (Object, StackTrace) error = pullResult is ResultError ? (pullResult.exception, pullResult.stackTrace) : (Exception('An error occurred while pulling.'), StackTrace.current);
              Error.throwWithStackTrace(error.$1, error.$2);
            }
          }

          List<PushOperation> pendingAfter = await ref.read(pushOperationsQueueProvider.future);
          retry = pendingAfter.isNotEmpty;
          onFinish(retry: retry);
        }
      } else {
        state = state.update(
          phase: const SynchronizationPhaseOffline(),
        );
        retry = false;
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
        _run();
      },
    );
  }
}
