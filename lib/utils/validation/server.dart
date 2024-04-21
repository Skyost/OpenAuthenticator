import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:url_launcher/url_launcher.dart';

/// Allows to validate various web requests that allows to give a callback URL.
abstract class AbstractValidationServer<T> {
  /// The server port.
  final int port;

  /// The server path.
  final String path;

  /// The validation timeout.
  Duration? timeout;

  /// The HTTP server instance.
  HttpServer? _server;

  /// The timeout timer.
  Timer? _timeoutTimer;

  /// Creates a new abstract validation server instance.
  AbstractValidationServer({
    this.port = 5000,
    required this.path,
    this.timeout = const Duration(minutes: 5),
  });

  /// The server URL.
  String get url => 'http://localhost:$port/$path/';

  /// Starts the validation server.
  Future<void> start() async {
    _server = await HttpServer.bind('localhost', port);
    _server!.listen(handleRequest);
    Uri? url = await buildUrl();
    if (url != null && await canLaunchUrl(url)) {
      launchUrl(url);
    }
    if (timeout != null) {
      _timeoutTimer = Timer(timeout!, () => cancel(timedOut: true));
    }
  }

  /// Allows to handle HTTP requests.
  Future<void> handleRequest(HttpRequest request) async {
    HttpResponse response = request.response;
    response.headers.contentType = ContentType('text', 'plain', charset: 'utf-8');
    if (request.uri.pathSegments.firstOrNull != path) {
      await sendResponse(response, translations.error.authenticationValidation.incorrectPath(path: request.uri.pathSegments.firstOrNull as Object));
      return;
    }
    ValidationResult<T>? object = await validate(request);
    switch (object) {
      case ValidationSuccess():
        await sendResponse(response, translations.validation.success);
        break;
      case ValidationError(:final exception):
        await sendResponse(response, translations.error.authenticationValidation.generic(exception: exception));
        break;
      default:
        break;
    }
    if (onValidate(object)) {
      await close();
    }
  }

  /// Sends a [message] to the given [response].
  Future<void> sendResponse(HttpResponse response, String message) async {
    response.write(message);
    await response.flush();
    await response.close();
    await response.done;
  }

  /// Cancels the validation.
  Future<void> cancel({bool timedOut = false}) async {
    onValidate(ValidationCancelled(timedOut: timedOut));
    await close();
  }

  /// Closes the validation server.
  Future<void> close() async {
    await _server?.close(force: true);
    _server = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  /// Builds the URL to launch.
  FutureOr<Uri?> buildUrl() => null;

  /// Validates the [request].
  FutureOr<ValidationResult<T>> validate(HttpRequest request);

  /// Triggered when a validation object has been received.
  bool onValidate(ValidationResult<T> object);
}

/// An [AbstractValidationServer] based on a completer.
abstract class CompleterAbstractValidationServer<T> extends AbstractValidationServer<T> {
  /// The Future completer.
  @protected
  Completer<ValidationResult<T>>? completer;

  /// Creates a new completer abstract validation server instance.
  CompleterAbstractValidationServer({
    super.port,
    required super.path,
    super.timeout,
  });

  @override
  @mustCallSuper
  Future<void> start() async {
    await super.start();
    completer = Completer();
  }

  @override
  bool onValidate(ValidationResult<T> object) {
    switch (object) {
      case ValidationSuccess<T>():
      case ValidationCancelled<T>():
        completer?.complete(object);
        break;
      case ValidationError<T>(:final exception):
        completer?.completeError(exception);
        break;
    }
    return true;
  }
}

/// Allows to instantiate [AbstractValidationServer].
class ValidationServer<T> extends AbstractValidationServer<T> {
  /// The validator.
  final FutureOr<ValidationResult<T>> Function(HttpRequest) _validate;

  /// Builds the URL to launch for validation.
  final FutureOr<Uri?> Function(String)? _urlBuilder;

  /// Triggered when the validation has been completed.
  final Function(T)? _onValidationCompleted;

  /// Triggered when there has been an error validating the request.
  final Function(ValidationException)? _onValidationFailed;

  /// Triggered when the validation has been cancelled.
  final Function(bool)? _onValidationCancelled;

  /// Creates a new validation server instance.
  ValidationServer({
    super.port,
    required super.path,
    FutureOr<Uri?> Function(String)? urlBuilder,
    required FutureOr<ValidationResult<T>> Function(HttpRequest) validate,
    Function(T)? onValidationCompleted,
    Function(ValidationException)? onValidationFailed,
    Function(bool)? onValidationCancelled,
    super.timeout,
  })  : _urlBuilder = urlBuilder,
        _validate = validate,
        _onValidationCompleted = onValidationCompleted,
        _onValidationFailed = onValidationFailed,
        _onValidationCancelled = onValidationCancelled;

  @override
  @protected
  FutureOr<Uri?> buildUrl() => _urlBuilder?.call(url);

  @override
  @protected
  FutureOr<ValidationResult<T>> validate(HttpRequest request) => _validate(request);

  @override
  bool onValidate(ValidationResult<T> result) {
    switch (result) {
      case ValidationSuccess<T>(:final object):
        _onValidationCompleted?.call(object);
        break;
      case ValidationCancelled<T>(:final timedOut):
        _onValidationCancelled?.call(timedOut);
        break;
      case ValidationError<T>(:final exception):
        _onValidationFailed?.call(exception);
        break;
    }
    return true;
  }
}

/// An object returned from a [ValidationServer].
sealed class ValidationResult<T> {
  /// The return object.
  final T? object;

  /// Creates a new validation object instance.
  const ValidationResult({
    this.object,
  });
}

/// Returned when the validation is a success.
class ValidationSuccess<T> extends ValidationResult<T> {
  /// Creates a new validation success instance.
  const ValidationSuccess({
    required T super.object,
  });

  @override
  T get object => super.object as T;
}

/// Returned when the validation has been cancelled.
class ValidationCancelled<T> extends ValidationResult<T> {
  /// Whether this is the result of a timeout.
  final bool timedOut;

  /// Creates a new validation cancelled instance.
  const ValidationCancelled({
    this.timedOut = false,
  });
}

/// Returned when there is an error.
class ValidationError<T> extends ValidationResult<T> {
  /// The exception instance.
  final ValidationException exception;

  /// Creates a new validation error instance.
  const ValidationError({
    super.object,
    required this.exception,
  });
}

/// An exception triggered when validating.
class ValidationException implements Exception {
  /// The error code for when there is no token in a query parameters.
  static const String kErrorNoToken = 'no_token_returned';

  /// Triggered when the response is invalid.
  static const String kErrorInvalidResponse = 'invalid_response';

  /// The error code for when the returned state is invalid.
  static const String kErrorInvalidState = 'invalid_state';

  /// Triggered when a generic error occurs.
  static const String kErrorGeneric = 'generic';

  /// The error code.
  final String? code;

  /// Creates a new validation exception instance.
  ValidationException({
    required this.code,
  });

  @override
  String toString() => 'ValidationException "$code"';
}
