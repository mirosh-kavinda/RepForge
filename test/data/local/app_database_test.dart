import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/data/local/app_database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('FND-03 AppDatabase', () {
    test('schema v1 creates catalog, muscles, FTS, meta and outbox', () async {
      expect(db.schemaVersion, 1);
      final names =
          (await db
                  .customSelect(
                    "SELECT name FROM sqlite_master WHERE type IN ('table') ORDER BY name",
                  )
                  .get())
              .map((r) => r.read<String>('name'))
              .toSet();
      expect(
        names,
        containsAll([
          'catalog_exercises',
          'exercise_muscles',
          'exercise_fts',
          'app_meta',
          'outbox',
        ]),
      );
      final indexes =
          (await db
                  .customSelect(
                    "SELECT name FROM sqlite_master WHERE type = 'index'",
                  )
                  .get())
              .map((r) => r.read<String>('name'));
      expect(indexes, contains('exercise_muscles_muscle'));
    });

    test('app meta reads and writes values', () async {
      expect(await db.readMeta('catalogVersion'), isNull);
      await db.writeMeta('catalogVersion', '1');
      await db.writeMeta('catalogVersion', '2');
      expect(await db.readMeta('catalogVersion'), '2');
    });
  });
}
