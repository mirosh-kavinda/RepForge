import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../sync/outbox_table.dart';
import '../sync/sync_state.dart';

part 'app_database.g.dart';

class CatalogExercises extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get equipment => text()();
  TextColumn get category => text()();
  TextColumn get level => text()();
  TextColumn get mechanic => text().nullable()();
  TextColumn get force => text().nullable()();
  TextColumn get instructions => text()();
  TextColumn get images => text()();
  TextColumn get contentHash => text()();
  DateTimeColumn get retiredAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@TableIndex(name: 'exercise_muscles_muscle', columns: {#muscle})
class ExerciseMuscles extends Table {
  TextColumn get exerciseId => text().references(CatalogExercises, #id)();
  TextColumn get muscle => text()();
  BoolColumn get isPrimary => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {exerciseId, muscle};
}

class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(tables: [CatalogExercises, ExerciseMuscles, AppMeta, Outbox])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        'CREATE VIRTUAL TABLE exercise_fts USING fts5(name, '
        "content='catalog_exercises', content_rowid='rowid', "
        "tokenize='unicode61 remove_diacritics 2')",
      );
    },
  );

  Future<String?> readMeta(String key) async => (await (select(
    appMeta,
  )..where((m) => m.key.equals(key))).getSingleOrNull())?.value;

  Future<void> writeMeta(String key, String value) => into(
    appMeta,
  ).insertOnConflictUpdate(AppMetaCompanion.insert(key: key, value: value));
}

AppDatabase openAppDatabase() => AppDatabase(driftDatabase(name: 'repforge'));
