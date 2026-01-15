import 'dart:math' as math;

import 'package:equatable/equatable.dart';

class SynchronizationStatus with EquatableMixin {
  static const Duration _kMaxBackoff = Duration(minutes: 10);

  final SynchronizationPhase phase;
  final int pendingOperations;
  final DateTime timestamp;
  final int retryAttempt;

  SynchronizationStatus({
    this.phase = const SynchronizationPhaseIdle(),
    this.pendingOperations = 0,
    DateTime? timestamp,
    this.retryAttempt = 0,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  List<Object?> get props => [
    phase,
    pendingOperations,
    timestamp,
    retryAttempt,
  ];

  SynchronizationStatus update({
    SynchronizationPhase? phase,
    int? pendingOperations,
    int? retryAttempt,
  }) => copyWith(
    phase: phase,
    pendingOperations: pendingOperations,
    retryAttempt: retryAttempt,
    timestamp: DateTime.now(),
  );

  SynchronizationStatus copyWith({
    SynchronizationPhase? phase,
    int? pendingOperations,
    DateTime? timestamp,
    int? retryAttempt,
  }) => SynchronizationStatus(
    phase: phase ?? this.phase,
    pendingOperations: pendingOperations ?? this.pendingOperations,
    timestamp: timestamp ?? this.timestamp,
    retryAttempt: retryAttempt ?? this.retryAttempt,
  );

  int calculateRetrySeconds() {
    int retryAttempt = math.min(this.retryAttempt + 1, 10);
    int baseSeconds = math.pow(2, retryAttempt).toInt();
    int capSeconds = _kMaxBackoff.inSeconds;
    int seconds = math.min(baseSeconds, capSeconds);
    return seconds;
  }
}

sealed class SynchronizationPhase {
  const SynchronizationPhase();
}

class SynchronizationPhaseIdle extends SynchronizationPhase {
  const SynchronizationPhaseIdle();
}

class SynchronizationPhaseOffline extends SynchronizationPhase {
  const SynchronizationPhaseOffline();
}

class SynchronizationPhaseSyncing extends SynchronizationPhase {
  const SynchronizationPhaseSyncing();
}

class SynchronizationPhaseUpToDate extends SynchronizationPhase {
  const SynchronizationPhaseUpToDate();
}

class SynchronizationPhaseError extends SynchronizationPhase {
  /// The exception instance.
  final Object? exception;

  /// The current stacktrace.
  final StackTrace stackTrace;

  SynchronizationPhaseError({
    this.exception,
    StackTrace? stackTrace,
  }) : stackTrace = stackTrace ?? StackTrace.current;
}
