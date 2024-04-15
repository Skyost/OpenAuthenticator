import 'dart:typed_data';

import 'package:open_authenticator/utils/argon2/blake2/blake2b.dart';
import 'package:open_authenticator/utils/argon2/blake2/digest.dart';
import 'package:open_authenticator/utils/argon2/extension.dart';
import 'package:open_authenticator/utils/argon2/parameters.dart';
import 'package:open_authenticator/utils/argon2/utils.dart';

/// Argon2 PBKDF.
///
/// Based on the results of:
/// - https://password-hashing.net/
/// - https://www.ietf.org/archive/id/draft-irtf-cfrg-argon2-03.txt
///
/// Converted to Dart from:
/// - https://github.com/bcgit/bc-java/blob/master/core/src/main/java/org/bouncycastle/crypto/generators/Argon2BytesGenerator.java
///
/// LICENSE (MIT):
/// ```text
/// Copyright (c) 2000-2021 The Legion of the Bouncy Castle Inc. (https://www.bouncycastle.org)
/// <p>
/// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
/// and associated documentation files (the "Software"), to deal in the Software without restriction,
/// including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
/// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
/// subject to the following conditions:
/// <p>
/// The above copyright notice and this permission notice shall be included in all copies or substantial
/// portions of the Software.
/// <p>
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
/// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
/// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
/// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
/// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
/// DEALINGS IN THE SOFTWARE.
/// ```
///
class Argon2BytesGenerator {
  static const int argon2BlockSize = 1024;
  static const int argon2QwordsInBlock = argon2BlockSize ~/ 8;

  static const int argon2AddressesInBlock = 128;

  static const int argon2PrehashDigestLength = 64;
  static const int argon2PrehashSeedLength = 72;

  static const int argon2SyncPoints = 4;

  /// Minimum and maximum number of lanes (degree of parallelism).
  static const int minParallelism = 1;
  static const int maxParallelism = 16777216;

  /// Minimum and maximum digest size in bytes.
  static const int minOutLen = 4;

  /// Minimum and maximum number of passes.
  static const int minIterations = 1;

  static const int m32L = 0xFFFFFFFFFFFFFFFF;

  static final Uint8List _zeroBytes = Uint8List(4);

  late Argon2Parameters _parameters;
  late List<_Block> _memory;
  late int _segmentLength;
  late int _laneLength;

  Argon2BytesGenerator();

  Argon2Parameters get parameters => _parameters;

  /// Initialise the Argon2BytesGenerator from the parameters.
  /// - [param] parameters Argon2 configuration.
  void init(Argon2Parameters parameters) {
    _parameters = parameters;

    if (parameters.lanes < Argon2BytesGenerator.minParallelism) {
      throw ArgumentError.value(parameters.lanes, 'parameters.lanes', 'lanes must be greater than ${Argon2BytesGenerator.minParallelism}');
    } else if (parameters.lanes > Argon2BytesGenerator.maxParallelism) {
      throw ArgumentError.value(parameters.lanes, 'parameters.lanes', 'lanes must be less than ${Argon2BytesGenerator.maxParallelism}');
    } else if (parameters.memory < 2 * parameters.lanes) {
      throw ArgumentError.value(parameters.memory, 'parameters.memory', 'memory is less than: ${(2 * parameters.lanes)} expected ${(2 * parameters.lanes)}');
    } else if (parameters.iterations < Argon2BytesGenerator.minParallelism) {
      throw ArgumentError.value(parameters.iterations, 'parameters.iterations', 'iterations is less than: ${Argon2BytesGenerator.minParallelism}');
    }

    _doInit(parameters);
  }

  int generateBytesFromString(String password, Uint8List out, [int outOff = 0, int? outLen]) => generateBytes(_parameters.converter.convert(password), out, outOff, outLen);

  int generateBytes(Uint8List password, Uint8List out, [int outOff = 0, int? outLen]) {
    outLen ??= out.length;

    if (outLen < Argon2BytesGenerator.minOutLen) {
      throw ArgumentError.value(outLen, 'outLen', 'output length less than ${Argon2BytesGenerator.minOutLen}');
    }

    var tmpBlockBytes = Uint8List(argon2BlockSize);

    _initialize(tmpBlockBytes, password, outLen);
    _fillMemoryBlocks();
    _digest(tmpBlockBytes, out, outOff, outLen);

    _reset();

    return outLen;
  }

  /// Clear memory.
  void _reset() {
    for (var i = _memory.length - 1; i >= 0; --i) {
      var b = _memory[i];
      b.clear();
    }
  }

  void _doInit(Argon2Parameters parameters) {
    /* 2. Align memory size */
    /* Minimum memoryBlocks = 8L blocks, where L is the number of lanes */
    var memoryBlocks = parameters.memory;

    if (memoryBlocks < 2 * Argon2BytesGenerator.argon2SyncPoints * parameters.lanes) {
      memoryBlocks = 2 * Argon2BytesGenerator.argon2SyncPoints * parameters.lanes;
    }

    _segmentLength = memoryBlocks ~/ (parameters.lanes * Argon2BytesGenerator.argon2SyncPoints);
    _laneLength = _segmentLength * Argon2BytesGenerator.argon2SyncPoints;

    /* Ensure that all segments have equal length */
    memoryBlocks = _segmentLength * (parameters.lanes * Argon2BytesGenerator.argon2SyncPoints);

    _initMemory(memoryBlocks);
  }

  void _initMemory(int memoryBlocks) {
    _memory = List<_Block>.generate(memoryBlocks, (i) => _Block());
  }

  void _fillMemoryBlocks() {
    var filler = _FillBlock();
    var position = _Position();
    for (var pass = 0; pass < _parameters.iterations; ++pass) {
      position.pass = pass;

      for (var slice = 0; slice < argon2SyncPoints; ++slice) {
        position.slice = slice;

        for (var lane = 0; lane < _parameters.lanes; ++lane) {
          position.lane = lane;

          _fillSegment(filler, position);
        }
      }
    }
  }

  void _fillSegment(_FillBlock filler, _Position position) {
    _Block? addressBlock;
    _Block? inputBlock;

    var dataIndependentAddressing = _isDataIndependentAddressing(position);
    var startingIndex = _getStartingIndex(position);
    var currentOffset = position.lane * _laneLength + position.slice * _segmentLength + startingIndex;
    var prevOffset = _getPrevOffset(currentOffset);

    if (dataIndependentAddressing) {
      addressBlock = filler.addressBlock.clear();
      inputBlock = filler.inputBlock.clear();

      _initAddressBlocks(filler, position, inputBlock, addressBlock);
    }

    final withXor = _isWithXor(position);

    for (var index = startingIndex; index < _segmentLength; ++index) {
      var pseudoRandom = _getPseudoRandom(filler, index, addressBlock, inputBlock, prevOffset, dataIndependentAddressing);
      var refLane = _getRefLane(position, pseudoRandom);
      var refColumn = _getRefColumn(position, index, pseudoRandom, refLane == position.lane);

      /* 2 Creating a new block */
      var prevBlock = _memory[prevOffset];
      var refBlock = _memory[((_laneLength) * refLane + refColumn)];
      var currentBlock = _memory[currentOffset];

      if (withXor) {
        filler.fillBlockWithXor(prevBlock, refBlock, currentBlock);
      } else {
        filler.fillBlock2(prevBlock, refBlock, currentBlock);
      }

      prevOffset = currentOffset;
      currentOffset++;
    }
  }

  bool _isDataIndependentAddressing(_Position position) {
    return (_parameters.type == Argon2Parameters.argon2I) || (_parameters.type == Argon2Parameters.argon2ID && (position.pass == 0) && (position.slice < argon2SyncPoints / 2));
  }

  void _initAddressBlocks(_FillBlock filler, _Position position, _Block inputBlock, _Block addressBlock) {
    inputBlock._v[0] = _intToLong(position.pass);
    inputBlock._v[1] = _intToLong(position.lane);
    inputBlock._v[2] = _intToLong(position.slice);
    inputBlock._v[3] = _intToLong(_memory.length);
    inputBlock._v[4] = _intToLong(_parameters.iterations);
    inputBlock._v[5] = _intToLong(_parameters.type);

    if ((position.pass == 0) && (position.slice == 0)) {
      /* Don't forget to generate the first block of addresses: */
      _nextAddresses(filler, inputBlock, addressBlock);
    }
  }

  bool _isWithXor(_Position position) {
    return !(position.pass == 0 || _parameters.version == Argon2Parameters.argon2Version10);
  }

  int _getPrevOffset(int currentOffset) {
    if (currentOffset % _laneLength == 0) {
      /* Last block in this lane */
      return currentOffset + _laneLength - 1;
    } else {
      /* Previous block */
      return currentOffset - 1;
    }
  }

  static int _getStartingIndex(_Position position) {
    if ((position.pass == 0) && (position.slice == 0)) {
      return 2; /* we have already generated the first two blocks */
    } else {
      return 0;
    }
  }

  void _nextAddresses(_FillBlock filler, _Block inputBlock, _Block addressBlock) {
    inputBlock._v[6]++;
    filler.fillBlock(inputBlock, addressBlock);
    filler.fillBlock(addressBlock, addressBlock);
  }

  /* 1.2 Computing the index of the reference block */
  /* 1.2.1 Taking pseudo-random value from the previous block */
  int _getPseudoRandom(_FillBlock filler, int index, _Block? addressBlock, _Block? inputBlock, int prevOffset, bool dataIndependentAddressing) {
    if (dataIndependentAddressing) {
      var addressIndex = index % argon2AddressesInBlock;
      if (addressIndex == 0) {
        _nextAddresses(filler, inputBlock!, addressBlock!);
      }
      return addressBlock!._v[addressIndex];
    } else {
      return _memory[prevOffset]._v[0];
    }
  }

  int _getRefLane(_Position position, int pseudoRandom) {
    var refLane = (pseudoRandom.tripleShift64(32) % _parameters.lanes);

    if ((position.pass == 0) && (position.slice == 0)) {
      /* Can not reference other lanes yet */
      refLane = position.lane;
    }
    return refLane;
  }

  int _getRefColumn(_Position position, int index, int pseudoRandom, bool sameLane) {
    int referenceAreaSize;
    int startPosition;

    if (position.pass == 0) {
      startPosition = 0;

      if (sameLane) {
        /* The same lane => add current segment */
        referenceAreaSize = position.slice * _segmentLength + index - 1;
      } else {
        /* pass == 0 && !sameLane => position.slice > 0*/
        referenceAreaSize = position.slice * _segmentLength + ((index == 0) ? (-1) : 0);
      }
    } else {
      startPosition = ((position.slice + 1) * _segmentLength) % _laneLength;

      if (sameLane) {
        referenceAreaSize = _laneLength - _segmentLength + index - 1;
      } else {
        referenceAreaSize = _laneLength - _segmentLength + ((index == 0) ? (-1) : 0);
      }
    }

    var relativePosition = pseudoRandom & 0xFFFFFFFF;
    relativePosition = (relativePosition * relativePosition).tripleShift64(32);
    relativePosition = referenceAreaSize - 1 - (referenceAreaSize * relativePosition).tripleShift64(32);

    return (startPosition + relativePosition) % _laneLength;
  }

  void _digest(Uint8List tmpBlockBytes, Uint8List out, int outOff, int outLen) {
    var finalBlock = _memory[_laneLength - 1];

    /* XOR the last blocks */
    for (var i = 1; i < _parameters.lanes; i++) {
      var lastBlockInLane = i * _laneLength + (_laneLength - 1);
      finalBlock.xorWith(_memory[lastBlockInLane]);
    }

    finalBlock.toBytes(tmpBlockBytes);

    _hash(tmpBlockBytes, out, outOff, outLen);
  }

  /// H' - hash - variable length hash function
  void _hash(Uint8List input, Uint8List out, int outOff, int outLen) {
    var outLenBytes = Uint8List(4);
    Pack.intToLittleEndianAtList(outLen, outLenBytes, 0);

    var blake2bLength = 64;

    if (outLen <= blake2bLength) {
      var blake = Blake2bDigest(digestSize: outLen);

      blake.update(outLenBytes, 0, outLenBytes.length);
      blake.update(input, 0, input.length);
      blake.doFinal(out, outOff);
    } else {
      var digest = Blake2bDigest(digestSize: blake2bLength);

      var outBuffer = Uint8List(blake2bLength);

      /* V1 */
      digest.update(outLenBytes, 0, outLenBytes.length);
      digest.update(input, 0, input.length);
      digest.doFinal(outBuffer, 0);

      var halfLen = blake2bLength ~/ 2, outPos = outOff;
      out.setFrom(outPos, outBuffer, 0, halfLen);

      outPos += halfLen;

      var r = ((outLen + 31) ~/ 32) - 2;

      for (var i = 2; i <= r; i++, outPos += halfLen) {
        digest.reset();
        /* V2 to Vr */
        digest.update(outBuffer, 0, outBuffer.length);
        digest.doFinal(outBuffer, 0);

        out.setFrom(outPos, outBuffer, 0, halfLen);
      }

      var lastLength = outLen - 32 * r;

      /* Vr+1 */
      digest = Blake2bDigest(digestSize: lastLength);
      digest.update(outBuffer, 0, outBuffer.length);
      digest.doFinal(out, outPos);
    }
  }

  void _initialize(Uint8List tmpBlockBytes, Uint8List password, int outputLength) {
    /**
     * H0 = H64(p, τ, m, t, v, y, |P|, P, |S|, S, |L|, K, |X|, X)
     * -> 64 byte (argon2PrehashDigestLength)
     */

    var blake = Blake2bDigest(digestSize: argon2PrehashDigestLength);

    var values = Uint32List.fromList([_parameters.lanes, outputLength, _parameters.memory, _parameters.iterations, _parameters.version, _parameters.type]);

    Pack.intListToLittleEndianAtList(values, tmpBlockBytes, 0);
    blake.update(tmpBlockBytes, 0, values.length * 4);

    _addByteString(tmpBlockBytes, blake, password);
    _addByteString(tmpBlockBytes, blake, _parameters.salt);
    _addByteString(tmpBlockBytes, blake, _parameters.secret);
    _addByteString(tmpBlockBytes, blake, _parameters.additional);

    var initialHashWithZeros = Uint8List(argon2PrehashSeedLength);
    blake.doFinal(initialHashWithZeros, 0);

    _fillFirstBlocks(tmpBlockBytes, initialHashWithZeros);
  }

  static void _addByteString(Uint8List tmpBlockBytes, Digest digest, [Uint8List? octets]) {
    if (octets == null) {
      digest.update(_zeroBytes, 0, 4);
      return;
    }

    Pack.intToLittleEndianAtList(octets.length, tmpBlockBytes, 0);
    digest.update(tmpBlockBytes, 0, 4);
    digest.update(octets, 0, octets.length);
  }

  /// (H0 || 0 || i) 72 byte -> 1024 byte
  /// (H0 || 1 || i) 72 byte -> 1024 byte
  void _fillFirstBlocks(Uint8List tmpBlockBytes, Uint8List initialHashWithZeros) {
    var initialHashWithOnes = Uint8List(argon2PrehashSeedLength);
    initialHashWithOnes.setFrom(0, initialHashWithZeros, 0, argon2PrehashDigestLength);

    initialHashWithOnes[argon2PrehashDigestLength] = 1;

    for (var i = 0; i < _parameters.lanes; i++) {
      Pack.intToLittleEndianAtList(i, initialHashWithZeros, argon2PrehashDigestLength + 4);
      Pack.intToLittleEndianAtList(i, initialHashWithOnes, argon2PrehashDigestLength + 4);

      _hash(initialHashWithZeros, tmpBlockBytes, 0, argon2BlockSize);
      _memory[i * _laneLength + 0].fromBytes(tmpBlockBytes);

      _hash(initialHashWithOnes, tmpBlockBytes, 0, argon2BlockSize);
      _memory[i * _laneLength + 1].fromBytes(tmpBlockBytes);
    }
  }

  static int _intToLong(int x) => (x & m32L);
}

class _FillBlock {
  final _Block _r = _Block();
  final _Block _z = _Block();

  _Block addressBlock = _Block();
  _Block inputBlock = _Block();

  void _applyBlake() {
    /* Apply Blake2 on columns of 64-bit words: (0,1,...,15) , then
            (16,17,..31)... finally (112,113,...127) */
    for (var i = 0; i < 8; i++) {
      var i16 = 16 * i;
      _roundFunction(_z, i16, i16 + 1, i16 + 2, i16 + 3, i16 + 4, i16 + 5, i16 + 6, i16 + 7, i16 + 8, i16 + 9, i16 + 10, i16 + 11, i16 + 12, i16 + 13, i16 + 14, i16 + 15);
    }

    /* Apply Blake2 on rows of 64-bit words: (0,1,16,17,...112,113), then
            (2,3,18,19,...,114,115).. finally (14,15,30,31,...,126,127) */
    for (var i = 0; i < 8; i++) {
      var i2 = 2 * i;
      _roundFunction(_z, i2, i2 + 1, i2 + 16, i2 + 17, i2 + 32, i2 + 33, i2 + 48, i2 + 49, i2 + 64, i2 + 65, i2 + 80, i2 + 81, i2 + 96, i2 + 97, i2 + 112, i2 + 113);
    }
  }

  void fillBlock(_Block Y, _Block currentBlock) {
    _z.copyBlock(Y);
    _applyBlake();
    currentBlock.xor(Y, _z);
  }

  void fillBlock2(_Block X, _Block Y, _Block currentBlock) {
    _r.xor(X, Y);
    _z.copyBlock(_r);
    _applyBlake();
    currentBlock.xor(_r, _z);
  }

  void fillBlockWithXor(_Block X, _Block Y, _Block currentBlock) {
    _r.xor(X, Y);
    _z.copyBlock(_r);
    _applyBlake();
    currentBlock.xorWith2(_r, _z);
  }

  static void _roundFunction(_Block block, int v0, int v1, int v2, int v3, int v4, int v5, int v6, int v7, int v8, int v9, int v10, int v11, int v12, int v13, int v14, int v15) {
    final v = block._v;

    _f(v, v0, v4, v8, v12);
    _f(v, v1, v5, v9, v13);
    _f(v, v2, v6, v10, v14);
    _f(v, v3, v7, v11, v15);

    _f(v, v0, v5, v10, v15);
    _f(v, v1, v6, v11, v12);
    _f(v, v2, v7, v8, v13);
    _f(v, v3, v4, v9, v14);
  }

  static void _f(Uint64List v, int a, int b, int c, int d) {
    _quarterRound(v, a, b, d, 32);
    _quarterRound(v, c, d, b, 24);
    _quarterRound(v, a, b, d, 16);
    _quarterRound(v, c, d, b, 63);
  }

  static void _quarterRound(Uint64List v, int x, int y, int z, int s) {
    var a = v[x];
    var b = v[y];
    var c = v[z];

    a += b + 2 * Longs.toInt32(a) * Longs.toInt32(b);
    c = Longs.rotateRight(c ^ a, s);

    v[x] = a;
    v[z] = c;
  }
}

class _Block {
  static const int size = Argon2BytesGenerator.argon2QwordsInBlock;

  /// 128 * 8 Byte QWords.
  final Uint64List _v = Uint64List(size);

  _Block();

  void fromBytes(Uint8List input) {
    if (input.length < Argon2BytesGenerator.argon2BlockSize) {
      throw ArgumentError.value(input.length, 'input.length', 'input shorter than blocksize');
    }

    Pack.littleEndianToLongAtList(input, 0, _v);
  }

  void toBytes(Uint8List output) {
    if (output.length < Argon2BytesGenerator.argon2BlockSize) {
      throw ArgumentError.value(output.length, 'output.length', 'output shorter than blocksize');
    }

    Pack.longListToLittleEndianAtList(_v, output, 0);
  }

  void copyBlock(_Block other) {
    _v.setAll(0, other._v);
  }

  void xor(_Block b1, _Block b2) {
    var v0 = _v;
    var v1 = b1._v;
    var v2 = b2._v;

    for (var i = size - 1; i >= 0; --i) {
      v0[i] = v1[i] ^ v2[i];
    }
  }

  void xorWith(_Block b1) {
    var v0 = _v;
    var v1 = b1._v;
    for (var i = size - 1; i >= 0; --i) {
      v0[i] ^= v1[i];
    }
  }

  void xorWith2(_Block b1, _Block b2) {
    var v0 = _v;
    var v1 = b1._v;
    var v2 = b2._v;
    for (var i = size - 1; i >= 0; --i) {
      v0[i] ^= v1[i] ^ v2[i];
    }
  }

  _Block clear() {
    _v.setAllElementsTo(0);

    return this;
  }
}

class _Position {
  int pass;
  int lane;
  int slice;

  _Position([this.pass = 0, this.lane = 0, this.slice = 0]);
}
