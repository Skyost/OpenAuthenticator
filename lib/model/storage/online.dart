import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/storage/storage.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/model/totp/json.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/utils/firebase_auth/firebase_auth.dart';

/// Stores TOTPs using Firebase Firestore.
class OnlineStorage with Storage {
  /// The totps collection.
  static const String _kTotpsCollection = 'totps';

  /// The user data document.
  static const String _kUserDataDocument = 'userData';

  /// The salt document.
  static const String _kSaltKey = 'salt';

  /// The ref instance.
  final Ref _ref;

  /// Creates a new online storage instance.
  OnlineStorage(this._ref);

  @override
  StorageType get type => StorageType.online;

  @override
  List<NotifierProvider> get dependencies => [firebaseAuthenticationProvider];

  @override
  Future<void> addTotp(Totp totp) async {
    CollectionReference? collection = _totpsCollection;
    Map<String, dynamic>? data = await _toFirestore(totp);
    if (data == null) {
      throw _SerializationError(totp: totp);
    }
    await collection.doc(totp.uuid).set(data);
  }

  @override
  Future<void> addTotps(List<Totp> totps) async {
    CollectionReference? collection = _totpsCollection;
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (Totp totp in totps) {
      Map<String, dynamic>? data = await _toFirestore(totp);
      if (data == null) {
        throw _SerializationError(totp: totp);
      }
      batch.set(collection.doc(totp.uuid), data);
    }
    await batch.commit();
  }

  @override
  Future<void> deleteTotp(String uuid) => _totpsCollection.doc(uuid).delete();

  @override
  Future<void> deleteTotps(List<String> uuids) async {
    CollectionReference? collection = _totpsCollection;
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (String uuid in uuids) {
      batch.delete(collection.doc(uuid));
    }
    await batch.commit();
  }

  @override
  Future<void> clearTotps() async {
    QuerySnapshot snapshots = await _totpsCollection.get();
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (QueryDocumentSnapshot document in snapshots.docs) {
      batch.delete(document.reference);
    }
    await batch.commit();
  }

  @override
  Future<void> updateTotp(String uuid, Totp totp) async {
    CollectionReference? collection = _totpsCollection;
    Map<String, dynamic>? newData = await _toFirestore(totp);
    if (newData == null) {
      throw _SerializationError(totp: totp);
    }
    await collection.doc(uuid).update(newData);
  }

  @override
  Future<Totp?> getTotp(String uuid) async {
    DocumentSnapshot result = await _totpsCollection.doc(uuid).get();
    if (!result.exists) {
      return null;
    }
    return await _fromFirestore(result);
  }

  @override
  Future<List<Totp>> listTotps() async {
    QuerySnapshot result = await _totpsCollection.orderBy(Totp.kIssuerKey).get();
    List<Totp> totps = [];
    for (QueryDocumentSnapshot doc in result.docs) {
      Totp? totp = await _fromFirestore(doc);
      if (totp != null) {
        totps.add(totp);
      }
    }
    return totps;
  }

  @override
  Future<List<String>> listUuids() async {
    QuerySnapshot result = await _totpsCollection.orderBy(Totp.kIssuerKey).get();
    List<String> uuids = [];
    for (QueryDocumentSnapshot snapshot in result.docs) {
      Object? data = snapshot.data();
      if (data is Map<String, Object?> && data.containsKey(Totp.kUuidKey)) {
        uuids.add(data[Totp.kUuidKey]!.toString());
      }
    }
    return uuids;
  }

  @override
  Future<bool> canDecryptAll(CryptoStore cryptoStore) async {
    QuerySnapshot result = await _totpsCollection.get();
    for (QueryDocumentSnapshot doc in result.docs) {
      Totp? totp = await _fromFirestore(doc, cryptoStore: cryptoStore);
      if (totp == null) {
        return false;
      }
      if (!await cryptoStore.canDecrypt(totp.secret)) {
        return false;
      }
    }
    return true;
  }

  @override
  Future<Salt?> readSecretsSalt() async {
    DocumentSnapshot<Map<String, dynamic>> userDoc = await _userDocument.get();
    if (!userDoc.exists) {
      return null;
    }
    List salt = (userDoc.data() as Map<String, dynamic>)[_kSaltKey];
    return Salt.fromRawValue(value: Uint8List.fromList(salt.cast<int>()));
  }

  @override
  Future<void> saveSecretsSalt(Salt salt) async {
    DocumentReference<Map<String, dynamic>> userDoc = _userDocument;
    await userDoc.set({_kSaltKey: salt.value}, SetOptions(merge: true));
  }

  @override
  Future<void> close() async {
    // FirebaseFirestore.instance.terminate();
  }

  /// Returns a reference to the current user document.
  /// Throws a [NotLoggedInException] if user is not logged in.
  DocumentReference<Map<String, dynamic>> get _userDocument {
    if (!FirebaseAuth.instance.isLoggedIn) {
      throw NotLoggedInException();
    }
    return FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser!.uid).doc(_kUserDataDocument);
  }

  /// Returns a reference to the current user collection.
  /// Throws a [NotLoggedInException] if user is not logged in.
  CollectionReference get _totpsCollection => _userDocument.collection(_kTotpsCollection);

  /// Creates a new TOTP from the specified JSON data.
  Future<Totp?> _fromFirestore(DocumentSnapshot snapshot, {CryptoStore? cryptoStore}) async {
    if (snapshot.data() is! Map<String, Object?>) {
      return null;
    }
    Map<String, Object?> data = snapshot.data() as Map<String, Object?>;
    Map<String, dynamic>? decryptedData = await _transform<List?, dynamic>(
      data,
      (cryptoStore, key, input) async {
        if (input == null) {
          return null;
        }
        String? decrypted = await cryptoStore.decrypt(Uint8List.fromList(input.cast<int>()));
        return decrypted;
      },
      cryptoStore: cryptoStore,
    );
    return decryptedData == null ? null : JsonTotp.fromJson(decryptedData);
  }

  /// Converts the [totp] to an encrypted Firestore map.
  Future<Map<String, dynamic>?> _toFirestore(Totp totp) async => await _transform<dynamic, List>(
        totp.toJson(),
        (cryptoStore, key, input) async {
          if (input == null) {
            return null;
          }
          Uint8List? encrypted = await cryptoStore.encrypt(input.toString());
          return encrypted;
        },
      );

  /// Transforms the [totpData] using the [transformer].
  Future<Map<String, dynamic>?> _transform<I, O>(
    Map<String, dynamic> totpData,
    Future<O?> Function(CryptoStore, String, I) transformer, {
    CryptoStore? cryptoStore,
  }) async {
    cryptoStore ??= await _ref.read(cryptoStoreProvider.future);
    if (cryptoStore == null) {
      return null;
    }
    return {
      Totp.kSecretKey: totpData[Totp.kSecretKey],
      Totp.kEncryptionSalt: totpData[Totp.kEncryptionSalt],
      Totp.kUuidKey: totpData[Totp.kUuidKey],
      Totp.kLabelKey: await transformer(
        cryptoStore,
        Totp.kLabelKey,
        totpData[Totp.kLabelKey],
      ),
      if (totpData.containsKey(Totp.kIssuerKey))
        Totp.kIssuerKey: await transformer(
          cryptoStore,
          Totp.kIssuerKey,
          totpData[Totp.kIssuerKey],
        ),
      if (totpData.containsKey(Totp.kAlgorithmKey)) Totp.kAlgorithmKey: totpData[Totp.kAlgorithmKey],
      if (totpData.containsKey(Totp.kDigitsKey)) Totp.kDigitsKey: totpData[Totp.kDigitsKey],
      if (totpData.containsKey(Totp.kValidityKey)) Totp.kValidityKey: totpData[Totp.kValidityKey],
      if (totpData.containsKey(Totp.kImageUrlKey))
        Totp.kImageUrlKey: await transformer(
          cryptoStore,
          Totp.kImageUrlKey,
          totpData[Totp.kImageUrlKey],
        ),
    };
  }
}

/// Thrown when the user is not logged in.
class NotLoggedInException implements Exception {
  @override
  String toString() => 'User is not logged in';
}

/// Thrown when there is an error serializing a given TOTP.
class _SerializationError implements Exception {
  /// The TOTP.
  final Totp totp;

  /// Creates a new serialization error instance.
  _SerializationError({
    required this.totp,
  });

  @override
  String toString() => 'Unable to serialize TOTP (${totp.uuid} / ${totp.label})';
}
