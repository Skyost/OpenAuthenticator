import 'dart:convert';
import 'dart:typed_data';

import 'package:open_authenticator/utils/argon2/platform.dart';

final bool _isNative = Argon2Platform.instance.isNative;

extension ListExtension<T> on List<T> {
  List<T> copy() => List<T>.from(this);

  void setFrom(int startIndex, List<T> from, int fromIndex, int length) {
    for (var i = 0; i < length; ++i) {
      this[startIndex + i] = from[fromIndex + i];
    }
  }
}

extension ListIntExtension on List<int> {
  Uint8List copy() => Uint8List.fromList(this);

  Uint8List toUint8List() => this is Uint8List ? this as Uint8List : Uint8List.fromList(this);

  void clear() => setAllElementsTo(0);

  void setAllElementsTo(int value) {
    for (var i = length - 1; i >= 0; --i) {
      this[i] = value;
    }
  }
}

extension StringExtension on String {
  Uint8List toBytesUTF8() => utf8.encode(this).toUint8List();

  Uint8List toBytesLatin1() => latin1.encode(this);
}

extension Uint8ListExtension on Uint8List {
  ByteData get asByteData => ByteData.view(buffer);

  void reset() => setAllElementsTo(0);

  String toHexString() {
    StringBuffer buffer = StringBuffer();
    for (int part in this) {
      if (part & 0xff != part) {
        throw FormatException("Non-byte integer detected");
      }
      buffer.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
    }
    return buffer.toString();
  }
}

extension IntExtension on int {
  int tripleShift32(int count) {
    if (_isNative) {
      return (this >> count) & ~(-1 << (32 - count));
    } else {
      // assumes this > -(2^32 -1)
      count &= 0x1f;
      if (this >= 0) {
        return (this >> count);
      } else {
        return (this >> count) ^ ((0xFFFFFFFF) ^ ((1 << (32 - count)) - 1));
      }
    }
  }

  int tripleShift64(int count) {
    if (_isNative) {
      return (this >> count) & ~(-1 << (64 - count));
    } else {
      count &= 0x1f;
      if (this >= 0) {
        return (this >> count);
      } else {
        return (this >> count) ^ ((0xFFFFFFFFFFFFFFFF) ^ ((1 << (64 - count)) - 1));
      }
    }
  }
}
