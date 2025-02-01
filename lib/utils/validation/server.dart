import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/utils/result.dart';
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
  String get url => 'http://localhost:${_server?.port ?? port}/$path/';

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
    Result<T>? object = await validate(request);
    switch (object) {
      case ResultSuccess():
        await sendResponse(response, translations.validation.success);
        break;
      case ResultError(:final exception):
        await sendResponse(response, translations.error.authenticationValidation.generic(exception: exception ?? ValidationException()));
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
    onValidate(ResultCancelled(timedOut: timedOut));
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
  FutureOr<Result<T>> validate(HttpRequest request);

  /// Triggered when a validation object has been received.
  bool onValidate(Result<T> object);
}

/// An [AbstractValidationServer] based on a completer.
abstract class CompleterAbstractValidationServer<T> extends AbstractValidationServer<T> {
  /// The Future completer.
  @protected
  Completer<Result<T>>? _completer;

  /// Creates a new completer abstract validation server instance.
  CompleterAbstractValidationServer({
    super.port,
    required super.path,
    super.timeout,
  });

  /// Returns the [_completer.future].
  Future<Result<T>> get future => _completer!.future;

  @override
  @mustCallSuper
  Future<void> start() async {
    await super.start();
    _completer = Completer();
  }

  @override
  bool onValidate(Result<T> object) {
    switch (object) {
      case ResultSuccess<T>():
      case ResultCancelled<T>():
        _completer?.complete(object);
        break;
      case ResultError<T>(:final exception):
        _completer?.completeError(exception ?? ValidationException());
        break;
    }
    return true;
  }
}

/// Allows to instantiate [AbstractValidationServer].
class ValidationServer<T> extends AbstractValidationServer<T> {
  /// The validator.
  final FutureOr<Result<T>> Function(HttpRequest) _validate;

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
    required FutureOr<Result<T>> Function(HttpRequest) validate,
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
  FutureOr<Result<T>> validate(HttpRequest request) => _validate(request);

  @override
  bool onValidate(Result<T> result) {
    switch (result) {
      case ResultSuccess<T>(:final value):
        _onValidationCompleted?.call(value);
        break;
      case ResultCancelled<T>(:final timedOut):
        _onValidationCancelled?.call(timedOut);
        break;
      case ResultError<T>(:final exception):
        _onValidationFailed?.call(exception is ValidationException ? exception : ValidationException());
        break;
    }
    return true;
  }
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
  final String code;

  /// Creates a new validation exception instance.
  const ValidationException({
    this.code = kErrorGeneric,
  });

  @override
  String toString() => 'ValidationException "$code"';
}
