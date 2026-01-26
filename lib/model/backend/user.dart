import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/backend/authentication/providers/provider.dart';
import 'package:open_authenticator/model/backend/authentication/session.dart';
import 'package:open_authenticator/model/backend/backend.dart';
import 'package:open_authenticator/model/backend/request/request.dart';
import 'package:open_authenticator/model/backend/request/response.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:path_provider/path_provider.dart';

class User {
  final String id;
  final int totpsLimit;
  final String? email;
  final String? googleId;
  final String? githubId;
  final String? microsoftId;
  final String? appleId;

  const User._({
    required this.id,
    required this.totpsLimit,
    this.email,
    this.googleId,
    this.githubId,
    this.microsoftId,
    this.appleId,
  });

  User.fromJson(Map<String, dynamic> json)
    : this._(
        id: json['id'],
        totpsLimit: json['totpsLimit'],
        email: json['email'],
        googleId: json['googleId'],
        githubId: json['githubId'],
        microsoftId: json['microsoftId'],
      );

  bool hasAuthenticationProvider(String providerId) => switch (providerId) {
    EmailAuthenticationProvider.kProviderId => email != null,
    GoogleAuthenticationProvider.kProviderId => googleId != null,
    GithubAuthenticationProvider.kProviderId => githubId != null,
    MicrosoftAuthenticationProvider.kProviderId => microsoftId != null,
    AppleAuthenticationProvider.kProviderId => appleId != null,
    _ => false,
  };

  static Future<File> _getFile({bool create = false}) async {
    Directory directory = await getApplicationSupportDirectory();
    File file = File('${directory.path}/user.json');
    if (create && !file.existsSync()) {
      file.createSync();
    }
    return file;
  }

  static Future<User?> _readFromCache() async {
    File file = await _getFile();
    if (!file.existsSync()) {
      return null;
    }
    String content = await file.readAsString();
    Map<String, dynamic> json = jsonDecode(content);
    return json['id'] == null ? null : User.fromJson(json);
  }

  Future<void> _saveToCache() async {
    File file = await _getFile(create: true);
    await file.writeAsString(jsonEncode(toJson()));
  }

  User copyWith({
    int? totpsLimit,
    String? email,
    String? googleId,
    String? githubId,
    String? microsoftId,
    String? appleId,
  }) => User._(
    id: id,
    totpsLimit: totpsLimit ?? this.totpsLimit,
    email: email ?? this.email,
    googleId: googleId ?? this.googleId,
    githubId: githubId ?? this.githubId,
    microsoftId: microsoftId ?? this.microsoftId,
    appleId: appleId ?? this.appleId,
  );

  Map<String, String> toJson() => {
    'id': id,
    'totpsLimit': totpsLimit.toString(),
    if (email != null) 'email': email!,
    if (googleId != null) 'googleId': googleId!,
    if (githubId != null) 'githubId': githubId!,
    if (microsoftId != null) 'microsoftId': microsoftId!,
    if (appleId != null) 'appleId': appleId!,
  };
}

final userProvider = AsyncNotifierProvider<UserNotifier, User?>(UserNotifier.new);

class UserNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    Session? session = await ref.watch(storedSessionProvider.future);
    if (session == null) {
      return null;
    }
    User? user = await User._readFromCache();
    refreshUserInfo();
    return user;
  }

  Future<Result> refreshUserInfo() async {
    Result<GetUserInfoResponse> result = await ref
        .read(backendProvider.notifier)
        .sendHttpRequest(
          const GetUserInfoRequest(),
          retries: 1,
        );
    if (result is! ResultSuccess<GetUserInfoResponse>) {
      return result;
    }
    await changeUser(result.value.user);
    return const ResultSuccess();
  }

  Future<void> changeUser(User user) async {
    await user._saveToCache();
    state = AsyncData(user);
  }

  Future<Result> logoutUser() async {
    try {
      Session? session = await ref.read(storedSessionProvider.future);
      if (session == null) {
        return const ResultSuccess();
      }
      Result<UserLogoutResponse> result = await ref
          .read(backendProvider.notifier)
          .sendHttpRequest(
            UserLogoutRequest(
              refreshToken: session.refreshToken,
            ),
          );
      if (result is! ResultSuccess<UserLogoutResponse>) {
        return result;
      }
      await ref.read(storedSessionProvider.notifier).clear();
      return const ResultSuccess();
    } catch (ex, stackTrace) {
      return ResultError(
        exception: ex,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Result> deleteUser() async {
    try {
      Result<DeleteUserResponse> result = await ref
          .read(backendProvider.notifier)
          .sendHttpRequest(
        const DeleteUserRequest(),
      );
      await ref.read(storedSessionProvider.notifier).clear();
      return result;
    } catch (ex, stackTrace) {
      return ResultError<DeleteUserResponse>(
        exception: ex,
        stackTrace: stackTrace,
      );
    }
  }
}
