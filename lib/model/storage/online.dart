import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/storage/storage.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/model/totp/json.dart';
import 'package:open_authenticator/model/totp/totp.dart';

/// The online storage provider.
final onlineStorageProvider = Provider.autoDispose<OnlineStorage>((ref) {
  FirebaseAuthenticationState state = ref.watch(firebaseAuthenticationProvider);
  OnlineStorage storage = OnlineStorage(userId: state is FirebaseAuthenticationStateLoggedIn ? state.user.uid : null);
  ref.onDispose(storage.close);
  return storage;
});

/// Stores TOTPs using Firebase Firestore.
class OnlineStorage with Storage {
  /// The totps collection.
  static const String _kTotpsCollection = 'totps';

  /// The user data document.
  static const String _kUserDataDocument = 'userData';

  /// The last updated key.
  static const String _kUpdatedKey = 'updated';

  /// The salt key.
  static const String _kSaltKey = 'salt';

  /// The user id.
  final String? _userId;

  /// The collection subscription.
  StreamSubscription? _collectionSubscription;

  /// Creates a new online storage instance.
  OnlineStorage({
    String? userId,
  }) : _userId = userId;

  @override
  StorageType get type => StorageType.online;

  @override
  Duration get operationThreshold => const Duration(seconds: 5);

  @override
  Future<void> addTotp(Totp totp) async {
    CollectionReference? collection = _totpsCollection;
    await collection.doc(totp.uuid).set(totp.toFirestore());
  }

  @override
  Future<void> addTotps(List<Totp> totps) async {
    CollectionReference? collection = _totpsCollection;
    WriteBatch batch = _firestore.batch();
    for (Totp totp in totps) {
      batch.set(collection.doc(totp.uuid), totp.toFirestore());
    }
    await batch.commit();
  }

  @override
  Future<void> deleteTotp(String uuid) => _totpsCollection.doc(uuid).delete();

  @override
  Future<void> deleteTotps(List<String> uuids) async {
    CollectionReference? collection = _totpsCollection;
    WriteBatch batch = _firestore.batch();
    for (String uuid in uuids) {
      batch.delete(collection.doc(uuid));
    }
    await batch.commit();
  }

  @override
  Future<void> clearTotps() async {
    QuerySnapshot snapshot = await _totpsCollection.get();
    WriteBatch batch = _firestore.batch();
    for (QueryDocumentSnapshot document in snapshot.docs) {
      batch.delete(document.reference);
    }
    await batch.commit();
  }

  @override
  Future<void> updateTotp(String uuid, Totp totp) async {
    CollectionReference? collection = _totpsCollection;
    await collection.doc(uuid).update(totp.toFirestore());
  }

  @override
  Future<Totp?> getTotp(String uuid) async {
    DocumentSnapshot result = await _totpsCollection.doc(uuid).get();
    if (!result.exists) {
      return null;
    }
    return _FirestoreTotp.fromFirestore(result);
  }

  @override
  Future<List<Totp>> listTotps({GetOptions? getOptions}) async {
    QuerySnapshot result = await _totpsCollection.orderBy(Totp.kIssuerKey).get(getOptions);
    List<Totp> totps = [];
    for (QueryDocumentSnapshot doc in result.docs) {
      Totp? totp = _FirestoreTotp.fromFirestore(doc);
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
  Future<void> replaceTotps(List<Totp> newTotps) async {
    CollectionReference? collection = _totpsCollection;
    WriteBatch batch = _firestore.batch();
    QuerySnapshot snapshots = await collection.get();
    for (QueryDocumentSnapshot document in snapshots.docs) {
      batch.delete(document.reference);
    }
    for (Totp totp in newTotps) {
      batch.set(collection.doc(totp.uuid), totp.toFirestore());
    }
    await batch.commit();
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
    await userDoc.set(
      {
        _kSaltKey: salt.value,
        _kUpdatedKey: FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> deleteSecretsSalt() async {
    DocumentSnapshot<Map<String, dynamic>> userDoc = await _userDocument.get();
    if (!userDoc.exists) {
      return;
    }
    Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
    data.remove(_kSaltKey);
    if (data.isEmpty || (data.keys.length == 1 && data.keys.first == _kUpdatedKey)) {
      await _userDocument.delete();
    } else {
      await _userDocument.set(data);
    }
  }

  @override
  Future<void> close() async {
    _cancelSubscription();
    // _firestore.terminate();
  }

  /// Deletes the user document.
  Future<void> deleteUserDocument() async => await _userDocument.delete();

  /// Cancels the subscription.
  void _cancelSubscription() {
    _collectionSubscription?.cancel();
    _collectionSubscription = null;
  }

  /// Returns the Firestore instance.
  static FirebaseFirestore get _firestore => App.firebaseFirestoreDatabaseId == null
      ? FirebaseFirestore.instance
      : FirebaseFirestore.instanceFor(
          app: Firebase.app(),
          databaseId: App.firebaseFirestoreDatabaseId,
        );

  /// Returns a reference to the current user document.
  /// Throws a [NotLoggedInException] if user is not logged in.
  DocumentReference<Map<String, dynamic>> get _userDocument {
    if (_userId == null) {
      throw NotLoggedInException();
    }
    return _firestore.collection(_userId).doc(_kUserDataDocument);
  }

  /// Returns a reference to the current user collection.
  /// Throws a [NotLoggedInException] if user is not logged in.
  CollectionReference get _totpsCollection => _userDocument.collection(_kTotpsCollection);
}

/// Thrown when the user is not logged in.
class NotLoggedInException implements Exception {
  @override
  String toString() => 'User is not logged in';
}

/// Allows to convert a TOTP to a Firestore map.
extension _FirestoreTotp on Totp {
  /// Converts this TOTP to a Firestore map.
  Map<String, dynamic> toFirestore() => {
        ...toJson(),
        OnlineStorage._kUpdatedKey: FieldValue.serverTimestamp(),
      };

  /// Creates a new TOTP from the specified JSON data.
  static Totp? fromFirestore(DocumentSnapshot snapshot) {
    if (snapshot.data() is! Map<String, Object?>) {
      return null;
    }
    return JsonTotp.fromJson(snapshot.data() as Map<String, Object?>);
  }
}
