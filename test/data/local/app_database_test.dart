import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
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
      await v1.customStatement('DROP TABLE workout_templates');
      await v1.customStatement('DROP TABLE cycles');
      await v1.customStatement('DROP TABLE schedule_days');
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

  group('WKT-01 schema v3', () {
    test('v2 -> v3 upgrade adds workout_templates and keeps data', () async {
      final dir = await Directory.systemTemp.createTemp('rf_migration');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/app.db');

      final v2 = AppDatabase(NativeDatabase(file));
      await v2.writeMeta('onboarding.done', 'true');
      await v2.customStatement('DROP TABLE workout_templates');
      await v2.customStatement('DROP TABLE cycles');
      await v2.customStatement('DROP TABLE schedule_days');
      await v2.customStatement('PRAGMA user_version = 2');
      await v2.close();

      final v3 = AppDatabase(NativeDatabase(file));
      addTearDown(v3.close);
      final names =
          (await v3
                  .customSelect(
                    "SELECT name FROM sqlite_master WHERE type = 'table'",
                  )
                  .get())
              .map((r) => r.read<String>('name'));
      expect(names, contains('workout_templates'));
      expect(await v3.readMeta('onboarding.done'), 'true');
    });
  });

  group('SCH-01 schema v4', () {
    test('v3 -> v4 upgrade adds cycles and keeps data', () async {
      final dir = await Directory.systemTemp.createTemp('rf_migration');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/app.db');

      final v3 = AppDatabase(NativeDatabase(file));
      await v3.writeMeta('workout.startersSeeded', 'true');
      await v3.customStatement('DROP TABLE cycles');
      await v3.customStatement('DROP TABLE schedule_days');
      await v3.customStatement('PRAGMA user_version = 3');
      await v3.close();

      final v4 = AppDatabase(NativeDatabase(file));
      addTearDown(v4.close);
      final names =
          (await v4
                  .customSelect(
                    "SELECT name FROM sqlite_master WHERE type = 'table'",
                  )
                  .get())
              .map((r) => r.read<String>('name'));
      expect(names, contains('cycles'));
      expect(await v4.readMeta('workout.startersSeeded'), 'true');
    });
  });

  group('SCH-02 schema v5', () {
    test('v4 -> v5 upgrade adds schedule_days and keeps data', () async {
      final dir = await Directory.systemTemp.createTemp('rf_migration');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/app.db');

      final v4 = AppDatabase(NativeDatabase(file));
      await v4.writeMeta('workout.startersSeeded', 'true');
      await v4.customStatement('DROP TABLE schedule_days');
      await v4.customStatement('ALTER TABLE cycles DROP COLUMN mode');
      await v4.customStatement('PRAGMA user_version = 4');
      await v4.close();

      final v5 = AppDatabase(NativeDatabase(file));
      addTearDown(v5.close);
      final names =
          (await v5
                  .customSelect(
                    "SELECT name FROM sqlite_master WHERE type = 'table'",
                  )
                  .get())
              .map((r) => r.read<String>('name'));
      expect(names, contains('schedule_days'));
      expect(await v5.readMeta('workout.startersSeeded'), 'true');
    });

    test('AC13 one record per cycle and calendar date', () async {
      ScheduleDaysCompanion row(String id, String cycle) =>
          ScheduleDaysCompanion.insert(
            id: Value(id),
            cycleId: cycle,
            date: DateTime.utc(2026, 11, 22),
            dayId: 'd1',
            dayIndex: 0,
            status: 'done',
            updatedAt: DateTime.utc(2026, 11, 22),
          );
      await db.into(db.scheduleDays).insert(row('a', 'c1'));
      await db.into(db.scheduleDays).insert(row('b', 'c2'));
      await expectLater(
        db.into(db.scheduleDays).insert(row('c', 'c1')),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('SCH-03 schema v6', () {
    test(
      'v5 -> v6 adds cycles.mode; existing cycles read as Rolling',
      () async {
        final dir = await Directory.systemTemp.createTemp('rf_migration');
        addTearDown(() => dir.delete(recursive: true));
        final file = File('${dir.path}/app.db');

        final v5 = AppDatabase(NativeDatabase(file));
        await v5.customStatement('ALTER TABLE cycles DROP COLUMN mode');
        await v5.customStatement(
          'INSERT INTO cycles (id, name, days, is_active, start_date, '
          "start_day_index, updated_at, sync_state) VALUES ('c1', 'PPL', '[]', "
          "1, '2026-11-23T00:00:00.000Z', 0, '2026-11-23T00:00:00.000Z', "
          "'pending')",
        );
        await v5.customStatement('PRAGMA user_version = 5');
        await v5.close();

        final v6 = AppDatabase(NativeDatabase(file));
        addTearDown(v6.close);
        final row = await v6.select(v6.cycles).getSingle();
        expect((row.name, row.mode), ('PPL', 'rolling'));
      },
    );
  });

  group('FND-03 AppDatabase', () {
    test('schema v1 creates catalog, muscles, FTS, meta and outbox', () async {
      expect(db.schemaVersion, 6);
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
