import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../sync/remote_store.dart';

// SYN-01: users/{uid}/{collection}/{id} in Firestore. Drift is the local
// store, so Firestore's own offline cache is off.
class FirestoreRemoteStore implements RemoteStore {
  FirestoreRemoteStore(this._firestore);

  // Null when Firebase couldn't start (no config, no network at launch).
  final Future<FirebaseFirestore?> _firestore;

  Future<FirebaseFirestore> _db() async {
    final db = await _firestore;
    if (db == null) throw const SyncFailure(SyncErrorKind.offline);
    return db;
  }

  CollectionReference<Map<String, dynamic>> _col(
    FirebaseFirestore db,
    String uid,
    String collection,
  ) => db.collection('users').doc(uid).collection(collection);

  // Permission-denied is the rules refusing a document (e.g. a finished
  // workout's sets), not a sign-out: the engine sets that one aside.
  static SyncFailure _failure(FirebaseException e) =>
      SyncFailure(switch (e.code) {
        'unavailable' || 'deadline-exceeded' => SyncErrorKind.offline,
        'unauthenticated' => SyncErrorKind.signedOut,
        'permission-denied' => SyncErrorKind.rejected,
        _ => SyncErrorKind.server,
      });

  // Without the offline cache a commit can wait forever on a network that
  // only looks connected (captive portal).
  static const _timeout = Duration(seconds: 30);

  @override
  Future<void> commit(String uid, List<RemoteWrite> writes) async {
    final db = await _db();
    final batch = db.batch();
    for (final w in writes) {
      batch.set(_col(db, uid, w.collection).doc(w.id), {
        ...w.data,
        syncedAtField: FieldValue.serverTimestamp(),
      });
    }
    try {
      await batch.commit().timeout(_timeout);
    } on FirebaseException catch (e) {
      throw _failure(e);
    } on TimeoutException {
      throw const SyncFailure(SyncErrorKind.offline);
    }
  }

  static Map<String, Object?> _plain(Map<String, dynamic> d) => {
    for (final MapEntry(:key, :value) in d.entries)
      key: value is Timestamp ? value.millisecondsSinceEpoch : value,
  };

  @override
  Future<List<RemoteDoc>> changedSince(
    String uid,
    String collection,
    int sinceMs,
  ) async {
    final db = await _db();
    try {
      final snap = await _col(db, uid, collection)
          .where(
            syncedAtField,
            isGreaterThanOrEqualTo: Timestamp.fromMillisecondsSinceEpoch(
              sinceMs,
            ),
          )
          .orderBy(syncedAtField)
          .get()
          .timeout(_timeout);
      return [for (final d in snap.docs) (id: d.id, data: _plain(d.data()))];
    } on FirebaseException catch (e) {
      throw _failure(e);
    } on TimeoutException {
      throw const SyncFailure(SyncErrorKind.offline);
    }
  }
}
