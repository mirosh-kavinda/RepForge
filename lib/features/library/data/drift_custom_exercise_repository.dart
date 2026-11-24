import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../data/local/app_database.dart';
import '../../../data/local/base_columns.dart';
import '../../../data/sync/sync_state.dart';
import '../../../data/sync/synced_writer.dart';
import '../domain/custom_exercise_repository.dart';
import '../domain/custom_rules.dart';
import '../domain/exercise.dart';

class DriftCustomExerciseRepository implements CustomExerciseRepository {
  DriftCustomExerciseRepository(this._db, {DateTime Function()? now})
    : _writer = SyncedWriter(_db, now: now);

  static const _table = 'custom_exercises';
  static const _entity = 'customExercise';

  final AppDatabase _db;
  final SyncedWriter _writer;

  static String _muscles(List<Muscle> m) =>
      jsonEncode([for (final x in m) x.key]);

  static List<Muscle> _decode(String json) => [
    for (final k in (jsonDecode(json) as List).cast<String>())
      Muscle.fromKey(k),
  ];

  static Exercise fromRow(CustomExerciseRow r) => Exercise(
    id: r.id,
    name: r.name,
    primaryMuscles: _decode(r.primaryMuscles),
    secondaryMuscles: _decode(r.secondaryMuscles),
    equipment: Equipment.fromKey(r.equipment),
    category: ExerciseCategory.strength,
    level: ExerciseLevel.beginner,
    instructions: const [],
    images: const [],
    custom: true,
    notes: r.notes,
  );

  @override
  Stream<List<Exercise>> watchAll() =>
      (_db.selectActive(_db.customExercises)..orderBy([
            (t) => OrderingTerm(expression: t.name.collate(Collate.noCase)),
          ]))
          .watch()
          .map((rows) => rows.map(fromRow).toList());

  @override
  Future<Exercise?> byId(String id) async {
    final r = await (_db.select(
      _db.customExercises,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return r == null ? null : fromRow(r);
  }

  @override
  Future<void> save(Exercise e) => _db.transaction(() async {
    final exists = await byId(e.id) != null;
    final notes = e.notes?.trim();
    await _writer.run(
      table: _table,
      entity: _entity,
      id: e.id,
      op: exists ? OutboxOp.update : OutboxOp.create,
      write: (now) => _db
          .into(_db.customExercises)
          .insertOnConflictUpdate(
            CustomExercisesCompanion.insert(
              id: Value(e.id),
              name: cleanExerciseName(e.name) ?? e.name.trim(),
              equipment: e.equipment.key,
              primaryMuscles: _muscles(e.primaryMuscles),
              secondaryMuscles: _muscles(e.secondaryMuscles),
              notes: Value(notes == null || notes.isEmpty ? null : notes),
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
        (_db.update(_db.customExercises)..where((t) => t.id.equals(id))).write(
          const CustomExercisesCompanion(deletedAt: Value(null)),
        ),
  );

  @override
  Future<NameClash> nameClash(String name, {String? exceptId}) async {
    final key = nameKey(name);
    final mine = await _db.selectActive(_db.customExercises).get();
    if (mine.any((r) => r.id != exceptId && nameKey(r.name) == key)) {
      return NameClash.custom;
    }
    // In Dart, so inner spaces and non-ASCII case follow nameKey exactly.
    final catalog =
        await (_db.selectOnly(_db.catalogExercises)
              ..addColumns([_db.catalogExercises.name])
              ..where(_db.catalogExercises.retiredAt.isNull()))
            .map((r) => r.read(_db.catalogExercises.name)!)
            .get();
    return catalog.any((n) => nameKey(n) == key)
        ? NameClash.catalog
        : NameClash.none;
  }
}
