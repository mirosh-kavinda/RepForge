import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/ids.dart';
import '../sync/outbox_table.dart';
import '../sync/sync_state.dart';
import 'base_columns.dart';

part 'app_database.g.dart';

// EXL-03: the user's own exercises. Muscles are JSON lists of keys.
@DataClassName('CustomExerciseRow')
class CustomExercises extends Table with SyncedTable {
  TextColumn get name => text()();
  TextColumn get equipment => text()();
  TextColumn get primaryMuscles => text()();
  TextColumn get secondaryMuscles => text()();
  TextColumn get notes => text().nullable()();
}

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
@DataClassName('BodySnapshotRow')
class BodySnapshots extends Table with SyncedTable {
  DateTimeColumn get date => dateTime()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get waistCm => real().nullable()();
  RealColumn get neckCm => real().nullable()();
  RealColumn get hipCm => real().nullable()();
  RealColumn get scaleBodyFatPct => real().nullable()();
  TextColumn get activity => text().nullable()();
  // BOD-01: every result saved with it (JSON); null for onboarding ones.
  TextColumn get results => text().nullable()();
}

// WKT-01. Exercises are a JSON list, matching the Firestore template document.
@DataClassName('WorkoutTemplateRow')
class WorkoutTemplates extends Table with SyncedTable {
  TextColumn get name => text()();
  TextColumn get exercises => text()();
}

// SCH-01. Days are a JSON list of {id, workoutId|null}.
@DataClassName('CycleRow')
class Cycles extends Table with SyncedTable {
  TextColumn get name => text()();
  TextColumn get days => text()();
  BoolColumn get isActive => boolean()();
  DateTimeColumn get startDate => dateTime()();
  IntColumn get startDayIndex => integer()();
  TextColumn get mode => text().withDefault(const Constant('rolling'))();
}

// SCH-02. One per (cycle, calendar date): a cycle switched to today has its
// own today. `dayId` is the cycle row; status is done / missed / rest.
@DataClassName('ScheduleDayRow')
// SCH-05 AC7: the calendar reads all cycles by date range.
@TableIndex(name: 'schedule_days_date', columns: {#date})
class ScheduleDays extends Table with SyncedTable {
  TextColumn get cycleId => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get dayId => text()();
  IntColumn get dayIndex => integer()();
  TextColumn get status => text()();
  // SCH-04: the workout for the date when it is not the row's own, and the
  // other date of a Move.
  TextColumn get workoutId => text().nullable()();
  DateTimeColumn get linkedDate => dateTime().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {cycleId, date},
  ];
}

// LOG-01. A workout, with a copy of the rows it started from (JSON). In
// progress while ended_at is null; it gets its first outbox row on Finish
// (NFR-10: one cloud write per finished workout).
@DataClassName('SessionRow')
@TableIndex(
  name: 'workout_sessions_template_ended',
  columns: {#templateId, #endedAt},
)
class WorkoutSessions extends Table with SyncedTable {
  TextColumn get templateId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get exercises => text()();
  TextColumn get cycleId => text().nullable()();
  TextColumn get dayId => text().nullable()();
  IntColumn get dayIndex => integer().nullable()();
  // The calendar day it was started for (edge: midnight mid-workout).
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  // LOG-03: the running or paused rest (JSON), local only; Finish clears it.
  TextColumn get rest => text().nullable()();
  // LOG-05: the workout's note, written after Finish.
  TextColumn get note => text().nullable()();
}

// LOG-01. Local only: synced inside its session, never on its own.
@DataClassName('SessionSetRow')
@TableIndex(name: 'session_sets_session', columns: {#sessionId})
@TableIndex(name: 'session_sets_exercise', columns: {#exerciseId})
class SessionSets extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get rowId => text()();
  TextColumn get exerciseId => text()();
  IntColumn get setNo => integer()();
  RealColumn get kg => real()();
  IntColumn get reps => integer().nullable()();
  IntColumn get seconds => integer().nullable()();
  // LOG-02: set at Finish.
  BoolColumn get isPr => boolean().withDefault(const Constant(false))();
  DateTimeColumn get loggedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
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
    WorkoutTemplates,
    Cycles,
    ScheduleDays,
    WorkoutSessions,
    SessionSets,
    CustomExercises,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 14;

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
      if (from < 3) await m.createTable(workoutTemplates);
      if (from < 4) await m.createTable(cycles);
      if (from < 5) await m.createTable(scheduleDays);
      // v4 created cycles with mode already.
      if (from >= 4 && from < 6) await m.addColumn(cycles, cycles.mode);
      // v5 created schedule_days with these already.
      if (from >= 5 && from < 7) {
        await m.addColumn(scheduleDays, scheduleDays.workoutId);
        await m.addColumn(scheduleDays, scheduleDays.linkedDate);
      }
      if (from < 8) {
        await customStatement(
          'CREATE INDEX IF NOT EXISTS schedule_days_date '
          'ON schedule_days (date)',
        );
      }
      if (from < 9) {
        await m.createTable(workoutSessions);
        await m.createTable(sessionSets);
        await customStatement(
          'CREATE INDEX IF NOT EXISTS session_sets_session '
          'ON session_sets (session_id)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS session_sets_exercise '
          'ON session_sets (exercise_id)',
        );
      }
      // v9 created session_sets with is_pr already.
      if (from == 9) await m.addColumn(sessionSets, sessionSets.isPr);
      // v9 created workout_sessions with rest already.
      if (from == 9 || from == 10) {
        await m.addColumn(workoutSessions, workoutSessions.rest);
      }
      if (from >= 9 && from < 12 && !await _has('workout_sessions', 'note')) {
        await m.addColumn(workoutSessions, workoutSessions.note);
      }
      if (from < 13) await m.createTable(customExercises);
      if (from < 14) {
        for (final c in [
          bodySnapshots.neckCm,
          bodySnapshots.hipCm,
          bodySnapshots.scaleBodyFatPct,
          bodySnapshots.activity,
          bodySnapshots.results,
        ]) {
          if (!await _has('body_snapshots', c.name)) {
            await m.addColumn(bodySnapshots, c);
          }
        }
      }
      if (from < 12) {
        await customStatement(
          'CREATE INDEX IF NOT EXISTS workout_sessions_template_ended '
          'ON workout_sessions (template_id, ended_at)',
        );
      }
    },
  );

  Future<bool> _has(String table, String column) async => (await customSelect(
    'SELECT 1 FROM pragma_table_info(?) WHERE name = ?',
    variables: [Variable.withString(table), Variable.withString(column)],
  ).get()).isNotEmpty;

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
