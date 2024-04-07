import 'dart:async';

/// Allows to throttle the current stream.
extension StreamThrottle<T> on Stream<T> {
  /// Reduces the rate that events are emitted to at most once per [duration].
  ///
  /// No events will ever be emitted within [duration] of another event on the
  /// result stream.
  /// If this stream is a broadcast stream, the result will be as well.
  /// Errors are forwarded immediately.
  ///
  /// If [trailing] is `false`, source events emitted during the [duration]
  /// period following a result event are discarded.
  /// The result stream will not emit an event until this stream emits an event
  /// following the throttled period.
  /// If this stream is consistently emitting events with less than
  /// [duration] between events, the time between events on the result stream
  /// may still be more than [duration].
  /// The result stream will close immediately when this stream closes.
  ///
  /// If [trailing] is `true`, the latest source event emitted during the
  /// [duration] period following an result event is held and emitted following
  /// the period.
  /// If this stream is consistently emitting events with less than [duration]
  /// between events, the time between events on the result stream will be
  /// [duration].
  /// If this stream closes the result stream will wait to emit a pending event
  /// before closing.
  ///
  /// For example:
  ///
  ///     source.throtte(Duration(seconds: 6));
  ///
  ///     source: 1-2-3---4-5-6---7-8-|
  ///     result: 1-------4-------7---|
  ///
  ///     source.throttle(Duration(seconds: 6), trailing: true);
  ///
  ///     source: 1-2-3---4-5----6--|
  ///     result: 1-----3-----5-----6|
  ///
  ///     source.throttle(Duration(seconds: 6), trailing: true);
  ///
  ///     source: 1-2-----------3|
  ///     result: 1-----2-------3|
  ///
  /// See also:
  /// - [audit], which emits the most recent event at the end of the period.
  /// Compared to `audit`, `throttle` will not introduce delay to forwarded
  /// elements, except for the [trailing] events.
  /// - [debounce], which uses inter-event spacing instead of a fixed period
  /// from the first event in a window. Compared to `debouce`, `throttle` cannot
  /// be starved by having events emitted continuously within [duration].
  Stream<T> throttle(Duration duration, {bool trailing = false}) => trailing ? _throttleTrailing(duration) : _throttle(duration);

  /// Classic throttle transformer.
  Stream<T> _throttle(Duration duration) {
    Timer? timer;

    return transformByHandlers(onData: (data, sink) {
      if (timer == null) {
        sink.add(data);
        timer = Timer(duration, () {
          timer = null;
        });
      }
    });
  }

  /// Throttle with trailing transformer.
  Stream<T> _throttleTrailing(Duration duration) {
    Timer? timer;
    T? pending;
    bool hasPending = false;
    bool isDone = false;

    return transformByHandlers(onData: (data, sink) {
      void onTimer() {
        if (hasPending) {
          sink.add(pending as T);
          if (isDone) {
            sink.close();
          } else {
            timer = Timer(duration, onTimer);
            hasPending = false;
            pending = null;
          }
        } else {
          timer = null;
        }
      }

      if (timer == null) {
        sink.add(data);
        timer = Timer(duration, onTimer);
      } else {
        hasPending = true;
        pending = data;
      }
    }, onDone: (sink) {
      isDone = true;
      if (hasPending) return; // Will be closed by timer.
      sink.close();
      timer?.cancel();
      timer = null;
    });
  }
}

/// Transform the current stream with handlers.
extension _TransformByHandlers<S> on Stream<S> {
  /// Transform a stream by callbacks.
  ///
  /// This is similar to `transform(StreamTransformer.fromHandler(...))` except
  /// that the handlers are called once per event rather than called for the
  /// same event for each listener on a broadcast stream.
  Stream<T> transformByHandlers<T>({Function(S, EventSink<T>)? onData, Function(Object, StackTrace, EventSink<T>)? onError, Function(EventSink<T>)? onDone}) {
    Function(S, EventSink<T>) handleData = onData ?? _defaultHandleData;
    Function(Object, StackTrace, EventSink<T>) handleError = onError ?? _defaultHandleError;
    Function(EventSink<T>) handleDone = onDone ?? _defaultHandleDone;

    StreamController<T> controller = isBroadcast ? StreamController<T>.broadcast(sync: true) : StreamController<T>(sync: true);

    StreamSubscription<S>? subscription;
    controller.onListen = () {
      assert(subscription == null);
      bool valuesDone = false;
      subscription = listen(
            (value) => handleData(value, controller),
        onError: (Object error, StackTrace stackTrace) {
          handleError(error, stackTrace, controller);
        },
        onDone: () {
          valuesDone = true;
          handleDone(controller);
        },
      );
      if (!isBroadcast) {
        controller
          ..onPause = subscription!.pause
          ..onResume = subscription!.resume;
      }
      controller.onCancel = () {
        StreamSubscription<S>? toCancel = subscription;
        subscription = null;
        if (!valuesDone) {
          return toCancel!.cancel();
        }
        return null;
      };
    };
    return controller.stream;
  }

  /// The default data handler.
  static void _defaultHandleData<S, T>(S value, EventSink<T> sink) => sink.add(value as T);

  /// The default error handler.
  static void _defaultHandleError<T>(Object error, StackTrace stackTrace, EventSink<T> sink) => sink.addError(error, stackTrace);

  /// The default completion handler.
  static void _defaultHandleDone<T>(EventSink<T> sink) => sink.close();
}
