import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/utils/validation/server.dart';
import 'package:open_authenticator/utils/validation/sign_in/oauth2.dart';
import 'package:webcrypto/webcrypto.dart';

/// Allows to sign in using Apple.
class AppleSignIn extends OAuth2SignInServer with OAuth2SignInVerifyFragment, OAuth2SignInNonce {
  /// The user email.
  final String? email;

  /// The hashed nonce.
  String? _hashedNonce;

  /// Creates a new Apple sign in instance.
  AppleSignIn({
    required super.clientId,
    this.email,
    super.timeout,
  }) : super(
          name: 'Apple',
        );

  @override
  Uri buildUrl() => Uri.https(
        'appleid.apple.com',
        '/auth/authorize',
        loginUrlParameters,
      );

  @override
  List<String> get scopes => [
        'email',
        'name',
      ];

  @override
  Map<String, String> get loginUrlParameters => {
        ...super.loginUrlParameters,
        if (_hashedNonce != null) 'nonce': _hashedNonce!,
        'redirect_uri': App.appleSignInReturnUrl,
        'response_type': 'code id_token',
        'response_mode': 'form_post',
        'prompt': 'select_account',
      };

  @override
  Future<void> generateNonce() async {
    await super.generateNonce();
    Uint8List digest = await Hash.sha256.digestBytes(utf8.encode(nonce!));
    _hashedNonce = _hexEncode(digest);
  }

  @override
  Future<Result<OAuth2Response>> validate(HttpRequest request) async {
    if (!validateState(request.requestedUri.queryParametersAll)) {
      return ResultError(
        exception: const ValidationException(code: ValidationException.kErrorInvalidState),
      );
    }
    return super.validate(request);
  }

  /// Encodes the [bytes] into an hexadecimal string.
  String _hexEncode(List<int> bytes) {
    String hexDigits = '0123456789abcdef';
    Uint8List charCodes = Uint8List(bytes.length * 2);
    for (var i = 0, j = 0; i < bytes.length; i++) {
      int byte = bytes[i];
      charCodes[j++] = hexDigits.codeUnitAt((byte >> 4) & 0xF);
      charCodes[j++] = hexDigits.codeUnitAt(byte & 0xF);
    }
    return String.fromCharCodes(charCodes);
  }
}
