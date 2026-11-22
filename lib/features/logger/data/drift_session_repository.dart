import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../data/local/app_database.dart';
import '../../../data/sync/sync_state.dart';
import '../../../data/sync/synced_writer.dart';
import '../../schedule/domain/day_record_repository.dart';
import '../../workout/domain/workout_template.dart';
import '../domain/session_repository.dart';
import '../domain/workout_session.dart';

class DriftSessionRepository implements SessionRepository {
  DriftSessionRepository(this._db, this._days, {DateTime Function()? now})
    : _now = now ?? DateTime.now,
      _writer = SyncedWriter(_db, now: now);

  static const _table = 'workout_sessions';
  static const _entity = 'session';

  final AppDatabase _db;
  final DayRecordRepository _days;
  final DateTime Function() _now;
  final SyncedWriter _writer;

  static String _encode(List<SessionExercise> rows) => jsonEncode([
    for (final r in rows)
      {
        'id': r.id,
        'exerciseId': r.exerciseId,
        'name': r.name,
        'plannedSets': r.plannedSets,
        'kind': r.kind.name,
        'repMin': r.repMin,
        'repMax': r.repMax,
        'seconds': r.seconds,
        'targetKg': r.targetKg,
        'bodyweight': r.bodyweight,
      },
  ]);

  static List<SessionExercise> _decode(String json) => [
    for (final j in (jsonDecode(json) as List).cast<Map<String, Object?>>())
      SessionExercise(
        id: j['id']! as String,
        exerciseId: j['exerciseId']! as String,
        name: j['name']! as String,
        plannedSets: j['plannedSets']! as int,
        kind: TargetKind.values.byName(j['kind']! as String),
        repMin: j['repMin']! as int,
        repMax: j['repMax']! as int,
        seconds: j['seconds']! as int,
        targetKg: (j['targetKg'] as num?)?.toDouble(),
        bodyweight: j['bodyweight']! as bool,
      ),
  ];

  static LoggedSet _set(SessionSetRow r) => LoggedSet(
    id: r.id,
    rowId: r.rowId,
    exerciseId: r.exerciseId,
    setNo: r.setNo,
    kg: r.kg,
    reps: r.reps,
    seconds: r.seconds,
  );

  SimpleSelectStatement<$WorkoutSessionsTable, SessionRow> _inProgress() =>
      _db.select(_db.workoutSessions)
        ..where((s) => s.endedAt.isNull() & s.deletedAt.isNull())
        ..limit(1);

  Future<WorkoutSession?> _readActive() async {
    final r = await _inProgress().getSingleOrNull();
    if (r == null) return null;
    final sets = await (_db.select(
      _db.sessionSets,
    )..where((s) => s.sessionId.equals(r.id))).get();
    return WorkoutSession(
      id: r.id,
      name: r.name,
      templateId: r.templateId,
      exercises: _decode(r.exercises),
      date: r.date,
      startedAt: r.startedAt,
      cycleId: r.cycleId,
      dayId: r.dayId,
      dayIndex: r.dayIndex,
      sets: sets.map(_set).toList(),
    );
  }

  @override
  Stream<WorkoutSession?> watchActive() => _db
      .customSelect(
        'SELECT 1',
        readsFrom: {_db.workoutSessions, _db.sessionSets},
      )
      .watch()
      .asyncMap((_) => _readActive());

  @override
  Future<String> start(WorkoutSession d) => _db.transaction(() async {
    if (await _inProgress().getSingleOrNull() case final r?) return r.id;
    await _db
        .into(_db.workoutSessions)
        .insert(
          WorkoutSessionsCompanion.insert(
            id: Value(d.id),
            templateId: Value(d.templateId),
            name: d.name,
            exercises: _encode(d.exercises),
            cycleId: Value(d.cycleId),
            dayId: Value(d.dayId),
            dayIndex: Value(d.dayIndex),
            date: d.date,
            startedAt: d.startedAt,
            updatedAt: _now().toUtc(),
          ),
        );
    return d.id;
  });

  @override
  Future<void> logSet(String sessionId, LoggedSet s) => _db
      .into(_db.sessionSets)
      .insert(
        SessionSetsCompanion.insert(
          id: s.id,
          sessionId: sessionId,
          rowId: s.rowId,
          exerciseId: s.exerciseId,
          setNo: s.setNo,
          kg: s.kg,
          reps: Value(s.reps),
          seconds: Value(s.seconds),
          loggedAt: _now().toUtc(),
          updatedAt: _now().toUtc(),
        ),
      );

  @override
  Future<void> updateSet(
    String id, {
    required double kg,
    int? reps,
    int? seconds,
  }) => (_db.update(_db.sessionSets)..where((s) => s.id.equals(id))).write(
    SessionSetsCompanion(
      kg: Value(kg),
      reps: Value(reps),
      seconds: Value(seconds),
      updatedAt: Value(_now().toUtc()),
    ),
  );

  @override
  Future<void> deleteSet(String id) =>
      (_db.delete(_db.sessionSets)..where((s) => s.id.equals(id))).go();

  @override
  Future<void> setExercises(String sessionId, List<SessionExercise> rows) =>
      (_db.update(
        _db.workoutSessions,
      )..where((s) => s.id.equals(sessionId))).write(
        WorkoutSessionsCompanion(
          exercises: Value(_encode(rows)),
          updatedAt: Value(_now().toUtc()),
        ),
      );

  @override
  Future<Map<int, LoggedSet>> lastSets(String exerciseId) async {
    final q =
        _db.select(_db.sessionSets).join([
            innerJoin(
              _db.workoutSessions,
              _db.workoutSessions.id.equalsExp(_db.sessionSets.sessionId),
            ),
          ])
          ..where(
            _db.sessionSets.exerciseId.equals(exerciseId) &
                _db.workoutSessions.endedAt.isNotNull() &
                _db.workoutSessions.deletedAt.isNull(),
          )
          ..orderBy([
            OrderingTerm.desc(_db.workoutSessions.endedAt),
            OrderingTerm.desc(_db.workoutSessions.date),
            OrderingTerm.desc(_db.workoutSessions.startedAt),
            OrderingTerm.asc(_db.sessionSets.loggedAt),
          ]);
    final rows = [for (final r in await q.get()) r.readTable(_db.sessionSets)];
    if (rows.isEmpty) return const {};
    final latest = rows.first.sessionId;
    // The first row of that exercise in that session, if it appears twice.
    final rowId = rows.first.rowId;
    return {
      for (final r in rows)
        if (r.sessionId == latest && r.rowId == rowId) r.setNo: _set(r),
    };
  }

  @override
  Future<void> discard(String sessionId) => _db.transaction(() async {
    await (_db.delete(
      _db.sessionSets,
    )..where((s) => s.sessionId.equals(sessionId))).go();
    await (_db.delete(
      _db.workoutSessions,
    )..where((s) => s.id.equals(sessionId))).go();
  });

  @override
  Future<void> finish(String sessionId) => _db.transaction(() async {
    final s = await (_db.select(
      _db.workoutSessions,
    )..where((r) => r.id.equals(sessionId))).getSingle();
    final count =
        await (_db.selectOnly(_db.sessionSets)
              ..addColumns([_db.sessionSets.id.count()])
              ..where(_db.sessionSets.sessionId.equals(sessionId)))
            .map((r) => r.read(_db.sessionSets.id.count()))
            .getSingle();
    if ((count ?? 0) == 0) throw NoSetsLogged();
    await _writer.run(
      table: _table,
      entity: _entity,
      id: sessionId,
      op: OutboxOp.create,
      write: (now) =>
          (_db.update(_db.workoutSessions)
                ..where((r) => r.id.equals(sessionId)))
              .write(WorkoutSessionsCompanion(endedAt: Value(now))),
    );
    if ((s.cycleId, s.dayId, s.dayIndex) case (
      final cycleId?,
      final dayId?,
      final dayIndex?,
    )) {
      await _days.markDone(
        cycleId: cycleId,
        date: s.date,
        dayId: dayId,
        dayIndex: dayIndex,
        fromWorkout: true,
      );
    }
  });
}
