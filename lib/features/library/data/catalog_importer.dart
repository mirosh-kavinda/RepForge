import 'dart:convert';
import 'dart:isolate';

import 'package:drift/drift.dart';

import '../../../data/local/app_database.dart';

enum ImportResult { imported, upgraded, upToDate }

class CatalogImporter {
  CatalogImporter(
    this._db, {
    required Future<String> Function() loadSeed,
    DateTime Function()? now,
  }) : _loadSeed = loadSeed,
       _now = now ?? DateTime.now;

  static const versionKey = catalogVersionKey;

  final AppDatabase _db;
  final Future<String> Function() _loadSeed;
  final DateTime Function() _now;

  Future<ImportResult> run() async {
    final raw = await _loadSeed();
    final seed = await _parseOffMainIsolate(raw);
    final stored = int.tryParse(await _db.readMeta(versionKey) ?? '') ?? 0;
    if (seed.version <= stored) return ImportResult.upToDate;

    // One transaction with the version written last: a killed import leaves
    // nothing behind and simply runs again on the next launch.
    await _db.transaction(() async {
      final existing = {
        for (final row in await _db.select(_db.catalogExercises).get())
          row.id: row,
      };
      final now = _now().toUtc();
      final changed = seed.exercises.where((e) {
        final old = existing[e.id];
        return old == null ||
            old.contentHash != e.hash ||
            old.retiredAt != null;
      }).toList();
      final seedIds = {for (final e in seed.exercises) e.id};

      await _db.batch((b) {
        for (final e in changed) {
          b.insert(
            _db.catalogExercises,
            e.toCompanion(),
            mode: InsertMode.insertOrReplace,
          );
          b.deleteWhere(_db.exerciseMuscles, (m) => m.exerciseId.equals(e.id));
          for (final (muscle, primary) in e.muscles) {
            b.insert(
              _db.exerciseMuscles,
              ExerciseMusclesCompanion.insert(
                exerciseId: e.id,
                muscle: muscle,
                isPrimary: primary,
              ),
            );
          }
        }
        for (final id in existing.keys) {
          if (!seedIds.contains(id) && existing[id]!.retiredAt == null) {
            b.update(
              _db.catalogExercises,
              CatalogExercisesCompanion(retiredAt: Value(now)),
              where: (t) => t.id.equals(id),
            );
          }
        }
      });
      await _db.customStatement(
        "INSERT INTO exercise_fts(exercise_fts) VALUES('rebuild')",
      );
      await _db.writeMeta(versionKey, '${seed.version}');
    });
    return stored == 0 ? ImportResult.imported : ImportResult.upgraded;
  }

  // Static so the closure captures only the raw text, not this importer and
  // its database (a native handle cannot cross isolates).
  static Future<_SeedData> _parseOffMainIsolate(String raw) =>
      Isolate.run(() => _SeedData.parse(raw));
}

class _SeedData {
  _SeedData(this.version, this.exercises);

  factory _SeedData.parse(String raw) {
    final json = jsonDecode(raw) as Map<String, Object?>;
    return _SeedData(json['catalogVersion']! as int, [
      for (final e in (json['exercises']! as List).cast<Map<String, Object?>>())
        _SeedExercise(e),
    ]);
  }

  final int version;
  final List<_SeedExercise> exercises;
}

class _SeedExercise {
  _SeedExercise(this.json);

  final Map<String, Object?> json;

  String get id => json['id']! as String;
  String get hash => json['hash']! as String;

  List<(String, bool)> get muscles => [
    for (final m in (json['primaryMuscles']! as List).cast<String>()) (m, true),
    for (final m in (json['secondaryMuscles']! as List).cast<String>())
      (m, false),
  ];

  CatalogExercisesCompanion toCompanion() => CatalogExercisesCompanion.insert(
    id: id,
    name: json['name']! as String,
    equipment: json['equipment']! as String,
    category: json['category']! as String,
    level: json['level']! as String,
    mechanic: Value(json['mechanic'] as String?),
    force: Value(json['force'] as String?),
    instructions: jsonEncode(json['instructions']),
    images: jsonEncode(json['images']),
    contentHash: hash,
    retiredAt: const Value(null),
  );
}
