import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_authenticator/firebase_options.dart';
import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';
import 'package:open_authenticator/utils/firebase_auth/rest.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/utils/validation/server.dart';

/// Allows to sign in using an email link.
class EmailSignIn extends CompleterAbstractValidationServer<EmailSignInResponse> {
  /// Triggered when the validation URL is invalid.
  static const String _kErrorInvalidUrl = 'invalid_url';

  /// Triggered when the response is invalid.
  static const String _kErrorInvalidResponse = 'invalid_response';

  /// The email to send the sign-in link to.
  final String email;

  /// The id token of the current user.
  String? _idToken;

  /// Creates a new email link sign in instance.
  EmailSignIn({
    required this.email,
  }) : super(
          path: 'email-login',
        );

  /// Sends a sign-in link to the [email].
  Future<Result<EmailSignInResponse>> sendLinkToEmailAndWaitForConfirmation() async {
    Result<EmailSignInResponse>? result = await _sendLinkToEmail();
    if (result != null) {
      return result;
    }
    await start();
    return await future;
  }

  /// Sends a sign-in link to the [email].
  Future<Result<EmailSignInResponse>?> _sendLinkToEmail() async {
    _idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    http.Response response = await http.post(
      Uri.https(
        'identitytoolkit.googleapis.com',
        '/v1/accounts:sendOobCode',
        {
          'key': DefaultFirebaseOptions.currentPlatform.apiKey,
        },
      ),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        FirebaseAuthRest.kLocaleHeader: FirebaseAuth.instance.locale,
      },
      body: jsonEncode({
        'continueUrl': url,
        'canHandleCodeInApp': true,
        'requestType': 'EMAIL_SIGNIN',
        'email': email,
        if (_idToken != null) 'idToken': _idToken,
      }),
    );
    if (response.statusCode != 200) {
      return ResultError(
        exception: const ValidationException(code: _kErrorInvalidResponse),
      );
    }
    return null;
  }

  @override
  FutureOr<Result<EmailSignInResponse>> validate(HttpRequest request) async => await validateUrl(request.uri.toString());

  /// Validates the [url].
  FutureOr<Result<EmailSignInResponse>> validateUrl(String url) async {
    Uri? uri = Uri.tryParse(url);
    String? apiKey = uri?.queryParameters[EmailSignInResponse._kApiKey];
    String? oobCode = uri?.queryParameters[EmailSignInResponse._kOobCode];
    if (apiKey == null || oobCode == null) {
      return ResultError(
        exception: const ValidationException(code: _kErrorInvalidUrl),
      );
    }
    return ResultSuccess(
      value: EmailSignInResponse(
        email: email,
        uri: uri!,
      ),
    );
  }
}

/// Contains the sign-in response.
class EmailSignInResponse {
  /// The API key URI parameter.
  static const String _kApiKey = 'apiKey';

  /// The OOB code URI parameter.
  static const String _kOobCode = 'oobCode';

  /// The user email.
  final String email;

  /// The response URI.
  final Uri uri;

  /// Creates a new email link sign-in response instance.
  const EmailSignInResponse({
    required this.email,
    required this.uri,
  });

  /// Returns the OOB code.
  String get apiKey => uri.queryParameters[_kApiKey]!;

  /// Returns the OOB code.
  String get oobCode => uri.queryParameters[_kOobCode]!;
}
