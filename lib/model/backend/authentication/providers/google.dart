part of 'provider.dart';

final googleAuthenticationProvider = Provider<GoogleAuthenticationProvider>(
  (ref) => GoogleAuthenticationProvider._(
    ref: ref,
  ),
);

class GoogleAuthenticationProvider extends AuthenticationProvider with OAuthenticationProvider {
  static const String kProviderId = 'google';

  const GoogleAuthenticationProvider._({
    required super.ref,
  }) : super(
         id: kProviderId,
       );

  @override
  User _changeId(User user, String providerUserId) => user.copyWith(googleId: providerUserId);
}
