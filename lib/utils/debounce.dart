import 'dart:async';

/// A collection of of functions to debounce calls to a target function.
class Debounce {
  /// Map of functions currently being debounced.
  final Map<Function, _DebounceTimer> _timeouts = <Function, _DebounceTimer>{};

  /// Clear a function that has been debounced. Returns [true] if
  /// a debounced function has been removed.
  bool clear(Function target) {
    if (_timeouts.containsKey(target)) {
      _timeouts[target]?.cancel();
      _timeouts.remove(target);
      return true;
    }

    return false;
  }

  /// Calls [target] with the latest supplied [positionalArguments] and [namedArguments]
  /// after a [timeout] duration.
  ///
  /// Repeated calls to [duration] (or any debounce operation in this library)
  /// with the same [Function target] will reset the specified [timeout].
  void duration(Duration timeout, Function target, [List<dynamic> positionalArguments = const [], Map<Symbol, dynamic> namedArguments = const {}]) {
    if (_timeouts.containsKey(target)) {
      clear(target);
    }

    final timer = _DebounceTimer(timeout, target, positionalArguments, namedArguments);
    _timeouts[target] = timer;
  }

  /// Calls [duration] with a timeout specified in milliseconds.
  void milliseconds(
    int timeoutMs,
    Function target, [
    List<dynamic> positionalArguments = const [],
    Map<Symbol, dynamic> namedArguments = const {},
  ]) =>
      duration(Duration(milliseconds: timeoutMs), target, positionalArguments, namedArguments);

  /// Run a function which is already debounced (queued to be run later),
  /// but run it now. This also cancels and clears out the timeout for
  /// that function.
  ///
  /// If [positionalArguments] and [namedArguments] is not null or empty,
  /// a new version of [target] will be called with those arguments.
  void runAndClear(Function target, [List<dynamic> positionalArguments = const [], Map<Symbol, dynamic> namedArguments = const {}]) {
    if (_timeouts.containsKey(target)) {
      if (positionalArguments.isNotEmpty || namedArguments.isNotEmpty) {
        _timeouts[target]?.cancel();
        Function.apply(target, positionalArguments, namedArguments);
      } else {
        _timeouts[target]?.runNow();
      }
      _timeouts.remove(target);
    }
  }

  /// Calls [duration] with a timeout specified in seconds.
  void seconds(
    int timeoutSeconds,
    Function target, [
    List<dynamic> positionalArguments = const [],
    Map<Symbol, dynamic> namedArguments = const {},
  ]) =>
      duration(Duration(seconds: timeoutSeconds), target, positionalArguments, namedArguments);
}

/// _DebounceTimer allows us to keep track of the target function
/// along with it's timer.
class _DebounceTimer {
  /// The timer.
  final Timer timer;

  /// The target.
  final Function target;

  /// The positional arguments
  final List<dynamic> positionalArguments;

  /// The named arguments.
  final Map<Symbol, dynamic> namedArguments;

  /// Creates a new debounce timer instance.
  _DebounceTimer(
    Duration timeout,
    this.target, [
    this.positionalArguments = const [],
    this.namedArguments = const {},
  ]) : timer = Timer(
          timeout,
          () {
            Function.apply(target, positionalArguments, namedArguments);
          },
        );

  /// Cancels this timer.
  void cancel() => timer.cancel();

  /// Runs the target now.
  void runNow() {
    timer.cancel();
    Function.apply(target, positionalArguments, namedArguments);
  }
}
