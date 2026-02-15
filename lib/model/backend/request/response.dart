import 'package:open_authenticator/model/backend/synchronization/push/result.dart';
import 'package:open_authenticator/model/backend/user.dart';
import 'package:open_authenticator/model/totp/json.dart';
import 'package:open_authenticator/model/totp/totp.dart';

abstract class BackendResponse {
  const BackendResponse();
}

class GetUserInfoResponse extends BackendResponse {
  final User user;

  const GetUserInfoResponse({
    required this.user,
  });

  GetUserInfoResponse.fromJson(Map<String, dynamic> json)
    : this(
        user: User.fromJson(json),
      );
}

class DeleteUserResponse extends BackendResponse {
  const DeleteUserResponse();

  DeleteUserResponse.fromJson(Map<String, dynamic> json) : this();
}

class GetUserTotpsResponse extends BackendResponse {
  final List<Totp> totps;

  const GetUserTotpsResponse({
    this.totps = const [],
  });

  GetUserTotpsResponse.fromJson(Map<String, dynamic> json)
    : this(
        totps: [
          for (String uuid in json.keys)
            JsonTotp.fromJson(
              json[uuid],
              uuid: uuid,
            ),
        ],
      );
}

class RefreshTokenResponse extends BackendResponse {
  final String accessToken;
  final String refreshToken;

  const RefreshTokenResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  RefreshTokenResponse.fromJson(Map<String, dynamic> json)
    : this(
        accessToken: json['accessToken'],
        refreshToken: json['refreshToken'],
      );
}

class UserLogoutResponse extends BackendResponse {
  const UserLogoutResponse();

  UserLogoutResponse.fromJson(Map<String, dynamic> json) : this();
}

class EmailConfirmResponse extends BackendResponse {
  final Uri url;

  const EmailConfirmResponse({
    required this.url,
  });

  EmailConfirmResponse.fromJson(String json)
    : this(
        url: Uri.parse(json),
      );
}

class ProviderLoginResponse extends BackendResponse {
  final String accessToken;
  final String refreshToken;

  const ProviderLoginResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  ProviderLoginResponse.fromJson(Map<String, dynamic> json)
    : this(
        accessToken: json['accessToken'],
        refreshToken: json['refreshToken'],
      );
}

class EmailCancelResponse extends BackendResponse {
  const EmailCancelResponse();

  EmailCancelResponse.fromJson(Map<String, dynamic> json) : this();
}

class ProviderLinkResponse extends BackendResponse {
  final String userId;
  final String providerUserId;

  const ProviderLinkResponse({
    required this.userId,
    required this.providerUserId,
  });

  ProviderLinkResponse.fromJson(Map<String, dynamic> json)
    : this(
        userId: json['userId'],
        providerUserId: json['providerUserId'],
      );
}

class ProviderUnlinkResponse extends BackendResponse {
  const ProviderUnlinkResponse();

  ProviderUnlinkResponse.fromJson(Map<String, dynamic> json) : this();
}

class SynchronizationPushResponse extends BackendResponse {
  final List<PushOperationResult> result;

  const SynchronizationPushResponse({
    this.result = const [],
  });

  SynchronizationPushResponse.fromJson(List json)
    : this(
        result: json.map((json) => PushOperationResult.fromJson(json)).toList(),
      );
}

class SynchronizationPullResponse extends BackendResponse {
  final List<Totp> inserts;
  final List<Totp> updates;
  final List<String> deletes;

  const SynchronizationPullResponse({
    this.inserts = const [],
    this.updates = const [],
    this.deletes = const [],
  });

  SynchronizationPullResponse.fromJson(Map<String, dynamic> json)
    : this(
        inserts: _totpListFromJson(json['inserts']),
        updates: _totpListFromJson(json['updates']),
        deletes: (json['deletes'] as List).cast<String>(),
      );

  static List<Totp> _totpListFromJson(Map json) => [
    for (String uuid in json.keys)
      JsonTotp.fromJson(
        json[uuid],
        uuid: uuid,
      ),
  ];
}
