import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/ids.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/base_columns.dart';
import '../../../data/sync/sync_state.dart';
import '../../../data/sync/synced_writer.dart';
import '../domain/template_repository.dart';
import '../domain/workout_template.dart';
import 'starter_templates.dart';

class DriftTemplateRepository implements TemplateRepository {
  DriftTemplateRepository(this._db, {DateTime Function()? now})
    : _writer = SyncedWriter(_db, now: now);

  static const startersSeededKey = 'workout.startersSeeded';
  static const _table = 'workout_templates';
  static const _entity = 'workoutTemplate';

  final AppDatabase _db;
  final SyncedWriter _writer;

  static Map<String, Object?> exerciseToJson(TemplateExercise e) => {
    'id': e.id,
    'exId': e.exerciseId,
    'sets': e.sets,
    'kind': e.kind.name,
    'repMin': e.repMin,
    'repMax': e.repMax,
    'seconds': e.seconds,
    'targetKg': e.targetKg,
    'restSec': e.restSec,
    'superset': e.superset,
  };

  static TemplateExercise exerciseFromJson(Map<String, Object?> j) =>
      TemplateExercise(
        id: j['id']! as String,
        exerciseId: j['exId']! as String,
        sets: j['sets']! as int,
        kind: TargetKind.values.byName(j['kind']! as String),
        repMin: j['repMin']! as int,
        repMax: j['repMax']! as int,
        seconds: j['seconds']! as int,
        targetKg: (j['targetKg'] as num?)?.toDouble(),
        restSec: j['restSec']! as int,
        superset: j['superset'] as String?,
      );

  static WorkoutTemplate _fromRow(WorkoutTemplateRow r) => WorkoutTemplate(
    id: r.id,
    name: r.name,
    exercises: [
      for (final j in jsonDecode(r.exercises) as List)
        exerciseFromJson((j as Map).cast<String, Object?>()),
    ],
  );

  @override
  Stream<List<WorkoutTemplate>> watchAll() =>
      (_db.selectActive(_db.workoutTemplates)..orderBy([
            (t) => OrderingTerm(expression: t.name.collate(Collate.noCase)),
          ]))
          .watch()
          .map((rows) => rows.map(_fromRow).toList());

  @override
  Future<WorkoutTemplate?> byId(String id) async {
    final row = await (_db.selectActive(
      _db.workoutTemplates,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<bool> _exists(String id) async =>
      await (_db.select(
        _db.workoutTemplates,
      )..where((t) => t.id.equals(id))).getSingleOrNull() !=
      null;

  @override
  Future<void> save(WorkoutTemplate t) => _db.transaction(() async {
    final op = await _exists(t.id) ? OutboxOp.update : OutboxOp.create;
    await _writer.run(
      table: _table,
      entity: _entity,
      id: t.id,
      op: op,
      write: (now) => _db
          .into(_db.workoutTemplates)
          .insertOnConflictUpdate(
            WorkoutTemplatesCompanion.insert(
              id: Value(t.id),
              name: t.name,
              exercises: jsonEncode(t.exercises.map(exerciseToJson).toList()),
              updatedAt: now,
              deletedAt: const Value(null),
            ),
          ),
    );
  });

  @override
  Future<void> delete(String id) =>
      _writer.softDelete(table: _table, entity: _entity, id: id);

  @override
  Future<void> restore(String id) => _writer.run(
    table: _table,
    entity: _entity,
    id: id,
    op: OutboxOp.update,
    write: (_) =>
        (_db.update(_db.workoutTemplates)..where((t) => t.id.equals(id))).write(
          const WorkoutTemplatesCompanion(deletedAt: Value(null)),
        ),
  );

  @override
  Future<void> ensureStarters() => _db.transaction(() async {
    if (await _db.readMeta(startersSeededKey) == 'true') return;
    for (final s in starterTemplates) {
      await save(
        s.copyWith(
          id: newId(),
          exercises: [for (final e in s.exercises) e.copyWith(id: newId())],
        ),
      );
    }
    await _db.writeMeta(startersSeededKey, 'true');
  });
}
