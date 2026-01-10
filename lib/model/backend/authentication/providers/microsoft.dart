part of 'provider.dart';

final microsoftAuthenticationProvider = Provider<MicrosoftAuthenticationProvider>(
  (ref) => MicrosoftAuthenticationProvider._(
    ref: ref,
  ),
);

class MicrosoftAuthenticationProvider extends AuthenticationProvider with OAuthenticationProvider {
  static const String kProviderId = 'microsoft';

  const MicrosoftAuthenticationProvider._({
    required super.ref,
  }) : super(
         id: kProviderId,
       );

  @override
  User _changeId(User user, String providerUserId) => user.copyWith(microsoftId: providerUserId);
}
