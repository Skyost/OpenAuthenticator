import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_authenticator/utils/pkce.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/utils/validation/server.dart';
import 'package:open_authenticator/utils/validation/sign_in/oauth2.dart';

/// Allows to sign in using Twitter.
class TwitterSignIn extends OAuth2SignInServer with OAuth2SignInVerifyFragment {
  /// The current PKCE pair.
  PkcePair? pkcePair;

  /// Creates a new Twitter sign in instance.
  TwitterSignIn({
    required super.clientId,
    super.timeout,
  }) : super(
          name: 'Twitter',
        );

  @override
  Future<Result<OAuth2Response>> signIn(BuildContext context) async {
    pkcePair = await PkcePair.generate();
    if (context.mounted) {
      return await super.signIn(context);
    }
    return ResultError(
      exception: ValidationException(),
    );
  }

  @override
  Uri buildUrl() => Uri.https(
        'twitter.com',
        '/i/oauth2/authorize',
        loginUrlParameters,
      );

  @override
  List<String> get scopes => [
        'offline.access',
      ];

  @override
  Map<String, String> get loginUrlParameters => {
        ...super.loginUrlParameters,
        'response_type': 'code',
        'code_challenge': pkcePair!.codeChallenge,
        'code_challenge_method': 'S256',
      };

  @override
  FutureOr<Result<OAuth2Response>> validate(HttpRequest request) async {
    Map<String, List<String>> parameters = request.requestedUri.queryParametersAll;
    if (!parameters.containsKey('code') || !parameters.containsKey('state')) {
      return await super.validate(request);
    }
    if (!validateState(parameters)) {
      return ResultError(
        exception: ValidationException(code: ValidationException.kErrorInvalidState),
      );
    }
    http.Response response = await http.post(
      Uri.https(
        'api.twitter.com',
        '/2/oauth2/token',
      ),
      body: {
        'code': parameters['code']!.first,
        'grant_type': 'authorization_code',
        'client_id': clientId,
        'redirect_uri': url,
        'code_verifier': pkcePair!.codeVerifier,
      },
    );
    if (response.statusCode != 200) {
      return ResultError(
        exception: ValidationException(
          code: ValidationException.kErrorInvalidResponse,
        ),
      );
    }
    Map<String, dynamic> json = jsonDecode(response.body);
    return validateResponse(json.map((key, value) => MapEntry<String, String>(key, value.toString())));
  }
}
