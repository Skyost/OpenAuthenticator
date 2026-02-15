import 'dart:math' as math;

import 'package:equatable/equatable.dart';

class SynchronizationStatus with EquatableMixin {
  static const Duration _kMaxBackoff = Duration(minutes: 10);

  final SynchronizationPhase phase;
  final DateTime timestamp;
  final int retryAttempt;

  SynchronizationStatus({
    this.phase = const SynchronizationPhaseIdle(),
    DateTime? timestamp,
    this.retryAttempt = 0,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  List<Object?> get props => [
    phase,
    timestamp,
    retryAttempt,
  ];

  SynchronizationStatus update({
    DateTime? timestamp,
    SynchronizationPhase? phase,
    int? retryAttempt,
  }) => copyWith(
    phase: phase,
    retryAttempt: retryAttempt,
    timestamp: DateTime.now(),
  );

  SynchronizationStatus copyWith({
    SynchronizationPhase? phase,
    DateTime? timestamp,
    int? retryAttempt,
  }) => SynchronizationStatus(
    phase: phase ?? this.phase,
    timestamp: timestamp ?? this.timestamp,
    retryAttempt: retryAttempt ?? this.retryAttempt,
  );

  /// The next possible operation time.
  DateTime get nextPossibleOperationTime => timestamp.add(phase._threshold);

  /// Waits before the next operation.
  Future<void> waitBeforeNextOperation() {
    DateTime now = DateTime.now();
    if (now.isAfter(nextPossibleOperationTime)) {
      return Future.value();
    }
    return Future.delayed(nextPossibleOperationTime.difference(now));
  }

  int calculateRetrySeconds() {
    int retryAttempt = math.min(this.retryAttempt <= 0 ? 1 : this.retryAttempt, 10);
    int baseSeconds = math.pow(2, retryAttempt).toInt();
    int capSeconds = _kMaxBackoff.inSeconds;
    int seconds = math.min(baseSeconds, capSeconds);
    return seconds;
  }
}

sealed class SynchronizationPhase {

  const SynchronizationPhase();

  Duration get _threshold => const Duration(seconds: 5);
}

class SynchronizationPhaseIdle extends SynchronizationPhase {
  const SynchronizationPhaseIdle();

  @override
  Duration get _threshold => Duration.zero;
}

class SynchronizationPhaseOffline extends SynchronizationPhase {
  const SynchronizationPhaseOffline();

  @override
  Duration get _threshold => Duration.zero;
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
