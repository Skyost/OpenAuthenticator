import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_authenticator/firebase_options.dart';
import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';
import 'package:open_authenticator/utils/validation/server.dart';

/// Allows to sign in using an email link.
class EmailLinkSignIn extends CompleterAbstractValidationServer<EmailLinkSignInResponse> {
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
  Future<ValidationResult<EmailLinkSignInResponse>> sendSignInLinkToEmailAndWaitForConfirmation() async {
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
  FutureOr<ValidationResult<EmailLinkSignInResponse>> validate(HttpRequest request) async {
    return await validateUrl(request.uri.toString());
  }

  /// Validates the [url] as a sign-in link.
  FutureOr<ValidationResult<EmailLinkSignInResponse>> validateUrl(String url) async {
    Uri? uri = Uri.tryParse(url);
    String? apiKey = uri?.queryParameters['apiKey'];
    String? oobCode = uri?.queryParameters['oobCode'];
    String? email = uri?.queryParameters['email'];
    if (apiKey == null || oobCode == null || email == null) {
      return ValidationError(
        exception: ValidationException(code: _kErrorInvalidUrl),
      );
    }
    return ValidationSuccess(
      object: EmailLinkSignInResponse(
        email: email,
        oobCode: oobCode,
      ),
    );
  }
}

/// Contains the sign-in response.
class EmailLinkSignInResponse {
  /// The user email.
  final String email;

  /// The OOB code.
  final String oobCode;

  /// Creates a new email link sign-in response instance.
  const EmailLinkSignInResponse({
    required this.email,
    required this.oobCode,
  });
}
