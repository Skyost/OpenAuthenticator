import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/password_verification/methods/crypto_store.dart';
import 'package:open_authenticator/model/password_verification/methods/method.dart';
import 'package:open_authenticator/model/password_verification/methods/password_signature.dart';
import 'package:open_authenticator/utils/result.dart';

/// The provider instance.
final passwordVerificationProvider = AsyncNotifierProvider.autoDispose<PasswordVerification, List<PasswordVerificationMethod>>(PasswordVerification.new);

/// Allows to check whether a given password is the user's master password.
class PasswordVerification extends AutoDisposeAsyncNotifier<List<PasswordVerificationMethod>> {
  @override
  FutureOr<List<PasswordVerificationMethod>> build() async => [
        for (AutoDisposeAsyncNotifierProvider<PasswordVerificationMethod, bool> provider in [
          cryptoStoreVerificationMethodProvider,
          passwordSignatureVerificationMethodProvider,
        ])
          if (await ref.watch(provider.future)) ref.read(provider.notifier),
      ];

  /// Returns whether the given password is the user's master password.
  Future<Result<bool>> isPasswordValid(String password) async {
    try {
      int verificationCount = 0;
      List<PasswordVerificationMethod> verificationMethods = await future;
      for (PasswordVerificationMethod verificationMethod in verificationMethods) {
        if (await verificationMethod.verify(password)) {
          verificationCount++;
          if (verificationMethod.isSure) {
            return const ResultSuccess(value: true);
          }
        } else {
          return const ResultSuccess(value: false);
        }
      }
      return ResultSuccess(value: verificationCount == verificationMethods.length);
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }
}
