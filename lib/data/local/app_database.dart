import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/ids.dart';
import '../sync/outbox_table.dart';
import '../sync/sync_state.dart';
import 'base_columns.dart';

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

// ONB-01. Enum values are stored by name; the onboarding repository maps them.
class UserProfiles extends Table with SyncedTable {
  TextColumn get goal => text().nullable()();
  TextColumn get level => text().nullable()();
  TextColumn get units => text()();
  TextColumn get sex => text().nullable()();
  IntColumn get birthYear => integer().nullable()();
  RealColumn get heightCm => real().nullable()();
  TextColumn get activityLevel => text().nullable()();
}

// ONB-01 creates it with weight and waist; BOD-01 adds the other measurements.
class BodySnapshots extends Table with SyncedTable {
  DateTimeColumn get date => dateTime()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get waistCm => real().nullable()();
}

const catalogVersionKey = 'catalogVersion';

@DriftDatabase(
  tables: [
    CatalogExercises,
    ExerciseMuscles,
    AppMeta,
    Outbox,
    UserProfiles,
    BodySnapshots,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

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
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(userProfiles);
        await m.createTable(bodySnapshots);
      }
    },
  );

  Future<String?> readMeta(String key) async => (await (select(
    appMeta,
  )..where((m) => m.key.equals(key))).getSingleOrNull())?.value;

  Future<void> writeMeta(String key, String value) => into(
    appMeta,
  ).insertOnConflictUpdate(AppMetaCompanion.insert(key: key, value: value));

  Future<void> deleteMeta(String key) =>
      (delete(appMeta)..where((m) => m.key.equals(key))).go();

  Stream<String?> watchMeta(String key) => (select(
    appMeta,
  )..where((m) => m.key.equals(key))).watchSingleOrNull().map((m) => m?.value);
}

AppDatabase openAppDatabase() => AppDatabase(driftDatabase(name: 'repforge'));
