part of 'provider.dart';

final appleAuthenticationProvider = Provider<AppleAuthenticationProvider>(
  (ref) => AppleAuthenticationProvider._(
    ref: ref,
  ),
);

class AppleAuthenticationProvider extends AuthenticationProvider with OAuthenticationProvider {
  static const String kProviderId = 'apple';

  const AppleAuthenticationProvider._({
    required super.ref,
  }) : super(
         id: kProviderId,
       );

  @override
  User _changeId(User user, String providerUserId) => user.copyWith(appleId: providerUserId);
}
