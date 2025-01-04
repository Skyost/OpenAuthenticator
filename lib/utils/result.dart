import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/utils.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';

/// Used all around the project to either return a success, a failure or a cancellation.
sealed class Result<T> {
  /// Creates a new result instance.
  const Result();

  /// Converts this result to another.
  Result<U> to<U>(U? Function(T?) convert);
}

/// When this is a success.
class ResultSuccess<T> extends Result<T> {
  /// The return value.
  final T? _value;

  /// Creates a new result success instance.
  const ResultSuccess({
    T? value,
  }) : _value = value;

  /// Returns the raw [_value].
  T? get valueOrNull => _value;

  /// Returns the [_value], ensuring it's not null.
  T get value => _value!;

  @override
  ResultSuccess<U> to<U>(U? Function(T?) convert) => ResultSuccess(value: convert(valueOrNull));
}

/// When an error occurred.
class ResultError<T> extends Result<T> {
  /// The exception instance.
  final Object? exception;

  /// The current stacktrace.
  final StackTrace stacktrace;

  /// Creates a new result error instance.
  ResultError({
    this.exception,
    StackTrace? stacktrace,
    bool? sendToCrashlytics,
  }) : stacktrace = stacktrace ?? StackTrace.current {
    handleException(exception, stacktrace);
    sendToCrashlytics ??= !kDebugMode && (currentPlatform.isMobile || currentPlatform == Platform.macOS);
    if (sendToCrashlytics) {
      FirebaseCrashlytics.instance.recordError(
        exception,
        stacktrace,
        printDetails: false,
      );
    }
  }

  /// Creates a new result error instance from another [result].
  ResultError.fromAnother(ResultError result)
      : this(
          exception: result.exception,
          stacktrace: result.stacktrace,
        );

  @override
  ResultError<U> to<U>(_) => ResultError<U>.fromAnother(this);
}

/// When it has been cancelled. It should not be handled.
class ResultCancelled<T> extends Result<T> {
  /// Whether this is the result of a timeout.
  final bool timedOut;

  /// Creates a new result cancelled instance.
  const ResultCancelled({
    this.timedOut = false,
  });

  /// Creates a new result cancelled instance from another [result].
  ResultCancelled.fromAnother(ResultCancelled result)
      : this(
          timedOut: result.timedOut,
        );

  @override
  ResultCancelled<U> to<U>(_) => ResultCancelled<U>.fromAnother(this);
}

/// Allows to display a result into a SnackBar.
extension DisplayResult on BuildContext {
  /// Display the given [result].
  void showSnackBarForResult(
    Result result, {
    bool retryIfError = false,
    String? successMessage,
  }) {
    switch (result) {
      case ResultSuccess():
        SnackBarIcon.showSuccessSnackBar(this, text: successMessage ?? translations.error.noError);
        break;
      case ResultError(:final exception):
        if (exception == null) {
          SnackBarIcon.showErrorSnackBar(this, text: retryIfError ? translations.error.generic.tryAgain : translations.error.generic.noTryAgain);
        } else {
          SnackBarIcon.showErrorSnackBar(this, text: translations.error.generic.withException(exception: exception));
        }
        break;
      default:
        break;
    }
  }
}
