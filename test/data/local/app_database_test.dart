import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/data/local/app_database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('ONB-01 schema v2', () {
    Future<Set<String>> tables(AppDatabase d) async =>
        (await d
                .customSelect(
                  "SELECT name FROM sqlite_master WHERE type = 'table'",
                )
                .get())
            .map((r) => r.read<String>('name'))
            .toSet();

    test('fresh install has the profile and snapshot tables', () async {
      expect(
        await tables(db),
        containsAll(['user_profiles', 'body_snapshots']),
      );
    });

    test('v1 -> v2 upgrade adds them and keeps existing data', () async {
      final dir = await Directory.systemTemp.createTemp('rf_migration');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/app.db');

      final v1 = AppDatabase(NativeDatabase(file));
      await v1.writeMeta('auth.choiceMade', 'true');
      await v1.customStatement('DROP TABLE user_profiles');
      await v1.customStatement('DROP TABLE body_snapshots');
      await v1.customStatement('PRAGMA user_version = 1');
      await v1.close();

      final v2 = AppDatabase(NativeDatabase(file));
      addTearDown(v2.close);
      expect(
        await tables(v2),
        containsAll(['user_profiles', 'body_snapshots']),
      );
      expect(await v2.readMeta('auth.choiceMade'), 'true');
    });
  });

  group('FND-03 AppDatabase', () {
    test('schema v1 creates catalog, muscles, FTS, meta and outbox', () async {
      expect(db.schemaVersion, 2);
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
