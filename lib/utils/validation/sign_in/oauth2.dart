import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/utils/utils.dart';
import 'package:open_authenticator/utils/validation/server.dart';

/// Allows to log in the user to various providers.
mixin OAuth2SignIn {
  /// The client id.
  String get clientId;

  /// The provider name.
  String get name;

  /// Tries to sign in the user.
  Future<Result<OAuth2Response>> signIn(BuildContext context);

  /// The scopes to request.
  List<String> get scopes => [];

  /// The default login URL parameters to use.
  Map<String, String> get loginUrlParameters => {
    'client_id': clientId,
    'scope': scopes.join(' '),
  };
}

/// Allows to log in the user to various providers using a [ValidationServer].
abstract class OAuth2SignInServer extends CompleterAbstractValidationServer<OAuth2Response> with OAuth2SignIn {
  @override
  final String clientId;

  @override
  final String name;

  /// The state (used for validation).
  String? _state;

  /// Creates a new sign in validation instance.
  OAuth2SignInServer({
    required this.clientId,
    required this.name,
    super.timeout,
  }) : super(
         path: name.toLowerCase(),
       );

  @override
  Future<Result<OAuth2Response>> signIn(BuildContext context) async {
    _state = generateRandomString();
    await start();
    return await future;
  }

  @override
  @protected
  FutureOr<Result<OAuth2Response>> validate(HttpRequest request) {
    Map<String, String> params = request.uri.queryParameters;
    if (params.containsKey('error')) {
      return ResultError(
        exception: ValidationException(code: params['error'] ?? ValidationException.kErrorGeneric),
      );
    }
    return validateResponse(params);
  }

  /// Validates the response using the [params].
  Result<OAuth2Response> validateResponse(Map<String, String> params) {
    OAuth2Response response = createResponseFromParams(params);
    if (response.accessToken == null && response.idToken == null) {
      return ResultError(
        exception: const ValidationException(code: ValidationException.kErrorNoToken),
      );
    }
    return ResultSuccess<OAuth2Response>(value: response);
  }

  /// Creates a new OAuth2Response instance from the given params.
  OAuth2Response createResponseFromParams(Map<String, String> params) => OAuth2Response.fromResponse(params);

  @override
  Map<String, String> get loginUrlParameters => {
    ...super.loginUrlParameters,
    'redirect_uri': url,
    'state': _state!,
  };

  /// Validates the received state.
  bool validateState(Map<String, List<String>> receivedParams) => receivedParams['state']?.firstOrNull == _state;
}

/// Gives a nonce parameter to sign-in requests.
mixin OAuth2SignInNonce on OAuth2SignInServer {
  /// The nonce parameter.
  String? nonce;

  /// Generates the [nonce].
  FutureOr<void> generateNonce() => nonce = generateRandomString();

  @override
  Future<Result<OAuth2Response>> signIn(BuildContext context) async {
    await generateNonce();
    if (context.mounted) {
      return await super.signIn(context);
    }
    return ResultError(
      exception: const ValidationException(),
    );
  }

  @override
  OAuth2Response createResponseFromParams(Map<String, String> params) => OAuth2Response.fromResponse(
    params,
    nonce: nonce,
  );

  @override
  Map<String, String> get loginUrlParameters => {
    ...super.loginUrlParameters,
    if (nonce != null) 'nonce': nonce!,
  };
}

/// This allows to handle cases where the tokens are returned in the URL hash.
mixin OAuth2SignInVerifyFragment on OAuth2SignInServer {
  @override
  Future<void> handleRequest(HttpRequest request) async {
    if (request.uri.queryParameters.isNotEmpty) {
      return await super.handleRequest(request);
    }
    HttpResponse response = request.response;
    response.headers.contentType = ContentType('text', 'html', charset: 'utf-8');
    await sendResponse(response, _verifyFragmentHtml);
  }

  @override
  OAuth2Response createResponseFromParams(Map<String, String> params) {
    Map<String, String> decodedParams = params.map((key, value) => MapEntry(Uri.decodeComponent(key), Uri.decodeComponent(value)));
    return super.createResponseFromParams(decodedParams);
  }

  /// The HTML / JS code that allows to verify the fragment.
  String get _verifyFragmentHtml =>
      '''<!DOCTYPE html>
<html lang="${translations.$meta.locale.languageCode}">
<head>
  <title>${translations.validation.oauth2.title(name: name)}</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <script type="text/javascript">    
    function init() {
      const noHashLocation = window.location.href.substr(0, window.location.href.indexOf('#'));
      if (noHashLocation.length === 0) {
        window.location = window.location + '?error=${ValidationException.kErrorNoToken}';
        return;
      }
    
      const fragmentString = location.hash.substring(1);
      const regex = /([^&=]+)=([^&]*)/g;
      let match;
      let toAppend = '?';
      while (match = regex.exec(fragmentString)) {
        toAppend += encodeURIComponent(match[1]) + '=' + encodeURIComponent(match[2]) + '&';
      }
      if (toAppend.length > 1) {
        toAppend = toAppend.substr(0, toAppend.length - 1);
        document.getElementById('message').innerHTML = '${translations.validation.oauth2.loading(link: '\$toAppend').replaceAll('\'', '\\\'').replaceAll('\$toAppend', ' + toAppend + ')}';
        window.location = noHashLocation + toAppend;
      }
    }

    window.onload = init;
  </script>
</head>
<body>
  <span id="message">${translations.error.authenticationValidation.oauth2(name: name)}</span>
</body>
</html>''';
}

/// Allows to communicated an OAuth2 response.
class OAuth2Response {
  /// The access token.
  final String? accessToken;

  /// The ID token.
  final String? idToken;

  /// The nonce, if provided.
  final String? nonce;

  /// Creates a new OAuth2 response instance.
  const OAuth2Response({
    this.accessToken,
    this.idToken,
    this.nonce,
  });

  /// Creates a new OAuth2 response instance from the given [receivedParams].
  OAuth2Response.fromResponse(Map<String, String> receivedParams, {String? nonce})
    : this(
        accessToken: receivedParams['access_token'],
        idToken: receivedParams['id_token'],
        nonce: nonce,
      );
}
