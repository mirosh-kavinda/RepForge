import 'package:drift/drift.dart';

import '../local/app_database.dart';
import 'remote_store.dart';
import 'sync_codecs.dart';

const _backedUpKey = 'sync.backedUpAt';
const _errorKey = 'sync.error';
// Per account: another account on this phone starts from the beginning.
String _pulledKey(String uid, String collection) =>
    'sync.pulledAt.$uid.$collection';
String _setAsideKey(String entity, String id) => 'sync.setAside.$entity.$id';

typedef SyncStatus = ({
  DateTime? backedUpAt,
  int waiting,
  SyncErrorKind? error,
});

// Still the account this run started for (edge: sign-out mid-sync).
typedef StillFor = bool Function();

bool _always() => true;

// What the scheduler runs (SYN-01).
abstract interface class SyncRunner {
  Future<void> push(
    String uid, {
    required bool withBody,
    StillFor current = _always,
  });

  Future<void> pull(String uid, {StillFor current = _always});

  Future<void> recordError(SyncErrorKind? kind);
}

// SYN-01: drains the outbox to the cloud and pulls the cloud back, by the
// sync rules in docs/architecture.md.
class SyncEngine implements SyncRunner {
  SyncEngine(this._db, this._remote, {DateTime Function()? now})
    : _now = now ?? DateTime.now,
      _codecs = syncCodecs(_db);

  final AppDatabase _db;
  final RemoteStore _remote;
  final DateTime Function() _now;
  final Map<String, SyncCodec> _codecs;

  // Outbox rows, one per (entity, id), in the order of their latest change;
  // each keeps every seq it stands for (edge: changed again before sending).
  Future<List<({String entity, String id, List<int> seqs})>> _queue({
    required bool withBody,
  }) async {
    final rows = await (_db.select(
      _db.outbox,
    )..orderBy([(o) => OrderingTerm.asc(o.seq)])).get();
    final byKey = <(String, String), List<int>>{};
    for (final r in rows) {
      if (!withBody && bodyEntities.contains(r.entity)) continue;
      (byKey[(r.entity, r.entityId)] ??= []).add(r.seq);
    }
    return [
      for (final MapEntry(key: (entity, id), value: seqs) in byKey.entries)
        (entity: entity, id: id, seqs: seqs),
    ]..sort((a, b) => a.seqs.last.compareTo(b.seqs.last));
  }

  // AC9: changes not yet backed up.
  Stream<int> watchWaiting() => _db
      .customSelect(
        'SELECT COUNT(*) AS n FROM '
        '(SELECT DISTINCT entity, entity_id FROM outbox)',
        readsFrom: {_db.outbox},
      )
      .watchSingle()
      .map((r) => r.read<int>('n'));

  // AC9, AC10: re-emits on outbox and status changes alike.
  Stream<SyncStatus> watchStatus() => _db
      .customSelect(
        'SELECT '
        '(SELECT COUNT(*) FROM (SELECT DISTINCT entity, entity_id FROM outbox))'
        ' AS n, '
        '(SELECT value FROM app_meta WHERE key = ?) AS b, '
        '(SELECT value FROM app_meta WHERE key = ?) AS e',
        variables: [
          Variable.withString(_backedUpKey),
          Variable.withString(_errorKey),
        ],
        readsFrom: {_db.outbox, _db.appMeta},
      )
      .watchSingle()
      .map((r) {
        final ms = int.tryParse(r.readNullable<String>('b') ?? '');
        return (
          backedUpAt: ms == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(ms),
          waiting: r.read<int>('n'),
          error: SyncErrorKind.values.asNameMap()[r.readNullable<String>('e')],
        );
      });

  @override
  Future<void> recordError(SyncErrorKind? kind) => kind == null
      ? _db.deleteMeta(_errorKey)
      : _db.writeMeta(_errorKey, kind.name);

  // AC1–AC3, AC7, AC11: sends the queue oldest first, ≤ 500 per batch; a
  // batch's outbox rows go only once the cloud has it all. A document the
  // server refuses is set aside so it can't hold up everything after it.
  @override
  Future<void> push(
    String uid, {
    required bool withBody,
    StillFor current = _always,
  }) async {
    final queue = await _queue(withBody: withBody);
    for (var i = 0; i < queue.length; i += maxBatch) {
      final chunk = queue.skip(i).take(maxBatch).toList();
      final items =
          <
            ({
              ({String entity, String id, List<int> seqs}) q,
              SyncCodec codec,
              RemoteWrite write,
              Object? stamp,
            })
          >[];
      for (final q in chunk) {
        final codec = _codecs[q.entity];
        if (codec == null) continue;
        final stamp = await codec.rawUpdatedAt(_db, q.id);
        final doc = await codec.toRemote(_db, q.id, withBody: withBody);
        if (doc == null) continue;
        items.add((
          q: q,
          codec: codec,
          write: (collection: codec.collection, id: q.id, data: doc),
          stamp: stamp,
        ));
      }
      if (!current()) return;
      var sent = items;
      try {
        if (items.isNotEmpty) {
          await _remote.commit(uid, [for (final it in items) it.write]);
        }
      } on SyncFailure catch (e) {
        if (e.kind != SyncErrorKind.rejected) rethrow;
        // One by one, to find the document the server won't take.
        sent = [];
        for (final it in items) {
          if (!current()) return;
          try {
            await _remote.commit(uid, [it.write]);
            sent.add(it);
          } on SyncFailure catch (e) {
            if (e.kind != SyncErrorKind.rejected) rethrow;
            await _db.writeMeta(
              _setAsideKey(it.q.entity, it.q.id),
              '${_now().millisecondsSinceEpoch}',
            );
          }
        }
      }
      if (!current()) return;
      await _db.transaction(() async {
        // Set-aside rows leave the queue too; the record stays on the phone.
        await (_db.delete(
          _db.outbox,
        )..where((o) => o.seq.isIn([for (final q in chunk) ...q.seqs]))).go();
        for (final s in sent) {
          // Only if it hasn't changed again while sending: the stored value
          // as SQLite holds it, so the comparison is exact.
          final stamp = s.stamp;
          if (stamp == null) continue;
          await _db.customUpdate(
            'UPDATE "${s.codec.table.actualTableName}" SET sync_state = ? '
            'WHERE id = ? AND updated_at = ?',
            variables: [
              Variable.withString('synced'),
              Variable.withString(s.q.id),
              if (stamp is int)
                Variable.withInt(stamp)
              else
                Variable.withString('$stamp'),
            ],
            updates: {s.codec.table},
          );
        }
      });
    }
    if (!current()) return;
    await _db.writeMeta(_backedUpKey, '${_now().millisecondsSinceEpoch}');
    await recordError(null);
  }

  // AC4, AC5, AC11: per collection, what reached the server since the last
  // pull (server time, so late uploads aren't missed). A local change still
  // waiting to be sent wins over an older cloud one. A document that can't
  // be applied is skipped, never fatal.
  @override
  Future<void> pull(String uid, {StillFor current = _always}) async {
    for (final codec in _codecs.values) {
      final key = _pulledKey(uid, codec.collection);
      final since = int.tryParse(await _db.readMeta(key) ?? '') ?? 0;
      final docs = await _remote.changedSince(uid, codec.collection, since);
      var newest = since;
      for (final d in docs) {
        if (!current()) return;
        if (d.data[syncedAtField] case final int at when at > newest) {
          newest = at;
        }
        final remoteAt = d.data['updatedAt'];
        if (remoteAt is! int) continue;
        try {
          final local = await codec.readLocal(_db, d.id);
          final localAt = local?['updatedAt'];
          if (local != null && localAt is int && localAt >= remoteAt) continue;
          await codec.apply(_db, d.id, d.data);
        } on Object {
          // A document this version can't read; the rest still apply.
        }
      }
      if (!current()) return;
      // ">=" on the next pull: documents sharing this millisecond come again
      // and are skipped as already applied.
      if (newest > since) await _db.writeMeta(key, '$newest');
    }
  }
}
