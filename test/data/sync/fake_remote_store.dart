import 'package:repforge/data/sync/remote_store.dart';

// In-memory cloud: users/{uid}/{collection}/{id}, with a server clock for
// syncedAt that only moves forward.
class FakeRemoteStore implements RemoteStore {
  final docs = <String, Map<String, Map<String, Map<String, Object?>>>>{};
  final commits = <List<RemoteWrite>>[];
  SyncFailure? failWith;
  var serverTime = 1000000;
  // Sessions are append-only, as the security rules enforce (AC5).
  var enforceCreateOnlySessions = true;
  // Ids the "rules" refuse.
  final refuse = <String>{};

  Map<String, Object?>? doc(String uid, String collection, String id) =>
      docs[uid]?[collection]?[id];

  Map<String, Map<String, Object?>> all(String uid, String collection) =>
      docs[uid]?[collection] ?? const {};

  // Writes as another phone would, stamped by the server now.
  void put(String uid, String collection, String id, Map<String, Object?> d) =>
      ((docs[uid] ??= {})[collection] ??= {})[id] = {
        ...d,
        syncedAtField: ++serverTime,
      };

  @override
  Future<void> commit(String uid, List<RemoteWrite> writes) async {
    if (failWith case final e?) throw e;
    if (writes.length > maxBatch) throw StateError('batch over $maxBatch');
    for (final w in writes) {
      if (refuse.contains(w.id)) {
        throw const SyncFailure(SyncErrorKind.rejected);
      }
      final old = doc(uid, w.collection, w.id);
      if (enforceCreateOnlySessions &&
          w.collection == 'sessions' &&
          old != null &&
          old['endedAt'] != null &&
          !_onlyNoteOrDelete(old, w.data)) {
        throw const SyncFailure(SyncErrorKind.rejected);
      }
    }
    commits.add(writes);
    for (final w in writes) {
      put(uid, w.collection, w.id, Map.of(w.data));
    }
  }

  // A finished workout's sets never change; its note and deletion may.
  static bool _onlyNoteOrDelete(
    Map<String, Object?> a,
    Map<String, Object?> b,
  ) {
    const free = {'note', 'updatedAt', 'deletedAt', syncedAtField};
    for (final k in {...a.keys, ...b.keys}) {
      if (free.contains(k)) continue;
      if ('${a[k]}' != '${b[k]}') return false;
    }
    return true;
  }

  @override
  Future<List<RemoteDoc>> changedSince(
    String uid,
    String collection,
    int sinceMs,
  ) async {
    if (failWith case final e?) throw e;
    int at(Map<String, Object?> d) => d[syncedAtField]! as int;
    return [
      for (final MapEntry(:key, :value) in all(uid, collection).entries)
        if (at(value) >= sinceMs) (id: key, data: value),
    ]..sort((a, b) => at(a.data).compareTo(at(b.data)));
  }
}
