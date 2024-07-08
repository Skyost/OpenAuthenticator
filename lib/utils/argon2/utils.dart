import 'dart:typed_data';

import 'package:open_authenticator/utils/argon2/extension.dart';

abstract class Pack {
  static int littleEndianToLong(Uint8List bs, int off) {
    var data = bs.asByteData;
    return data.getInt64(off, Endian.little);
  }

  static void littleEndianToLongAtList(Uint8List bs, int off, Uint64List ns) {
    for (var i = 0; i < ns.length; ++i) {
      ns[i] = littleEndianToLong(bs, off);
      off += 8;
    }
  }

  static Uint8List longToLittleEndianList(int n) {
    var bs = Uint8List(8);
    longToLittleEndianAtList(n, bs, 0);
    return bs;
  }

  static void longToLittleEndianAtList(int n, Uint8List bs, int off) {
    var data = bs.asByteData;
    data.setInt64(off, n, Endian.little);
  }

  static Uint8List longListToLittleEndianList(Uint64List ns) {
    var bs = Uint8List(8 * ns.length);
    longListToLittleEndianAtList(ns, bs, 0);
    return bs;
  }

  static void longListToLittleEndianAtList(
      Uint64List ns, Uint8List bs, int off) {
    for (var i = 0; i < ns.length; ++i) {
      longToLittleEndianAtList(ns[i], bs, off);
      off += 8;
    }
  }

  static int littleEndianToInt(Uint8List bs, int off) {
    var data = bs.asByteData;
    return data.getInt32(off, Endian.little);
  }

  static Uint8List intToLittleEndianList(int n) {
    var bs = Uint8List(4);
    intToLittleEndianAtList(n, bs, 0);
    return bs;
  }

  static void intToLittleEndianAtList(int n, Uint8List bs, int off) {
    var data = bs.asByteData;
    data.setInt32(off, n, Endian.little);
  }

  static Uint8List intListToLittleEndian(Uint32List ns) {
    var bs = Uint8List(4 * ns.length);
    intListToLittleEndianAtList(ns, bs, 0);
    return bs;
  }

  static void intListToLittleEndianAtList(
      Uint32List ns, Uint8List bs, int off) {
    for (var i = 0; i < ns.length; ++i) {
      intToLittleEndianAtList(ns[i], bs, off);
      off += 4;
    }
  }
}

abstract class Longs {
  static const _mask32 = 0xFFFFFFFF;

  static const _mask32HiBits = <int>[
    0xFFFFFFFF,
    0x7FFFFFFF,
    0x3FFFFFFF,
    0x1FFFFFFF,
    0x0FFFFFFF,
    0x07FFFFFF,
    0x03FFFFFF,
    0x01FFFFFF,
    0x00FFFFFF,
    0x007FFFFF,
    0x003FFFFF,
    0x001FFFFF,
    0x000FFFFF,
    0x0007FFFF,
    0x0003FFFF,
    0x0001FFFF,
    0x0000FFFF,
    0x00007FFF,
    0x00003FFF,
    0x00001FFF,
    0x00000FFF,
    0x000007FF,
    0x000003FF,
    0x000001FF,
    0x000000FF,
    0x0000007F,
    0x0000003F,
    0x0000001F,
    0x0000000F,
    0x00000007,
    0x00000003,
    0x00000001,
    0x00000000
  ];

  static int rotateRight(int n, int distance) {
    if (distance == 0) {
      // do nothing:
      return n;
    }

    var hi32 = (n >> 32) & 0xFFFFFFFF;
    var lo32 = (n) & 0xFFFFFFFF;

    if (distance >= 32) {
      var swap = hi32;
      hi32 = lo32;
      lo32 = swap;
      distance -= 32;

      if (distance == 0) {
        return (hi32 << 32) | lo32;
      }
    }

    final distance32 = (32 - distance);
    final m = _mask32HiBits[distance32];

    final hi32cp = hi32;

    hi32 = hi32 >> distance;
    hi32 |= (((lo32 & m) << distance32) & _mask32);

    lo32 = lo32 >> distance;
    lo32 |= (((hi32cp & m) << distance32) & _mask32);

    return (hi32 << 32) | lo32;
  }

  static int toInt32(int n) => (n & 0xFFFFFFFF);
}
