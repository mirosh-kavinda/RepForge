import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/data/local/local_data_wiper.dart';
import 'package:repforge/features/library/data/catalog_importer.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final seed = File('assets/exercises/seed.json').readAsStringSync();
    await CatalogImporter(db, loadSeed: () async => seed).run();
  });
  tearDown(() => db.close());

  Future<int> count(String table) async =>
      (await db.customSelect('SELECT count(*) AS c FROM $table').getSingle())
          .read<int>('c');

  group('AUTH-01 local data wipe', () {
    test(
      'AC8 AC10 wipes user data and auth keys but keeps the catalog',
      () async {
        await db.customInsert(
          'INSERT INTO outbox (entity, entity_id, op, created_at) '
          "VALUES ('note', 'n1', 'create', 0)",
        );
        await db.writeMeta('auth.choiceMade', 'true');

        await LocalDataWiper(db).wipeUserData();

        expect(await count('outbox'), 0);
        expect(await db.readMeta('auth.choiceMade'), isNull);
        expect(await count('catalog_exercises'), 876);
        expect(await count('exercise_fts'), 876);
        expect(await count('exercise_muscles'), greaterThan(0));
        expect(await db.readMeta(catalogVersionKey), isNotNull);
      },
    );

    test('AC10 every table not on the keep list is wiped by default', () {
      const kept = LocalDataWiper.keptTables;
      expect(kept, {'catalog_exercises', 'exercise_muscles', 'app_meta'});
      final wiped = db.allTables
          .map((t) => t.actualTableName)
          .where((n) => !kept.contains(n));
      expect(wiped, contains('outbox'));
    });
  });
}
