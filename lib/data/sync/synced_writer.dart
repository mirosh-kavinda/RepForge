import 'package:drift/drift.dart';

import 'sync_state.dart';

// The only write path for user-owned tables: the change and its outbox row
// commit together or not at all.
class SyncedWriter {
  SyncedWriter(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final GeneratedDatabase _db;
  final DateTime Function() _now;

  // Stamps updatedAt and syncState itself, so callers cannot forget them.
  Future<void> run({
    required String table,
    required String entity,
    required String id,
    required OutboxOp op,
    required Future<void> Function(DateTime now) write,
  }) => _db.transaction(() async {
    final now = _now().toUtc();
    await write(now);
    await _db.customUpdate(
      'UPDATE "$table" SET updated_at = ?, sync_state = ? WHERE id = ?',
      variables: [
        Variable.withDateTime(now),
        Variable.withString(SyncState.pending.name),
        Variable.withString(id),
      ],
    );
    await _db.customInsert(
      'INSERT INTO outbox (entity, entity_id, op, created_at) VALUES (?, ?, ?, ?)',
      variables: [
        Variable.withString(entity),
        Variable.withString(id),
        Variable.withString(op.name),
        Variable.withDateTime(now),
      ],
    );
  });

  Future<void> softDelete({
    required String table,
    required String entity,
    required String id,
  }) => run(
    table: table,
    entity: entity,
    id: id,
    op: OutboxOp.delete,
    write: (now) => _db.customUpdate(
      'UPDATE "$table" SET deleted_at = ? WHERE id = ?',
      variables: [Variable.withDateTime(now), Variable.withString(id)],
    ),
  );
}
