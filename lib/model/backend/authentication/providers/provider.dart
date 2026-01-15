import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/model/backend/authentication/session.dart';
import 'package:open_authenticator/model/backend/backend.dart';
import 'package:open_authenticator/model/backend/request/request.dart';
import 'package:open_authenticator/model/backend/request/response.dart';
import 'package:open_authenticator/model/backend/user.dart';
import 'package:open_authenticator/model/settings/entry.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/utils/shared_preferences_with_prefix.dart';
import 'package:open_authenticator/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

part 'apple.dart';
part 'email.dart';
part 'github.dart';
part 'google.dart';
part 'microsoft.dart';

final authenticationProvider = Provider.family<AuthenticationProvider?, String>(
  (ref, id) => ref.watch(
    authenticationProviders.select(
      (providers) => providers.firstWhereOrNull(
        (provider) => provider.id == id,
      ),
    ),
  ),
);

final authenticationProviders = Provider<List<AuthenticationProvider>>(
  (ref) => List.unmodifiable([
    ref.watch(emailAuthenticationProvider),
    ref.watch(googleAuthenticationProvider),
    ref.watch(githubAuthenticationProvider),
    ref.watch(microsoftAuthenticationProvider),
    ref.watch(appleAuthenticationProvider),
  ]),
);

final userAuthenticationProviders = Provider<List<AuthenticationProvider>>((ref) {
  User? user = ref.watch(userProvider).value;
  if (user == null) {
    return [];
  }
  List<AuthenticationProvider> providers = ref.watch(authenticationProviders);
  return List.unmodifiable([
    for (AuthenticationProvider provider in providers)
      if (user.hasAuthenticationProvider(provider.id)) provider,
  ]);
});

sealed class AuthenticationProvider {
  final String id;
  final Ref _ref;

  const AuthenticationProvider({
    required this.id,
    required Ref ref,
  }) : _ref = ref;

  User _changeId(User user, String providerUserId);

  Future<Result> unlink() async {
    try {
      User? user = await _ref.read(userProvider.future);
      if (user == null) {
        return const ResultCancelled();
      }
      return await _ref
          .read(backendProvider.notifier)
          .sendHttpRequest(
            ProviderUnlinkRequest(
              provider: this,
            ),
          );
    } catch (ex, stackTrace) {
      return ResultError(
        exception: ex,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Result> onRedirectReceived(Uri uri) async {
    try {
      List<String> path = uri.pathSegments;
      if (path.lastOrNull != 'code') {
        return const ResultCancelled();
      }
      String? authorizationCode = uri.queryParameters['authorizationCode'];
      if (authorizationCode == null) {
        return const ResultCancelled();
      }
      User? user = await _ref.read(userProvider.future);
      if (user == null) {
        Result<ProviderLoginResponse> response = await _ref
            .read(backendProvider.notifier)
            .sendHttpRequest(
              ProviderLoginRequest(
                provider: this,
                authorizationCode: authorizationCode,
                codeVerifier: uri.queryParameters['codeVerifier'],
              ),
            );
        if (response is! ResultSuccess<ProviderLoginResponse>) {
          return response;
        }
        await _ref
            .read(storedSessionProvider.notifier)
            .storeAndUse(
              Session(
                accessToken: response.value.accessToken,
                refreshToken: response.value.refreshToken,
              ),
            );
      } else {
        Result<ProviderLinkResponse> response = await _ref
            .read(backendProvider.notifier)
            .sendHttpRequest(
              ProviderLinkRequest(
                provider: this,
                authorizationCode: authorizationCode,
                codeVerifier: uri.queryParameters['codeVerifier'],
              ),
            );
        if (response is! ResultSuccess<ProviderLinkResponse>) {
          return response;
        }
        await _ref.read(userProvider.notifier).changeUser(_changeId(user, response.value.providerUserId));
      }
      return const ResultSuccess();
    } catch (ex, stackTrace) {
      return ResultError(
        exception: ex,
        stackTrace: stackTrace,
      );
    }
  }
}

mixin OAuthenticationProvider on AuthenticationProvider {
  Future<Result> requestSignIn() => _requestLogin(link: false);

  Future<Result> requestLinking() => _requestLogin(link: true);

  Future<Result> _requestLogin({bool link = false}) async {
    await launchUrl(Uri.parse('${App.backendUrl}/auth/provider/$id/redirect?mode=${link ? 'link' : 'login'}'));
    return const ResultSuccess();
  }
}
