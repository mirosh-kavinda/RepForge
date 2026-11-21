import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../data/local/app_database.dart';
import '../../../data/local/base_columns.dart';
import '../../../data/sync/sync_state.dart';
import '../../../data/sync/synced_writer.dart';
import '../domain/cycle.dart';
import '../domain/cycle_repository.dart';

class DriftCycleRepository implements CycleRepository {
  DriftCycleRepository(this._db, {DateTime Function()? now})
    : _writer = SyncedWriter(_db, now: now);

  static const _table = 'cycles';
  static const _entity = 'cycle';

  final AppDatabase _db;
  final SyncedWriter _writer;

  static Cycle _fromRow(CycleRow r) => Cycle(
    id: r.id,
    name: r.name,
    days: [
      for (final j in jsonDecode(r.days) as List)
        CycleDay(
          id: (j as Map)['id']! as String,
          workoutId: j['workoutId'] as String?,
        ),
    ],
    isActive: r.isActive,
    startDate: r.startDate,
    startDayIndex: r.startDayIndex,
  );

  @override
  Stream<List<Cycle>> watchAll() =>
      (_db.selectActive(_db.cycles)..orderBy([
            (c) => OrderingTerm(expression: c.name.collate(Collate.noCase)),
          ]))
          .watch()
          .map((rows) => rows.map(_fromRow).toList());

  @override
  Stream<Cycle?> watchActive() =>
      (_db.selectActive(_db.cycles)
            ..where((c) => c.isActive.equals(true))
            ..limit(1))
          .watchSingleOrNull()
          .map((r) => r == null ? null : _fromRow(r));

  Future<CycleRow?> _row(String id) =>
      (_db.select(_db.cycles)..where((c) => c.id.equals(id))).getSingleOrNull();

  @override
  Future<Cycle?> byId(String id) async {
    final r = await _row(id);
    return r == null || r.deletedAt != null ? null : _fromRow(r);
  }

  Future<void> _write(Cycle c, OutboxOp op) => _writer.run(
    table: _table,
    entity: _entity,
    id: c.id,
    op: op,
    write: (now) => _db
        .into(_db.cycles)
        .insertOnConflictUpdate(
          CyclesCompanion.insert(
            id: Value(c.id),
            name: c.name,
            days: jsonEncode([
              for (final d in c.days) {'id': d.id, 'workoutId': d.workoutId},
            ]),
            isActive: c.isActive,
            startDate: c.startDate,
            startDayIndex: c.startDayIndex,
            updatedAt: now,
            deletedAt: const Value(null),
          ),
        ),
  );

  @override
  Future<void> save(Cycle c) => _db.transaction(() async {
    if (c.isActive) {
      final others = await (_db.select(
        _db.cycles,
      )..where((r) => r.isActive.equals(true) & r.id.equals(c.id).not())).get();
      for (final o in others) {
        await _write(_fromRow(o).copyWith(isActive: false), OutboxOp.update);
      }
    }
    await _write(
      c,
      await _row(c.id) == null ? OutboxOp.create : OutboxOp.update,
    );
  });

  @override
  Future<void> delete(String id) => _db.transaction(() async {
    if ((await _row(id))?.isActive ?? false) throw ActiveCycleDeleteError();
    await _writer.softDelete(table: _table, entity: _entity, id: id);
  });

  @override
  Future<void> restore(String id) => _writer.run(
    table: _table,
    entity: _entity,
    id: id,
    op: OutboxOp.update,
    write: (_) => (_db.update(_db.cycles)..where((c) => c.id.equals(id))).write(
      const CyclesCompanion(deletedAt: Value(null)),
    ),
  );
}
