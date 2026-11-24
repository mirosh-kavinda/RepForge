import 'package:drift/drift.dart';

import '../local/app_database.dart';

typedef Json = Map<String, Object?>;

typedef FromJson<R> =
    R Function(Map<String, dynamic> json, {ValueSerializer? serializer});

// Drift's JSON, but epoch ms come back as UTC, as the phone stores every
// time; the default would give local times, and a UTC-midnight date would
// read as the day before west of Greenwich.
class UtcSerializer implements ValueSerializer {
  const UtcSerializer();

  static const _base = ValueSerializer.defaults();

  @override
  T fromJson<T>(dynamic json) {
    if (json is int && _isDate<T>()) {
      return DateTime.fromMillisecondsSinceEpoch(json, isUtc: true) as T;
    }
    return _base.fromJson<T>(json);
  }

  @override
  dynamic toJson<T>(T value) => _base.toJson<T>(value);

  static bool _isDate<T>() => <T>[] is List<DateTime?>;
}

const utc = UtcSerializer();

// SYN-01: one synced table as cloud documents. Values use Drift's JSON form
// (dates as epoch ms); syncState never leaves the phone.
class SyncCodec<T extends Table, R extends DataClass> {
  SyncCodec({
    required this.entity,
    required this.collection,
    required this.table,
    required this.fromJson,
    this.localOnly = const {},
    this.bodyFields = const {},
  });

  // The outbox entity name.
  final String entity;
  final String collection;
  final TableInfo<T, R> table;
  final FromJson<R> fromJson;
  // Kept on the phone (LOG-03: a running rest).
  final Set<String> localOnly;
  // AC7: held back while body backup is off.
  final Set<String> bodyFields;

  static const _local = {'syncState'};

  Future<Json?> readLocal(AppDatabase db, String id) async {
    final rows = await db
        .customSelect(
          'SELECT * FROM "${table.actualTableName}" WHERE id = ?',
          variables: [Variable.withString(id)],
          readsFrom: {table},
        )
        .get();
    if (rows.isEmpty) return null;
    return (await table.map(rows.single.data)).toJson();
  }

  // The document for [id], or null when the row is gone.
  Future<Json?> toRemote(
    AppDatabase db,
    String id, {
    required bool withBody,
  }) async {
    final row = await readLocal(db, id);
    if (row == null) return null;
    return {
      for (final MapEntry(:key, :value) in row.entries)
        if (!_local.contains(key) &&
            !localOnly.contains(key) &&
            (withBody || !bodyFields.contains(key)))
          key: value,
      ...await extraOut(db, id),
    };
  }

  // The stored updated_at, as SQLite holds it: the "synced" mark compares
  // against it exactly (microseconds included).
  Future<Object?> rawUpdatedAt(AppDatabase db, String id) async {
    final rows = await db
        .customSelect(
          'SELECT updated_at FROM "${table.actualTableName}" WHERE id = ?',
          variables: [Variable.withString(id)],
          readsFrom: {table},
        )
        .get();
    return rows.isEmpty ? null : rows.single.data['updated_at'];
  }

  // Which cloud fields may replace local ones; all by default.
  bool takes(String key, Json? local) => true;

  // Before writing a pulled row: clears whatever else holds its unique key.
  Future<void> beforeApply(AppDatabase db, String id, Json remote) async {}

  // Writes a pulled document over the local row; fields the cloud doesn't
  // have (held-back body data, local-only state) keep their local values.
  Future<void> apply(AppDatabase db, String id, Json remote) async {
    final local = await readLocal(db, id);
    final merged = <String, dynamic>{
      ...?local,
      for (final MapEntry(:key, :value) in remote.entries)
        if (!localOnly.contains(key) &&
            !extraKeys.contains(key) &&
            key != 'syncedAt' &&
            takes(key, local))
          key: value,
      'id': id,
      'syncState': 'synced',
    };
    for (final k in localOnly) {
      merged.putIfAbsent(k, () => null);
    }
    await beforeApply(db, id, remote);
    await db
        .into(table)
        .insertOnConflictUpdate(
          fromJson(merged, serializer: utc) as Insertable<R>,
        );
    await extraIn(db, id, remote, local);
  }

  // Hooks for documents that carry child rows (sessions and their sets).
  Set<String> get extraKeys => const {};

  Future<Json> extraOut(AppDatabase db, String id) async => const {};

  Future<void> extraIn(
    AppDatabase db,
    String id,
    Json remote,
    Json? local,
  ) async {}
}

// AC3: a finished workout is one document with all its sets.
class SessionCodec extends SyncCodec<$WorkoutSessionsTable, SessionRow> {
  SessionCodec(AppDatabase db)
    : super(
        entity: 'session',
        collection: 'sessions',
        table: db.workoutSessions,
        fromJson: SessionRow.fromJson,
        localOnly: const {'rest'},
      );

  @override
  Set<String> get extraKeys => const {'sets'};

  // AC5: once finished here, only its note and deletion follow the cloud.
  static const _free = {'note', 'updatedAt', 'deletedAt'};

  static bool _finished(Json? local) => local?['endedAt'] != null;

  @override
  bool takes(String key, Json? local) =>
      !_finished(local) || _free.contains(key);

  @override
  Future<Json> extraOut(AppDatabase db, String id) async {
    final sets =
        await (db.select(db.sessionSets)
              ..where((s) => s.sessionId.equals(id))
              // Stable, so a resend never looks like changed sets.
              ..orderBy([
                (s) => OrderingTerm.asc(s.loggedAt),
                (s) => OrderingTerm.asc(s.id),
              ]))
            .get();
    return {
      'sets': [for (final s in sets) s.toJson()],
    };
  }

  @override
  Future<void> extraIn(
    AppDatabase db,
    String id,
    Json remote,
    Json? local,
  ) async {
    final sets = remote['sets'];
    if (sets is! List || _finished(local)) return;
    await db.batch((b) {
      b.insertAllOnConflictUpdate(db.sessionSets, [
        for (final s in sets)
          SessionSetRow.fromJson(
            Map<String, dynamic>.from(s as Map),
            serializer: utc,
          ),
      ]);
    });
  }
}

// One record per (cycle, date) (SCH-02): two phones can each make one for
// the same day; the pulled, newer one takes the key.
class ScheduleDayCodec extends SyncCodec<$ScheduleDaysTable, ScheduleDayRow> {
  ScheduleDayCodec(AppDatabase db)
    : super(
        entity: 'scheduleDay',
        collection: 'scheduleDays',
        table: db.scheduleDays,
        fromJson: ScheduleDayRow.fromJson,
      );

  @override
  Future<void> beforeApply(AppDatabase db, String id, Json remote) async {
    final cycleId = remote['cycleId'];
    final date = remote['date'];
    if (cycleId is! String || date is! int) return;
    await (db.delete(db.scheduleDays)..where(
          (d) =>
              d.cycleId.equals(cycleId) &
              d.date.equals(
                DateTime.fromMillisecondsSinceEpoch(date, isUtc: true),
              ) &
              d.id.equals(id).not(),
        ))
        .go();
  }
}

// Every synced table, by outbox entity. Profile body fields follow AUTH-01's
// body-metrics backup choice (AC7).
Map<String, SyncCodec> syncCodecs(AppDatabase db) => {
  for (final c in <SyncCodec>[
    SyncCodec<$UserProfilesTable, UserProfile>(
      entity: 'userProfile',
      collection: 'profile',
      table: db.userProfiles,
      fromJson: UserProfile.fromJson,
      bodyFields: const {'sex', 'birthYear', 'heightCm', 'activityLevel'},
    ),
    SyncCodec<$BodySnapshotsTable, BodySnapshotRow>(
      entity: 'bodySnapshot',
      collection: 'bodySnapshots',
      table: db.bodySnapshots,
      fromJson: BodySnapshotRow.fromJson,
    ),
    SyncCodec<$WorkoutTemplatesTable, WorkoutTemplateRow>(
      entity: 'workoutTemplate',
      collection: 'workoutTemplates',
      table: db.workoutTemplates,
      fromJson: WorkoutTemplateRow.fromJson,
    ),
    SyncCodec<$CyclesTable, CycleRow>(
      entity: 'cycle',
      collection: 'cycles',
      table: db.cycles,
      fromJson: CycleRow.fromJson,
    ),
    ScheduleDayCodec(db),
    SessionCodec(db),
    SyncCodec<$CustomExercisesTable, CustomExerciseRow>(
      entity: 'customExercise',
      collection: 'customExercises',
      table: db.customExercises,
      fromJson: CustomExerciseRow.fromJson,
    ),
    SyncCodec<$GoalsTable, GoalRow>(
      entity: 'goal',
      collection: 'goals',
      table: db.goals,
      fromJson: GoalRow.fromJson,
    ),
  ])
    c.entity: c,
};

// Body snapshots are body data in whole (AC7).
const bodyEntities = {'bodySnapshot'};
