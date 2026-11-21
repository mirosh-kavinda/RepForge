import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../data/local/app_database.dart';
import '../domain/exercise.dart';
import '../domain/exercise_catalog_repository.dart';
import '../domain/exercise_query.dart';

class DriftExerciseCatalogRepository implements ExerciseCatalogRepository {
  DriftExerciseCatalogRepository(this._db);

  final AppDatabase _db;

  // "Bench-Press!" → '"bench"* AND "press"*': every word is a prefix term,
  // punctuation and quotes never reach the FTS parser.
  static String? ftsQuery(String text) {
    final words = text
        .toLowerCase()
        .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
        .where((w) => w.isNotEmpty);
    return words.isEmpty ? null : words.map((w) => '"$w"*').join(' AND ');
  }

  @override
  Future<List<Exercise>> search(ExerciseQuery query) async {
    final match = ftsQuery(query.text);
    final vars = <Variable<Object>>[];
    final where = <String>['c.retired_at IS NULL'];

    String inList(String column, Iterable<String> values) {
      vars.addAll(values.map(Variable.withString));
      return '$column IN (${List.filled(values.length, '?').join(', ')})';
    }

    final sql = StringBuffer('SELECT c.*');
    if (query.muscles.isNotEmpty) sql.write(', MAX(m.is_primary) AS prim');
    sql.write(' FROM catalog_exercises c');
    if (match != null) {
      sql.write(
        ' JOIN (SELECT rowid, bm25(exercise_fts) AS rank FROM exercise_fts '
        'WHERE exercise_fts MATCH ?) h ON h.rowid = c.rowid',
      );
      vars.add(Variable.withString(match));
    }
    if (query.muscles.isNotEmpty) {
      sql.write(
        ' JOIN exercise_muscles m ON m.exercise_id = c.id AND '
        '${inList('m.muscle', query.muscles.map((m) => m.key))}',
      );
    }
    if (query.equipment.isNotEmpty) {
      where.add(inList('c.equipment', query.equipment.map((e) => e.key)));
    }
    if (query.levels.isNotEmpty) {
      where.add(inList('c.level', query.levels.map((e) => e.key)));
    }
    if (query.categories.isNotEmpty) {
      where.add(inList('c.category', query.categories.map((e) => e.key)));
    }
    sql.write(' WHERE ${where.join(' AND ')}');
    if (query.muscles.isNotEmpty) sql.write(' GROUP BY c.id');

    final order = <String>[
      if (query.muscles.isNotEmpty) 'prim DESC',
      if (match != null) 'h.rank',
      'c.name COLLATE NOCASE',
    ];
    sql.write(' ORDER BY ${order.join(', ')}');

    final rows = await _db
        .customSelect(
          sql.toString(),
          variables: vars,
          readsFrom: {_db.catalogExercises, _db.exerciseMuscles},
        )
        .get();
    return _toExercises(rows.map((r) => _db.catalogExercises.map(r.data)));
  }

  @override
  Future<Exercise?> byId(String id) async {
    final row = await (_db.select(
      _db.catalogExercises,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return (await _toExercises([row])).single;
  }

  Future<List<Exercise>> _toExercises(Iterable<CatalogExercise> rows) async {
    final list = rows.toList();
    if (list.isEmpty) return const [];
    final muscles = <String, List<ExerciseMuscle>>{};
    final all = await (_db.select(
      _db.exerciseMuscles,
    )..where((m) => m.exerciseId.isIn(list.map((r) => r.id)))).get();
    for (final m in all) {
      (muscles[m.exerciseId] ??= []).add(m);
    }
    return [
      for (final row in list)
        Exercise(
          id: row.id,
          name: row.name,
          primaryMuscles: [
            for (final m in muscles[row.id] ?? const <ExerciseMuscle>[])
              if (m.isPrimary) Muscle.fromKey(m.muscle),
          ],
          secondaryMuscles: [
            for (final m in muscles[row.id] ?? const <ExerciseMuscle>[])
              if (!m.isPrimary) Muscle.fromKey(m.muscle),
          ],
          equipment: Equipment.fromKey(row.equipment),
          category: ExerciseCategory.fromKey(row.category),
          level: ExerciseLevel.fromKey(row.level),
          mechanic: row.mechanic == null
              ? null
              : Mechanic.fromKey(row.mechanic!),
          force: row.force == null ? null : Force.fromKey(row.force!),
          instructions: (jsonDecode(row.instructions) as List).cast<String>(),
          images: (jsonDecode(row.images) as List).cast<String>(),
        ),
    ];
  }
}
