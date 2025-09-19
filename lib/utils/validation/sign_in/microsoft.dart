import 'package:open_authenticator/utils/validation/sign_in/oauth2.dart';

/// Allows to sign in using Microsoft.
class MicrosoftSignIn extends OAuth2SignInServer with OAuth2SignInVerifyFragment, OAuth2SignInNonce {
  /// The user email.
  final String? email;

  /// Creates a new Azure sign in instance.
  MicrosoftSignIn({
    required super.clientId,
    this.email,
    super.timeout,
  }) : super(
         name: 'Microsoft',
       );

  @override
  Uri buildUrl() => Uri.https(
    'login.microsoftonline.com',
    '/common/oauth2/v2.0/authorize',
    loginUrlParameters,
  );

  @override
  Map<String, String> get loginUrlParameters => {
    ...super.loginUrlParameters,
    'response_type': 'id_token token',
    'response_mode': 'fragment',
    'prompt': 'select_account',
    if (email != null) 'login_hint': email!,
  };

  @override
  List<String> get scopes => [
    'openid',
    'email',
    'offline_access',
  ];
}
