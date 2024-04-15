import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/storage/storage.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/model/totp/algorithm.dart';
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
  final AutoDisposeAsyncNotifierProviderRef _ref;

  /// Creates a new online storage instance.
  OnlineStorage(this._ref);

  @override
  StorageType get type => StorageType.online;

  @override
  Future<bool> addTotp(Totp totp) async {
    CollectionReference? collection = _totpsCollection;
    if (collection == null) {
      return false;
    }
    Map<String, dynamic>? data = await _toFirestore(totp);
    if (data == null) {
      return false;
    }
    await collection.doc(totp.uuid).set(data);
    return true;
  }

  @override
  Future<bool> addTotps(List<Totp> totps) async {
    CollectionReference? collection = _totpsCollection;
    if (collection == null) {
      return false;
    }
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (Totp totp in totps) {
      Map<String, dynamic>? data = await _toFirestore(totp);
      if (data == null) {
        return false;
      }
      batch.set(collection.doc(totp.uuid), data);
    }
    await batch.commit();
    return true;
  }

  @override
  Future<bool> deleteTotp(String uuid) async {
    CollectionReference? collection = _totpsCollection;
    if (collection == null) {
      return false;
    }
    await collection.doc(uuid).delete();
    return true;
  }

  @override
  Future<bool> deleteTotps(List<String> uuids) async {
    CollectionReference? collection = _totpsCollection;
    if (collection == null) {
      return false;
    }
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (String uuid in uuids) {
      batch.delete(collection.doc(uuid));
    }
    await batch.commit();
    return true;
  }

  @override
  Future<bool> clearTotps() async {
    CollectionReference? collection = _totpsCollection;
    if (collection == null) {
      return false;
    }
    WriteBatch batch = FirebaseFirestore.instance.batch();
    QuerySnapshot snapshots = await collection.get();
    for (QueryDocumentSnapshot document in snapshots.docs) {
      batch.delete(document.reference);
    }
    await batch.commit();
    return true;
  }

  @override
  Future<bool> updateTotp(
    String uuid, {
    String? label,
    String? issuer,
    Algorithm? algorithm,
    int? digits,
    int? validity,
    String? imageUrl,
  }) async {
    CollectionReference? collection = _totpsCollection;
    if (collection == null) {
      return false;
    }
    await collection.doc(uuid).update({
      if (label != null) Totp.kLabelKey: label,
      if (issuer != null) Totp.kIssuerKey: issuer,
      if (algorithm != null) Totp.kAlgorithmKey: algorithm.name,
      if (digits != null) Totp.kDigitsKey: digits,
      if (validity != null) Totp.kValidityKey: validity,
      if (imageUrl != null) Totp.kImageUrlKey: imageUrl,
    });
    return true;
  }

  @override
  Future<Totp?> getTotp(String uuid) async {
    CollectionReference? collection = _totpsCollection;
    if (collection == null) {
      return null;
    }
    DocumentSnapshot result = await collection.doc(uuid).get();
    if (!result.exists) {
      return null;
    }
    return await _fromFirestore(result);
  }

  @override
  Future<List<Totp>> listTotps() async {
    CollectionReference? collection = _totpsCollection;
    if (collection == null) {
      return [];
    }
    QuerySnapshot result = await collection.get();
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
  Future<bool> canDecryptAll(CryptoStore cryptoStore) async {
    CollectionReference? collection = _totpsCollection;
    if (collection == null) {
      return false;
    }
    QuerySnapshot result = await collection.get();
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
  Future<Uint8List?> readSecretsSalt() async {
    DocumentSnapshot<Map<String, dynamic>>? userDoc = await _userDocument?.get();
    if (userDoc == null || !userDoc.exists) {
      return null;
    }
    List salt = (userDoc.data() as Map<String, dynamic>)[_kSaltKey];
    return Uint8List.fromList(salt.cast<int>());
  }

  @override
  Future<bool> saveSecretsSalt(Uint8List salt) async {
    DocumentReference<Map<String, dynamic>>? userDoc = _userDocument;
    if (userDoc == null) {
      return false;
    }
    await userDoc.set({_kSaltKey: salt}, SetOptions(merge: true));
    return true;
  }

  @override
  Future<void> close() async {
    // FirebaseFirestore.instance.terminate();
  }

  /// Returns a reference to the current user document.
  DocumentReference<Map<String, dynamic>>? get _userDocument {
    if (!FirebaseAuth.instance.isLoggedIn) {
      return null;
    }
    return FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser!.uid).doc(_kUserDataDocument);
  }

  /// Returns a reference to the current user collection.
  CollectionReference? get _totpsCollection => _userDocument?.collection(_kTotpsCollection);

  /// Creates a new TOTP from the specified JSON data.
  Future<Totp?> _fromFirestore(DocumentSnapshot snapshot, {CryptoStore? cryptoStore}) async {
    if (snapshot.data() is! Map<String, Object?>) {
      return null;
    }
    Map<String, Object?> data = snapshot.data() as Map<String, Object?>;
    Map<String, dynamic>? decryptedData = await _transform<List, dynamic>(
      data,
      (cryptoStore, key, input) async {
        String? decrypted = await cryptoStore.decrypt(Uint8List.fromList(input.cast<int>()));
        if (decrypted == null) {
          return decrypted;
        }
        if (key == Totp.kDigitsKey || key == Totp.kValidityKey) {
          return int.tryParse(decrypted);
        }
        if (key == Totp.kAlgorithmKey) {
          return Algorithm.fromString(decrypted);
        }
        return decrypted;
      },
      cryptoStore: cryptoStore,
    );
    return decryptedData == null ? null : JsonTotp.fromJson(decryptedData);
  }

  /// Converts the [totp] to an encrypted Firestore map.
  Future<Map<String, dynamic>?> _toFirestore(Totp totp) async => await _transform<dynamic, List>(
        totp.toJson(),
        (cryptoStore, key, input) async => input == null ? null : (await cryptoStore.encrypt(input.toString())),
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
      if (totpData.containsKey(Totp.kAlgorithmKey))
        Totp.kAlgorithmKey: await transformer(
          cryptoStore,
          Totp.kAlgorithmKey,
          totpData[Totp.kIssuerKey],
        ),
      if (totpData.containsKey(Totp.kDigitsKey))
        Totp.kDigitsKey: await transformer(
          cryptoStore,
          Totp.kDigitsKey,
          totpData[Totp.kDigitsKey],
        ),
      if (totpData.containsKey(Totp.kValidityKey))
        Totp.kValidityKey: await transformer(
          cryptoStore,
          Totp.kValidityKey,
          totpData[Totp.kValidityKey],
        ),
      if (totpData.containsKey(Totp.kImageUrlKey))
        Totp.kImageUrlKey: await transformer(
          cryptoStore,
          Totp.kImageUrlKey,
          totpData[Totp.kImageUrlKey],
        ),
    };
  }
}
