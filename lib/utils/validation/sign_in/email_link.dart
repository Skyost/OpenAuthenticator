import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:open_authenticator/firebase_options.dart';
import 'package:open_authenticator/utils/validation/server.dart';
import 'package:open_authenticator/utils/validation/sign_in/oauth2.dart';

/// Allows to sign in using an email link.
class EmailLinkSignIn extends CompleterAbstractValidationServer<OAuth2Response> {
  /// Triggered when the validation URL is invalid.
  static const String _kErrorInvalidUrl = 'invalid_url';

  /// Triggered when the response is invalid.
  static const String _kErrorInvalidResponse = 'invalid_response';

  /// The email to send the sign-in link to.
  final String email;

  /// The id token of the current user.
  String? _idToken;

  /// Creates a new email link sign in instance.
  EmailLinkSignIn({
    required this.email,
  }) : super(path: 'email-link');

  /// Sends a sign-in link to the [email].
  Future<ValidationResult<OAuth2Response>> sendSignInLinkToEmailAndWaitForConfirmation(ActionCodeSettings actionCodeSettings) async {
    _idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    http.Response response = await http.post(
      Uri.https(
        'identitytoolkit.googleapis.com',
        '/v1/accounts:sendOobCode',
        {
          'key': DefaultFirebaseOptions.currentPlatform.apiKey,
          'continueUrl': url,
          'canHandleCodeInApp': true.toString(),
          'requestType': 'EMAIL_SIGNIN',
          'email': email,
          if (_idToken != null) 'idToken': _idToken,
        },
      ),
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
      },
    );
    if (response.statusCode != 200) {
      return ValidationError(
        exception: ValidationException(code: _kErrorInvalidResponse),
      );
    }
    await start();
    return await completer!.future;
  }

  @override
  FutureOr<ValidationResult<OAuth2Response>> validate(HttpRequest request) async {
    return await validateUrl(request.uri.toString());
  }

  /// Validates the [url] as a sign-in link.
  FutureOr<ValidationResult<OAuth2Response>> validateUrl(String url) async {
    Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      return ValidationError(
        exception: ValidationException(code: _kErrorInvalidUrl),
      );
    }
    String? apiKey = uri.queryParameters['apiKey'];
    String? code = uri.queryParameters['oobCode'];
    if (apiKey == null || code == null) {
      return ValidationError(
        exception: ValidationException(code: _kErrorInvalidUrl),
      );
    }
    http.Response response = await http.post(
      Uri.https(
        'identitytoolkit.googleapis.com',
        '/v1/accounts:signInWithEmailLink',
        {
          'key': DefaultFirebaseOptions.currentPlatform.apiKey,
          'oobCode': code,
          'email': email,
          if (_idToken != null) 'idToken': _idToken,
        },
      ),
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
      },
    );
    if (response.statusCode != 200) {
      return ValidationError(
        exception: ValidationException(code: response.statusCode.toString()),
      );
    }
    Map<String, dynamic> json = jsonDecode(response.body);
    return ValidationSuccess(
      object: OAuth2Response(idToken: json['idToken']),
    );
  }
}
