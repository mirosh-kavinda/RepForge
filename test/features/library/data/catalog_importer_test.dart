import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/features/library/data/catalog_importer.dart';

Map<String, Object?> ex(String id, {String? name, String level = 'beginner'}) =>
    {
      'id': id,
      'name': name ?? 'Exercise $id',
      'primaryMuscles': ['chest'],
      'secondaryMuscles': ['triceps'],
      'equipment': 'barbell',
      'category': 'strength',
      'level': level,
      'mechanic': null,
      'force': 'push',
      'instructions': ['Do it.'],
      'images': ['$id/0.jpg'],
      'hash': '${name ?? id}-$level',
    };

String seed(int version, List<Map<String, Object?>> exercises) => jsonEncode({
  'catalogVersion': version,
  'source': 'test',
  'exercises': exercises,
});

final realSeed = File('assets/exercises/seed.json').readAsStringSync();

void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 11, 21);

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  CatalogImporter importer(String json) =>
      CatalogImporter(db, loadSeed: () async => json, now: () => now);

  Future<int> count(String table) async =>
      (await db.customSelect('SELECT count(*) AS c FROM $table').getSingle())
          .read<int>('c');

  group('FND-03 catalog import', () {
    test('AC3 first launch imports the whole seed once', () async {
      expect(await importer(realSeed).run(), ImportResult.imported);
      expect(await count('catalog_exercises'), 876);
      expect(await count('exercise_fts'), 876);
      expect(await count('exercise_muscles'), greaterThan(876));
      expect(await db.readMeta('catalogVersion'), '1');

      expect(await importer(realSeed).run(), ImportResult.upToDate);
      expect(await count('catalog_exercises'), 876);
    });

    test('AC3 a later launch with the same version writes nothing', () async {
      await importer(seed(1, [ex('a')])).run();
      await db.customStatement(
        "UPDATE catalog_exercises SET name = 'touched' WHERE id = 'a'",
      );
      expect(
        await importer(seed(1, [ex('a', name: 'new')])).run(),
        ImportResult.upToDate,
      );
      final name = await db
          .customSelect("SELECT name FROM catalog_exercises WHERE id = 'a'")
          .getSingle();
      expect(name.read<String>('name'), 'touched');
    });

    test(
      'edge: a failed import leaves nothing and the next launch completes',
      () async {
        final broken = ex('b')..['primaryMuscles'] = ['chest', 'chest'];
        await expectLater(
          importer(seed(1, [ex('a'), broken])).run(),
          throwsA(anything),
        );
        expect(await count('catalog_exercises'), 0);
        expect(await count('exercise_muscles'), 0);
        expect(await db.readMeta('catalogVersion'), isNull);

        expect(
          await importer(seed(1, [ex('a'), ex('b')])).run(),
          ImportResult.imported,
        );
        expect(await count('catalog_exercises'), 2);
      },
    );

    test('AC9 a higher version writes only new or changed exercises', () async {
      await importer(seed(1, [ex('a'), ex('b'), ex('c')])).run();
      await db.customStatement(
        "UPDATE catalog_exercises SET name = 'local' WHERE id = 'a'",
      );

      final result = await importer(
        seed(2, [ex('a'), ex('b', level: 'expert'), ex('d', name: 'Deadlift')]),
      ).run();
      expect(result, ImportResult.upgraded);

      final rows = {
        for (final r
            in await db
                .customSelect(
                  'SELECT id, name, level, retired_at FROM catalog_exercises',
                )
                .get())
          r.read<String>('id'): r,
      };
      expect(
        rows['a']!.read<String>('name'),
        'local',
        reason: 'unchanged row not rewritten',
      );
      expect(rows['b']!.read<String>('level'), 'expert');
      expect(rows['d']!.read<String>('name'), 'Deadlift');
      expect(rows['c']!.read<String?>('retired_at'), isNotNull);
      expect(rows['a']!.read<String?>('retired_at'), isNull);
      expect(await db.readMeta('catalogVersion'), '2');

      final fts = await db
          .customSelect(
            "SELECT rowid FROM exercise_fts WHERE exercise_fts MATCH 'deadlift*'",
          )
          .get();
      expect(fts, hasLength(1));
    });

    test('AC9 a retired exercise that returns is active again', () async {
      await importer(seed(1, [ex('a'), ex('b')])).run();
      await importer(seed(2, [ex('a')])).run();
      await importer(seed(3, [ex('a'), ex('b')])).run();
      final b = await db
          .customSelect(
            "SELECT retired_at FROM catalog_exercises WHERE id = 'b'",
          )
          .getSingle();
      expect(b.read<String?>('retired_at'), isNull);
    });
  });
}
