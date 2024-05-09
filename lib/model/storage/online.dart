import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/storage/storage.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/model/totp/json.dart';
import 'package:open_authenticator/model/totp/totp.dart';

/// The online storage provider.
final onlineStorageProvider = FutureProvider.autoDispose<OnlineStorage>((ref) async {
  FirebaseAuthenticationState state = await ref.watch(firebaseAuthenticationProvider);
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

  /// The salt key.
  static const String _kSaltKey = 'salt';

  /// The user id.
  final String? _userId;

  /// The first read updated data subscription.
  StreamSubscription? _firstReadSubscription;

  /// Creates a new online storage instance.
  OnlineStorage({
    String? userId,
  }) : _userId = userId;

  @override
  StorageType get type => StorageType.online;

  @override
  Duration get operationThreshold => const Duration(seconds: 5);

  @override
  Future<List<Totp>> firstRead(Function(List<Totp> updatedData) onUpdatedDataReceived) async {
    QuerySnapshot cacheResult = await _totpsCollection.orderBy(Totp.kIssuerKey).get(const GetOptions(source: Source.cache));
    DateTime? lastUpdated;
    Map<String, Totp> result = {};
    for (QueryDocumentSnapshot doc in cacheResult.docs) {
      Totp? totp = _FirestoreTotp.fromFirestore(doc);
      if (totp == null) {
        continue;
      }
      Map<String, Object?> data = doc.data() as Map<String, Object?>;
      if (data[_FirestoreTotp._kUpdatedKey] is Timestamp) {
        DateTime totpLastUpdated = (data[_FirestoreTotp._kUpdatedKey] as Timestamp).toDate();
        if (lastUpdated == null || totpLastUpdated.isAfter(lastUpdated)) {
          lastUpdated = totpLastUpdated;
        }
      }
      result[totp.uuid] = totp;
    }
    Query serverQuery = _totpsCollection;
    if (lastUpdated != null) {
      serverQuery = serverQuery.where(
        _FirestoreTotp._kUpdatedKey,
        isGreaterThan: Timestamp.fromDate(lastUpdated),
      );
    }
    _firstReadSubscription = serverQuery
        .snapshots(
          includeMetadataChanges: true,
        )
        .map(
          (event) {
            if (event.metadata.isFromCache) {
              return null;
            }
            List<Totp> totps = [];
            for (QueryDocumentSnapshot doc in event.docs) {
              Totp? totp = _FirestoreTotp.fromFirestore(doc);
              if (totp != null) {
                totps.add(totp);
              }
            }
            return totps;
          },
        )
        .listen(
          (totps) {
            if (totps != null) {
              _cancelSubscription();
              onUpdatedDataReceived(totps);
            }
          },
        );
    Timer(const Duration(seconds: 30), _cancelSubscription);
    return result.values.toList()..sort();
  }

  @override
  Future<void> addTotp(Totp totp) async {
    CollectionReference? collection = _totpsCollection;
    await collection.doc(totp.uuid).set(totp.toFirestore());
  }

  @override
  Future<void> addTotps(List<Totp> totps) async {
    CollectionReference? collection = _totpsCollection;
    WriteBatch batch = FirebaseFirestore.instance.batch();
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
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (String uuid in uuids) {
      batch.delete(collection.doc(uuid));
    }
    await batch.commit();
  }

  @override
  Future<void> clearTotps() async {
    QuerySnapshot snapshot = await _totpsCollection.get();
    WriteBatch batch = FirebaseFirestore.instance.batch();
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
  Future<List<Totp>> listTotps() async {
    QuerySnapshot result = await _totpsCollection.orderBy(Totp.kIssuerKey).get();
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
    WriteBatch batch = FirebaseFirestore.instance.batch();
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
    await userDoc.set({_kSaltKey: salt.value}, SetOptions(merge: true));
  }

  @override
  Future<void> close() async {
    _cancelSubscription();
    // FirebaseFirestore.instance.terminate();
  }

  /// Cancels the subscription.
  void _cancelSubscription() {
    _firstReadSubscription?.cancel();
    _firstReadSubscription = null;
  }

  /// Returns a reference to the current user document.
  /// Throws a [NotLoggedInException] if user is not logged in.
  DocumentReference<Map<String, dynamic>> get _userDocument {
    if (_userId == null) {
      throw NotLoggedInException();
    }
    return FirebaseFirestore.instance.collection(_userId).doc(_kUserDataDocument);
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
  /// The last updated key.
  static const String _kUpdatedKey = 'updated';

  /// Converts this TOTP to a Firestore map.
  Map<String, dynamic> toFirestore() => {
        ...toJson(),
        _kUpdatedKey: FieldValue.serverTimestamp(),
      };

  /// Creates a new TOTP from the specified JSON data.
  static Totp? fromFirestore(DocumentSnapshot snapshot) {
    if (snapshot.data() is! Map<String, Object?>) {
      return null;
    }
    return JsonTotp.fromJson(snapshot.data() as Map<String, Object?>);
  }
}
