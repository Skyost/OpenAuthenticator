import 'package:open_authenticator/utils/validation/sign_in/oauth2.dart';

/// Allows to sign in using Google.
class GoogleSignIn extends OAuth2SignInServer with OAuth2SignInVerifyFragment, OAuth2SignInNonce {
  /// The user email.
  final String? email;

  /// Creates a new Google sign in instance.
  GoogleSignIn({
    required super.clientId,
    this.email,
    super.timeout,
  }) : super(
          name: 'Google',
        );

  @override
  Uri buildUrl() => Uri.https(
        'accounts.google.com',
        '/o/oauth2/v2/auth',
        loginUrlParameters,
      );

  @override
  List<String> get scopes => [
        'https://www.googleapis.com/auth/userinfo.profile',
        'https://www.googleapis.com/auth/userinfo.email',
      ];

  @override
  Map<String, String> get loginUrlParameters => {
        ...super.loginUrlParameters,
        'response_type': 'token id_token',
        'include_granted_scopes': 'true',
        'prompt': 'select_account',
        if (email != null) 'login_hint': email!,
      };
}
