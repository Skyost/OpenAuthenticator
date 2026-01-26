part of 'provider.dart';

final emailAuthenticationProvider = Provider<EmailAuthenticationProvider>(
  (ref) => EmailAuthenticationProvider._(
    ref: ref,
  ),
);

class EmailAuthenticationProvider extends AuthenticationProvider {
  static const String kProviderId = 'email';

  const EmailAuthenticationProvider._({
    required super.ref,
  }) : super(
         id: kProviderId,
       );

  @override
  Future<Result> onRedirectReceived(Uri uri) async {
    if (uri.host == 'auth' && uri.path == '/provider/email/sent') {
      _ref.read(emailConfirmationStateProvider.notifier)._markNeedsConfirmation(uri.queryParameters['email']!, uri.queryParameters['cancelCode']!);
      return const ResultSuccess();
    }
    Result result = await super.onRedirectReceived(uri);
    if (result is ResultSuccess) {
      await _ref.read(emailConfirmationStateProvider.notifier)._cancelConfirmation();
    }
    return result;
  }

  Future<Result> requestSignIn(String email) => _requestLogin(email, link: false);

  Future<Result> requestLinking(String email) => _requestLogin(email, link: true);

  Future<Result> _requestLogin(String email, {bool link = false}) async {
    String backendUrl = await _ref.read(backendUrlSettingsEntryProvider.future);
    await launchUrl(Uri.parse('$backendUrl/auth/provider/$id/redirect?email=$email&mode=${link ? 'link' : 'login'}'));
    return const ResultSuccess();
  }

  Future<Result> confirm(String code) async {
    try {
      EmailConfirmationData? data = await _ref.read(emailConfirmationStateProvider.future);
      if (data == null) {
        throw Exception('No email to confirm.');
      }
      Result<EmailConfirmResponse> response = await _ref
          .read(backendProvider.notifier)
          .sendHttpRequest(
            EmailConfirmRequest(
              email: data.email,
              code: code,
            ),
          );
      if (response is! ResultSuccess<EmailConfirmResponse>) {
        return response;
      }
      Uri uri = response.value.url;
      return await onRedirectReceived(uri);
    } catch (ex, stackTrace) {
      return ResultError(
        exception: ex,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Result> cancelConfirmation() async {
    try {
      EmailConfirmationData? data = await _ref.read(emailConfirmationStateProvider.future);
      if (data == null) {
        return const ResultSuccess();
      }
      Result<EmailCancelResponse> response = await _ref
          .read(backendProvider.notifier)
          .sendHttpRequest(
            EmailCancelRequest(
              email: data.email,
              cancelCode: data.cancelCode,
            ),
          );
      if (response is! ResultSuccess<EmailCancelResponse>) {
        return response;
      }
      await _ref.read(emailConfirmationStateProvider.notifier)._cancelConfirmation();
      return const ResultSuccess();
    } catch (ex, stackTrace) {
      return ResultError(
        exception: ex,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  User _changeId(User user, String providerUserId) => user.copyWith(email: providerUserId);
}

/// The email confirmation state provider.
final emailConfirmationStateProvider = AsyncNotifierProvider<EmailConfirmationStateNotifier, EmailConfirmationData?>(EmailConfirmationStateNotifier.new);

/// The email confirmation state notifier.
class EmailConfirmationStateNotifier extends AsyncNotifier<EmailConfirmationData?> {
  /// The preferences key where the email is temporally stored.
  static const String _kAuthenticationEmailKey = 'authenticationEmail';

  /// The preferences key where the cancel code is temporally stored.
  static const String _kAuthenticationEmailCancelCodeKey = 'authenticationEmailCancelCode';

  @override
  FutureOr<EmailConfirmationData?> build() async {
    SharedPreferencesWithPrefix preferences = await ref.read(sharedPreferencesProvider.future);
    String? email = preferences.getString(_kAuthenticationEmailKey);
    String? cancelCode = preferences.getString(_kAuthenticationEmailCancelCodeKey);
    return email == null || cancelCode == null
        ? null
        : EmailConfirmationData(
            email: email,
            cancelCode: cancelCode,
          );
  }

  /// Marks the [email] for confirmation with the given cancel code.
  Future<void> _markNeedsConfirmation(String email, String cancelCode) async {
    if ((await future) != null) {
      return;
    }
    SharedPreferencesWithPrefix preferences = await ref.read(sharedPreferencesProvider.future);
    await preferences.setString(_kAuthenticationEmailKey, email);
    await preferences.setString(_kAuthenticationEmailCancelCodeKey, cancelCode);
    state = AsyncData(
      EmailConfirmationData(
        email: email,
        cancelCode: cancelCode,
      ),
    );
  }

  /// Cancels the confirmation.
  Future<void> _cancelConfirmation() async {
    SharedPreferencesWithPrefix preferences = await ref.read(sharedPreferencesProvider.future);
    await preferences.remove(_kAuthenticationEmailKey);
    await preferences.remove(_kAuthenticationEmailCancelCodeKey);
    state = const AsyncData(null);
  }
}

class EmailConfirmationData with EquatableMixin {
  final String email;
  final String cancelCode;

  const EmailConfirmationData({
    required this.email,
    required this.cancelCode,
  });

  @override
  List<Object?> get props => [
    email,
    cancelCode,
  ];
}
