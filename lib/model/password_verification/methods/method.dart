import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Allows to check if a given master password is valid.
abstract class PasswordVerificationMethod extends AutoDisposeAsyncNotifier<bool> {
  /// Verifies if the [password] is valid.
  Future<bool> verify(String password);

  /// Whether this method is 100% sure.
  bool get isSure => true;
}
