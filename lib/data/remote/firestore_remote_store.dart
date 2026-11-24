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

  // The server time in microseconds, Firestore's own precision: a cursor in
  // milliseconds would sit before the last document read and fetch it again
  // forever.
  static int _micros(Timestamp t) =>
      t.seconds * 1000000 + t.nanoseconds ~/ 1000;

  static Map<String, Object?> _plain(Map<String, dynamic> d) => {
    for (final MapEntry(:key, :value) in d.entries)
      key: value is Timestamp ? _micros(value) : value,
  };

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run().timeout(_timeout);
    } on FirebaseException catch (e) {
      throw _failure(e);
    } on TimeoutException {
      throw const SyncFailure(SyncErrorKind.offline);
    }
  }

  @override
  Future<List<RemoteDoc>> changedSince(
    String uid,
    String collection,
    PullCursor? after, {
    int limit = pageSize,
  }) async {
    final db = await _db();
    var q = _col(
      db,
      uid,
      collection,
    ).orderBy(syncedAtField).orderBy(FieldPath.documentId);
    if (after != null) {
      q = q.startAfter([
        Timestamp.fromMicrosecondsSinceEpoch(after.at),
        after.id,
      ]);
    }
    final snap = await _guard(() => q.limit(limit).get());
    return [for (final d in snap.docs) (id: d.id, data: _plain(d.data()))];
  }

  @override
  Future<PullCursor?> last(String uid, String collection) async {
    final db = await _db();
    final snap = await _guard(
      () => _col(db, uid, collection)
          .orderBy(syncedAtField, descending: true)
          .orderBy(FieldPath.documentId, descending: true)
          .limit(1)
          .get(),
    );
    if (snap.docs.isEmpty) return null;
    final d = snap.docs.single;
    final t = d.data()[syncedAtField];
    return t is Timestamp ? (at: _micros(t), id: d.id) : null;
  }

  @override
  Future<int> count(
    String uid,
    String collection, {
    bool liveOnly = true,
  }) async {
    final db = await _db();
    final col = _col(db, uid, collection);
    final agg = await _guard(
      () =>
          (liveOnly ? col.where('deletedAt', isNull: true) : col).count().get(),
    );
    return agg.count ?? 0;
  }

  @override
  Future<BackupSummary?> summary(
    String uid,
    Iterable<String> collections,
  ) async {
    final db = await _db();
    Timestamp? newest;
    for (final c in collections) {
      final snap = await _guard(
        () => _col(
          db,
          uid,
          c,
        ).orderBy(syncedAtField, descending: true).limit(1).get(),
      );
      if (snap.docs.isEmpty) continue;
      final t = snap.docs.single.data()[syncedAtField];
      if (t is Timestamp && (newest == null || t.compareTo(newest) > 0)) {
        newest = t;
      }
    }
    if (newest == null) return null;
    return (
      newest: newest.toDate().toUtc(),
      workouts: await count(uid, 'sessions'),
    );
  }
}
