import 'dart:typed_data';

const _mask5 = 0x1F;
const _mask6 = 0x3F;
const _mask16 = 0xFFFF;
const _mask32 = 0xFFFFFFFF;

const _mask32HiBits = [
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

class Register64List {
  final List<Register64> _list;

  Register64List.from(List<List<int>> values) : _list = List<Register64>.generate(values.length, (i) => Register64(values[i][0], values[i][1]));

  Register64List(int length) : _list = List<Register64>.generate(length, (_) => Register64());

  int get length => _list.length;

  Register64 operator [](int index) => _list[index];

  void fillRange(int start, int end, dynamic hiOrLo32OrY, [int? lo32]) {
    for (var i = start; i < end; i++) {
      _list[i].set(hiOrLo32OrY, lo32);
    }
  }

  void setRange(int start, int end, Register64List list, [int skipCount = 0]) {
    var length = end - start;
    for (var i = 0; i < length; i++) {
      _list[start + i].set(list[skipCount + i]);
    }
  }

  @override
  String toString() {
    var sb = StringBuffer('(');
    for (var i = 0; i < _list.length; i++) {
      if (i > 0) {
        sb.write(', ');
      }
      sb.write(_list[i].toString());
    }
    sb.write(')');
    return sb.toString();
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// 64 bit operations
//
class Register64 {
  late int _hi32;
  late int _lo32;

  Register64([Object hiOrLo32OrY = 0, int? lo32]) {
    set(hiOrLo32OrY, lo32);
  }

  int get lo32 => _lo32;

  int get hi32 => _hi32;

  @override
  bool operator ==(Object other) => other is Register64 ? (((_hi32 == other._hi32) && (_lo32 == other._lo32))) : false;

  bool operator <(Register64 y) => (_hi32 < y._hi32) || ((_hi32 == y._hi32) && (_lo32 < y._lo32));

  bool operator <=(Register64 y) => (this < y) || (this == y);

  bool operator >(Register64 y) => (_hi32 > y._hi32) || ((_hi32 == y._hi32) && (_lo32 > y._lo32));

  bool operator >=(Register64 y) => (this > y) || (this == y);

  void set(dynamic hiOrLo32OrY, [int? lo32]) {
    if (lo32 == null) {
      if (hiOrLo32OrY is Register64) {
        _hi32 = hiOrLo32OrY._hi32;
        _lo32 = hiOrLo32OrY._lo32;
      } else {
        assert(hiOrLo32OrY as int <= _mask32);
        _hi32 = 0;
        _lo32 = hiOrLo32OrY as int;
      }
    } else {
      assert(hiOrLo32OrY as int <= _mask32);
      assert(lo32 <= _mask32);
      _hi32 = hiOrLo32OrY as int;
      _lo32 = lo32;
    }
  }

  void sum(dynamic y) {
    if (y is int) {
      y &= _mask32;
      var slo32 = _lo32 + y;
      _lo32 = slo32 & _mask32;
      if (slo32 != _lo32) {
        _hi32++;
        _hi32 &= _mask32;
      }
    } else {
      var slo32 = _lo32 + y._lo32 as int;
      _lo32 = slo32 & _mask32;
      var carry = ((slo32 != _lo32) ? 1 : 0);
      _hi32 = ((_hi32 + y._hi32 + carry) as int) & _mask32;
    }
  }

  void sumReg(Register64 y) {
    var slo32 = _lo32 + y._lo32;
    _lo32 = slo32 & _mask32;
    var carry = ((slo32 != _lo32) ? 1 : 0);
    _hi32 = (_hi32 + y._hi32 + carry) & _mask32;
  }

  void sub(dynamic y) {
    sum(Register64(y)..neg());
  }

  void mul(dynamic y) {
    // Grab 16-bit chunks.
    final a0 = _lo32 & _mask16;
    final a1 = (_lo32 >> 16) & _mask16;
    final a2 = _hi32 & _mask16;
    final a3 = (_hi32 >> 16) & _mask16;
    late int b0, b1, b2, b3;
    if (y is int) {
      // Assume it is a 32-bit integer.
      y &= _mask32;
      b0 = y & _mask16;
      b1 = (y >> 16) & _mask16;
      b2 = b3 = 0;
    } else /* if (y is Register64) */ {
      b0 = (y as Register64)._lo32 & _mask16;
      b1 = (y._lo32 >> 16) & _mask16;
      b2 = y._hi32 & _mask16;
      b3 = (y._hi32 >> 16) & _mask16;
    }

    // Compute partial products.
    // Optimization: if b is small, avoid multiplying by parts that are 0.
    var p0 = a0 * b0; // << 0
    var p1 = a1 * b0; // << 16
    var p2 = a2 * b0; // << 32
    var p3 = a3 * b0; // << 48

    if (b1 != 0) {
      p1 += a0 * b1;
      p2 += a1 * b1;
      p3 += a2 * b1;
    }
    if (b2 != 0) {
      p2 += a0 * b2;
      p3 += a1 * b2;
    }
    if (b3 != 0) {
      p3 += a0 * b3;
    }

    // Accumulate into 32-bit chunks:
    // |................................|................................|
    // |................................|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx| p0
    // |................................|................................|
    // |................................|................................|
    // |................xxxxxxxxxxxxxxxx|xxxxxxxxxxxxxxxx................| p1
    // |................................|................................|
    // |................................|................................|
    // |xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx|................................| p2
    // |................................|................................|
    // |................................|................................|
    // |xxxxxxxxxxxxxxxx................|................................| p3
    var slo32 = p0 + ((p1 & _mask16) << 16);
    _lo32 = slo32 & _mask32;
    var carry = ((slo32 != _lo32) ? 1 : 0);
    // p1 is a 33-bit integer, shiftr operation will ignore 33th-bit on js
    var carry2 = ((p1 & _mask32) != p1) ? 0x10000 : 0;
    var shi32 = ((p1 & _mask32) >> 16) + p2 + ((p3 & _mask16) << 16) + carry + carry2;
    _hi32 = shi32 & _mask32;
  }

  void neg() {
    not();
    sum(1);
  }

  void not() {
    _hi32 = ~_hi32 & _mask32;
    _lo32 = ~_lo32 & _mask32;
  }

  void and(Register64 y) {
    _hi32 &= y._hi32;
    _lo32 &= y._lo32;
  }

  void or(Register64 y) {
    _hi32 |= y._hi32;
    _lo32 |= y._lo32;
  }

  void xor(Register64 y) {
    _hi32 ^= y._hi32;
    _lo32 ^= y._lo32;
  }

  void shiftl(int n) {
    n &= _mask6;
    if (n == 0) {
      // do nothing
    } else if (n >= 32) {
      _hi32 = shiftl32(_lo32, n - 32);
      _lo32 = 0;
    } else {
      _hi32 = shiftl32(_hi32, n);
      _hi32 |= _lo32 >> (32 - n);
      _lo32 = shiftl32(_lo32, n);
    }
  }

  void shiftr(int n) {
    n &= _mask6;
    if (n == 0) {
      // do nothing
    } else if (n >= 32) {
      _lo32 = _hi32 >> (n - 32);
      _hi32 = 0;
    } else {
      _lo32 = _lo32 >> n;
      _lo32 |= shiftl32(_hi32, 32 - n);
      _hi32 = _hi32 >> n;
    }
  }

  void rotl(int n) {
    n &= _mask6;
    if (n == 0) {
      // do nothing
    } else {
      if (n >= 32) {
        var swap = _hi32;
        _hi32 = _lo32;
        _lo32 = swap;
        n -= 32;
      }
      if (n == 0) {
        // do nothing
      } else {
        var hi32 = _hi32;
        _hi32 = shiftl32(_hi32, n);
        _hi32 |= _lo32 >> (32 - n);
        _lo32 = shiftl32(_lo32, n);
        _lo32 |= hi32 >> (32 - n);
      }
    }
  }

  void rotr(int n) {
    n &= _mask6;
    if (n == 0) {
      // do nothing
    } else {
      if (n >= 32) {
        var swap = _hi32;
        _hi32 = _lo32;
        _lo32 = swap;
        n -= 32;
      }
      if (n == 0) {
        // do nothing
      } else {
        var hi32 = _hi32;
        _hi32 = _hi32 >> n;
        _hi32 |= shiftl32(_lo32, 32 - n);
        _lo32 = _lo32 >> n;
        _lo32 |= shiftl32(hi32, 32 - n);
      }
    }
  }

  void mod(int n) {
    if (_hi32 == 0) {
      // hi32 is zero, so just caculate lo32.
      _lo32 %= n;
    } else {
      // hi32 is not zero, use Horner's Method
      const b = 0x10000;
      final a0 = _lo32 & _mask16;
      final a1 = (_lo32 >> 16) & _mask16;
      final a2 = _hi32 & _mask16;
      final a3 = (_hi32 >> 16) & _mask16;
      _lo32 = ((((((a3 % n) * b + a2) % n) * b + a1) % n) * b + a0) % n;
      // Assume that n is a 32-bit integer, so hi32 will always be zero
      _hi32 = 0;
    }
  }

  /// Packs a 64 bit integer into a byte buffer. The [out] parameter can be an [Uint8List] or a
  /// [ByteData] if you will run it several times against the same buffer and want faster execution.
  void pack(dynamic out, int offset, Endian endian) {
    switch (endian) {
      case Endian.big:
        pack32(hi32, out, offset, endian);
        pack32(lo32, out, offset + 4, endian);
        break;

      case Endian.little:
        pack32(hi32, out, offset + 4, endian);
        pack32(lo32, out, offset, endian);
        break;

      default:
        throw UnsupportedError('Invalid endianness: $endian');
    }
  }

  /// Unpacks a 64 bit integer from a byte buffer. The [inp] parameter can be an [Uint8List] or a
  /// [ByteData] if you will run it several times against the same buffer and want faster execution.
  void unpack(dynamic inp, int offset, Endian endian) {
    switch (endian) {
      case Endian.big:
        _hi32 = unpack32(inp, offset, endian);
        _lo32 = unpack32(inp, offset + 4, endian);
        break;

      case Endian.little:
        _hi32 = unpack32(inp, offset + 4, endian);
        _lo32 = unpack32(inp, offset, endian);
        break;

      default:
        throw UnsupportedError('Invalid endianness: $endian');
    }
  }

  @override
  String toString() {
    var sb = StringBuffer();
    _padWrite(sb, _hi32);
    _padWrite(sb, _lo32);
    return sb.toString();
  }

  void _padWrite(StringBuffer sb, int value) {
    var str = value.toRadixString(16);
    for (var i = 8 - str.length; i > 0; i--) {
      sb.write('0');
    }
    sb.write(str);
  }

  @override
  int get hashCode => Object.hash(_hi32, _lo32);
}

/// Packs a 32 bit integer into a byte buffer. The [out] parameter can be an [Uint8List] or a
/// [ByteData] if you will run it several times against the same buffer and want faster execution.
void pack32(int x, dynamic out, int offset, Endian endian) {
  assert((x >= 0) && (x <= _mask32));
  if (out is! ByteData) {
    out = ByteData.view(out.buffer as ByteBuffer, out.offsetInBytes, out.length);
  }
  out.setUint32(offset, x, endian);
}

/// Unpacks a 32 bit integer from a byte buffer. The [inp] parameter can be an [Uint8List] or a
/// [ByteData] if you will run it several times against the same buffer and want faster execution.
int unpack32(dynamic inp, int offset, Endian endian) {
  if (inp is! ByteData) {
    inp = ByteData.view(inp.buffer, inp.offsetInBytes, inp.length);
  }
  return inp.getUint32(offset, endian);
}

int shiftl32(int x, int n) {
  assert((x >= 0) && (x <= _mask32));
  n &= _mask5;
  x &= _mask32HiBits[n];
  return (x << n) & _mask32;
}
