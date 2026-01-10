part of 'provider.dart';

final githubAuthenticationProvider = Provider<GithubAuthenticationProvider>(
  (ref) => GithubAuthenticationProvider._(
    ref: ref,
  ),
);

class GithubAuthenticationProvider extends AuthenticationProvider with OAuthenticationProvider {
  static const String kProviderId = 'github';

  const GithubAuthenticationProvider._({
    required super.ref,
  }) : super(
         id: kProviderId,
       );

  @override
  User _changeId(User user, String providerUserId) => user.copyWith(githubId: providerUserId);
}
