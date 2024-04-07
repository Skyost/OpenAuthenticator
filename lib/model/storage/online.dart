import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:open_authenticator/model/storage/storage.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/model/totp/algorithm.dart';
import 'package:open_authenticator/model/totp/json.dart';
import 'package:open_authenticator/model/totp/totp.dart';

/// Stores TOTPs using Firebase Firestore.
class OnlineStorage with Storage {
  /// The totps collection.
  static const String _kTotpsCollection = 'totps';

  /// The user data document.
  static const String _kUserDataDocument = 'userData';

  /// The salt document.
  static const String _kSaltKey = 'salt';

  /// Creates a new online storage instance.
  OnlineStorage();

  @override
  StorageType get type => StorageType.online;

  @override
  Future<bool> addTotp(Totp totp) async {
    CollectionReference? collection = _totpsCollection;
    if (collection == null) {
      return false;
    }
    await collection
        .withConverter(
          fromFirestore: _fromFirestore,
          toFirestore: (totp, options) => totp.toJson(),
        )
        .doc(totp.uuid)
        .set(totp);
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
      batch.set(
        collection
            .withConverter(
              fromFirestore: _fromFirestore,
              toFirestore: (totp, options) => totp.toJson(),
            )
            .doc(totp.uuid),
        totp,
      );
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
    DocumentSnapshot<Totp> result = await collection
        .withConverter(
          fromFirestore: _fromFirestore,
          toFirestore: (totp, options) => totp.toJson(),
        )
        .doc(uuid)
        .get();
    return result.data();
  }

  @override
  Future<List<Totp>> listTotps() async {
    CollectionReference? collection = _totpsCollection;
    if (collection == null) {
      return [];
    }
    QuerySnapshot<Totp> result = await collection
        .withConverter(
          fromFirestore: _fromFirestore,
          toFirestore: (totp, options) => totp.toJson(),
        )
        .get();
    return result.docs.map((result) => result.data()).toList();
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
    if (FirebaseAuth.instance.currentUser == null) {
      return null;
    }
    return FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser!.uid).doc(_kUserDataDocument);
  }

  /// Returns a reference to the current user collection.
  CollectionReference? get _totpsCollection => _userDocument?.collection(_kTotpsCollection);

  /// Creates a new TOTP from the specified JSON data.
  static Totp _fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    Map<String, dynamic> data = snapshot.data()!;
    return JsonTotp.fromJson(data);
  }
}
