import 'package:repforge/data/sync/remote_store.dart';

// In-memory cloud: users/{uid}/{collection}/{id}, with a server clock for
// syncedAt that only moves forward.
class FakeRemoteStore implements RemoteStore {
  final docs = <String, Map<String, Map<String, Map<String, Object?>>>>{};
  final commits = <List<RemoteWrite>>[];
  final pages = <(String, int)>[];
  SyncFailure? failWith;
  // Fails reads once this many pages were served (SYN-02 AC8: a stop).
  int? failAfterPages;
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

  // Writes many at one server time, as one batch does.
  void putBatch(
    String uid,
    String collection,
    Map<String, Map<String, Object?>> byId,
  ) {
    final at = ++serverTime;
    for (final MapEntry(:key, :value) in byId.entries) {
      ((docs[uid] ??= {})[collection] ??= {})[key] = {
        ...value,
        syncedAtField: at,
      };
    }
  }

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
    putBatch(uid, writes.first.collection, {});
    final at = serverTime;
    for (final w in writes) {
      ((docs[uid] ??= {})[w.collection] ??= {})[w.id] = {
        ...w.data,
        syncedAtField: at,
      };
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

  static int _at(Map<String, Object?> d) => d[syncedAtField]! as int;

  static int _order(RemoteDoc a, RemoteDoc b) {
    final t = _at(a.data).compareTo(_at(b.data));
    return t != 0 ? t : a.id.compareTo(b.id);
  }

  @override
  Future<List<RemoteDoc>> changedSince(
    String uid,
    String collection,
    PullCursor? after, {
    int limit = pageSize,
  }) async {
    if (failWith case final e?) throw e;
    if (failAfterPages case final n? when pages.length >= n) {
      throw const SyncFailure(SyncErrorKind.offline);
    }
    final sorted = [
      for (final MapEntry(:key, :value) in all(uid, collection).entries)
        (id: key, data: value),
    ]..sort(_order);
    final page = [
      for (final d in sorted)
        if (after == null ||
            _at(d.data) > after.at ||
            (_at(d.data) == after.at && d.id.compareTo(after.id) > 0))
          d,
    ].take(limit).toList();
    pages.add((collection, page.length));
    return page;
  }

  @override
  Future<PullCursor?> last(String uid, String collection) async {
    if (failWith case final e?) throw e;
    final sorted = [
      for (final MapEntry(:key, :value) in all(uid, collection).entries)
        (id: key, data: value),
    ]..sort(_order);
    if (sorted.isEmpty) return null;
    return (at: _at(sorted.last.data), id: sorted.last.id);
  }

  @override
  Future<int> count(
    String uid,
    String collection, {
    bool liveOnly = true,
  }) async {
    if (failWith case final e?) throw e;
    return all(
      uid,
      collection,
    ).values.where((d) => !liveOnly || d['deletedAt'] == null).length;
  }

  @override
  Future<BackupSummary?> summary(
    String uid,
    Iterable<String> collections,
  ) async {
    if (failWith case final e?) throw e;
    var newest = 0;
    for (final c in collections) {
      for (final d in all(uid, c).values) {
        if (_at(d) > newest) newest = _at(d);
      }
    }
    if (newest == 0) return null;
    return (
      newest: DateTime.fromMillisecondsSinceEpoch(newest, isUtc: true),
      workouts: await count(uid, 'sessions'),
    );
  }
}
