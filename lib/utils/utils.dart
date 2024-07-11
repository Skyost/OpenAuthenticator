import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hashlib_codecs/hashlib_codecs.dart';

/// Contains some useful iterable methods.
extension IterableUtils<T> on Iterable<T> {
  /// Returns the first element satisfying [test], or `null` if there are none.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

/// Returns whether a given [string] is a valid base 32 string.
bool isValidBase32(String string) {
  try {
    fromBase32(string);
    return true;
  } catch (_) {}
  return false;
}

/// Handles an exception.
void handleException(Object? ex, StackTrace? stacktrace) {
  if (kDebugMode) {
    print(ex);
    print(stacktrace);
  }
}

/// Generates a random string.
String generateRandomString([int length = 20]) {
  String chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random random = Random();
  return String.fromCharCodes(Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
}

/// Compares two [Uint8List]s by comparing 8 bytes at a time.
/// Kudos to https://stackoverflow.com/a/70751501/3608831.
bool memEquals(Uint8List bytes1, Uint8List bytes2) {
  if (identical(bytes1, bytes2)) {
    return true;
  }

  if (bytes1.lengthInBytes != bytes2.lengthInBytes) {
    return false;
  }

  // Treat the original byte lists as lists of 8-byte words.
  var numWords = bytes1.lengthInBytes ~/ 8;
  var words1 = bytes1.buffer.asUint64List(0, numWords);
  var words2 = bytes2.buffer.asUint64List(0, numWords);

  for (var i = 0; i < words1.length; i += 1) {
    if (words1[i] != words2[i]) {
      return false;
    }
  }

  // Compare any remaining bytes.
  for (var i = words1.lengthInBytes; i < bytes1.lengthInBytes; i += 1) {
    if (bytes1[i] != bytes2[i]) {
      return false;
    }
  }

  return true;
}
