import 'package:drift/drift.dart';

import '../../../data/local/app_database.dart';
import '../../../data/local/base_columns.dart';
import '../../../data/sync/sync_state.dart';
import '../../../data/sync/synced_writer.dart';
import '../domain/goal.dart';
import '../domain/goal_repository.dart';

class DriftGoalRepository implements GoalRepository {
  DriftGoalRepository(this._db, {DateTime Function()? now})
    : _writer = SyncedWriter(_db, now: now);

  static const _table = 'goals';
  static const _entity = 'goal';

  final AppDatabase _db;
  final SyncedWriter _writer;

  static Goal _fromRow(GoalRow r) => Goal(
    id: r.id,
    type: GoalType.values.byName(r.type),
    exerciseId: r.exerciseId,
    startValue: r.startValue,
    target: r.targetValue,
    deadline: r.deadline,
    pinned: r.pinned,
    createdAt: r.createdAt,
    achievedAt: r.achievedAt,
  );

  @override
  Stream<List<Goal>> watchAll() =>
      (_db.selectActive(_db.goals)
            ..orderBy([(g) => OrderingTerm.desc(g.createdAt)]))
          .watch()
          .map((rows) => rows.map(_fromRow).toList());

  Future<GoalRow?> _row(String id) =>
      (_db.select(_db.goals)..where((g) => g.id.equals(id))).getSingleOrNull();

  Future<void> _update(String id, GoalsCompanion c) => _writer.run(
    table: _table,
    entity: _entity,
    id: id,
    op: OutboxOp.update,
    write: (_) =>
        (_db.update(_db.goals)..where((g) => g.id.equals(id))).write(c),
  );

  @override
  Future<void> save(Goal g) => _db.transaction(() async {
    final exists = await _row(g.id) != null;
    await _writer.run(
      table: _table,
      entity: _entity,
      id: g.id,
      op: exists ? OutboxOp.update : OutboxOp.create,
      write: (now) => _db
          .into(_db.goals)
          .insertOnConflictUpdate(
            GoalsCompanion.insert(
              id: Value(g.id),
              type: g.type.name,
              exerciseId: Value(g.exerciseId),
              startValue: g.startValue,
              targetValue: g.target,
              deadline: Value(g.deadline),
              pinned: Value(g.pinned),
              createdAt: g.createdAt,
              achievedAt: Value(g.achievedAt),
              updatedAt: now,
            ),
          ),
    );
  });

  @override
  Future<void> updateTarget(String id, double target, DateTime? deadline) =>
      _update(
        id,
        GoalsCompanion(targetValue: Value(target), deadline: Value(deadline)),
      );

  @override
  Future<void> pin(String id) => _db.transaction(() async {
    final others = await (_db.selectActive(
      _db.goals,
    )..where((g) => g.pinned.equals(true) & g.id.equals(id).not())).get();
    for (final o in others) {
      await _update(o.id, const GoalsCompanion(pinned: Value(false)));
    }
    await _update(id, const GoalsCompanion(pinned: Value(true)));
  });

  @override
  Future<void> unpin(String id) =>
      _update(id, const GoalsCompanion(pinned: Value(false)));

  @override
  Future<void> achieve(String id, DateTime date) => _update(
    id,
    GoalsCompanion(achievedAt: Value(date), pinned: const Value(false)),
  );

  @override
  Future<void> delete(String id) =>
      _writer.softDelete(table: _table, entity: _entity, id: id);

  @override
  Future<void> restore(String id) => _update(
    id,
    const GoalsCompanion(deletedAt: Value(null), pinned: Value(false)),
  );
}
