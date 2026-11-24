import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../data/local/app_database.dart';
import '../../../data/sync/sync_state.dart';
import '../../../data/sync/synced_writer.dart';
import '../../schedule/domain/day_record_repository.dart';
import '../../workout/domain/workout_template.dart';
import '../domain/ghost.dart';
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
        'restSec': r.restSec,
        'superset': r.superset,
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
        restSec: (j['restSec'] as int?) ?? 120,
        superset: j['superset'] as String?,
      ),
  ];

  static String? _encodeRest(Rest? r) => r == null
      ? null
      : jsonEncode({
          'endsAt': r.endsAt?.toUtc().toIso8601String(),
          'pausedLeftMs': r.pausedLeftMs,
          'nextRowId': r.nextRowId,
          'nextSetNo': r.nextSetNo,
        });

  static Rest? _decodeRest(String? json) {
    if (json == null) return null;
    final j = jsonDecode(json) as Map<String, Object?>;
    return Rest(
      endsAt: switch (j['endsAt']) {
        final String s => DateTime.parse(s),
        _ => null,
      },
      pausedLeftMs: j['pausedLeftMs'] as int?,
      nextRowId: j['nextRowId'] as String?,
      nextSetNo: j['nextSetNo'] as int?,
    );
  }

  static LoggedSet _set(SessionSetRow r) => LoggedSet(
    id: r.id,
    rowId: r.rowId,
    exerciseId: r.exerciseId,
    setNo: r.setNo,
    kg: r.kg,
    reps: r.reps,
    seconds: r.seconds,
    isPr: r.isPr,
  );

  SimpleSelectStatement<$WorkoutSessionsTable, SessionRow> _inProgress() =>
      _db.select(_db.workoutSessions)
        ..where((s) => s.endedAt.isNull() & s.deletedAt.isNull())
        ..limit(1);

  Future<WorkoutSession?> _readActive() async {
    final r = await _inProgress().getSingleOrNull();
    return r == null ? null : _read(r);
  }

  Future<WorkoutSession> _read(SessionRow r) async {
    final sets =
        await (_db.select(_db.sessionSets)
              ..where((s) => s.sessionId.equals(r.id))
              ..orderBy([(s) => OrderingTerm.asc(s.loggedAt)]))
            .get();
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
      endedAt: r.endedAt,
      sets: sets.map(_set).toList(),
      rest: _decodeRest(r.rest),
      note: r.note,
    );
  }

  @override
  Future<WorkoutSession?> finished(String id) async {
    final r =
        await (_db.select(_db.workoutSessions)..where(
              (s) =>
                  s.id.equals(id) &
                  s.endedAt.isNotNull() &
                  s.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    return r == null ? null : _read(r);
  }

  @override
  Future<WorkoutSession?> previousOf(WorkoutSession s) async {
    final t = s.templateId;
    if (t == null) return null;
    final r =
        await (_db.select(_db.workoutSessions)
              ..where(
                (w) =>
                    w.templateId.equals(t) &
                    w.id.equals(s.id).not() &
                    w.endedAt.isSmallerThanValue(s.startedAt) &
                    w.deletedAt.isNull(),
              )
              ..orderBy([(w) => OrderingTerm.desc(w.endedAt)])
              ..limit(1))
            .getSingleOrNull();
    return r == null ? null : _read(r);
  }

  @override
  Future<Map<String, List<LoggedSet>>> lastBefore(
    Iterable<String> exerciseIds,
    DateTime before,
  ) async {
    final out = <String, List<LoggedSet>>{};
    for (final exerciseId in exerciseIds.toSet()) {
      // NFR-01: pick the workout in SQL, then read only its sets.
      final latest =
          await (_db.selectOnly(_db.sessionSets).join([
                  innerJoin(
                    _db.workoutSessions,
                    _db.workoutSessions.id.equalsExp(_db.sessionSets.sessionId),
                    useColumns: false,
                  ),
                ])
                ..addColumns([_db.sessionSets.sessionId])
                ..where(
                  _db.sessionSets.exerciseId.equals(exerciseId) &
                      _db.workoutSessions.endedAt.isSmallerThanValue(before) &
                      _db.workoutSessions.deletedAt.isNull(),
                )
                ..orderBy([OrderingTerm.desc(_db.workoutSessions.endedAt)])
                ..limit(1))
              .map((r) => r.read(_db.sessionSets.sessionId))
              .getSingleOrNull();
      if (latest == null) continue;
      final rows =
          await (_db.select(_db.sessionSets)
                ..where(
                  (x) =>
                      x.sessionId.equals(latest) &
                      x.exerciseId.equals(exerciseId),
                )
                ..orderBy([(x) => OrderingTerm.asc(x.loggedAt)]))
              .get();
      out[exerciseId] = rows.map(_set).toList();
    }
    return out;
  }

  @override
  Future<List<({String id, String name})>> finishedOn(DateTime date) async {
    final rows =
        await (_db.select(_db.workoutSessions)
              ..where(
                (w) =>
                    w.date.equals(date) &
                    w.endedAt.isNotNull() &
                    w.deletedAt.isNull(),
              )
              ..orderBy([(w) => OrderingTerm.asc(w.startedAt)]))
            .get();
    return [for (final r in rows) (id: r.id, name: r.name)];
  }

  @override
  Future<void> setNote(String id, String? note) => _db.transaction(() async {
    final text = note?.trim();
    final finished =
        await (_db.select(_db.workoutSessions)..where(
              (r) =>
                  r.id.equals(id) &
                  r.endedAt.isNotNull() &
                  r.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (finished == null) return;
    Future<void> write(DateTime now) =>
        (_db.update(_db.workoutSessions)..where((r) => r.id.equals(id))).write(
          WorkoutSessionsCompanion(
            note: Value(text == null || text.isEmpty ? null : text),
            updatedAt: Value(now),
          ),
        );
    // NFR-10: while the Finish create is still queued, the note rides in it.
    final queued =
        await (_db.select(_db.outbox)..where(
              (o) =>
                  o.entity.equals(_entity) &
                  o.entityId.equals(id) &
                  o.op.equalsValue(OutboxOp.create),
            ))
            .get();
    if (queued.isNotEmpty) return write(_now().toUtc());
    await _writer.run(
      table: _table,
      entity: _entity,
      id: id,
      op: OutboxOp.update,
      write: write,
    );
  });

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
  Future<void> setRest(String sessionId, Rest? rest) =>
      (_db.update(_db.workoutSessions)..where((s) => s.id.equals(sessionId)))
          .write(WorkoutSessionsCompanion(rest: Value(_encodeRest(rest))));

  @override
  Future<List<LoggedSet>> history(String exerciseId) async {
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
          ..orderBy([OrderingTerm.asc(_db.sessionSets.loggedAt)]);
    return [for (final r in await q.get()) _set(r.readTable(_db.sessionSets))];
  }

  @override
  Stream<List<String>> watchRecentExerciseIds({int limit = 10}) => _db
      .customSelect(
        'SELECT 1',
        readsFrom: {_db.workoutSessions, _db.sessionSets},
      )
      .watch()
      .asyncMap((_) => recentExerciseIds(limit: limit));

  @override
  Future<List<String>> recentExerciseIds({int limit = 10}) async {
    final last = _db.workoutSessions.endedAt.max();
    final q =
        _db.selectOnly(_db.sessionSets).join([
            innerJoin(
              _db.workoutSessions,
              _db.workoutSessions.id.equalsExp(_db.sessionSets.sessionId),
              useColumns: false,
            ),
          ])
          ..addColumns([_db.sessionSets.exerciseId, last])
          ..where(
            _db.workoutSessions.endedAt.isNotNull() &
                _db.workoutSessions.deletedAt.isNull(),
          )
          ..groupBy([_db.sessionSets.exerciseId])
          ..orderBy([OrderingTerm.desc(last)])
          ..limit(limit);
    return [for (final r in await q.get()) r.read(_db.sessionSets.exerciseId)!];
  }

  @override
  Future<List<ExerciseLogEntry>> exerciseLog(
    String exerciseId, {
    int? limit = 5,
    DateTime? since,
  }) async {
    final ended = _db.workoutSessions.endedAt.max();
    var where =
        _db.sessionSets.exerciseId.equals(exerciseId) &
        _db.workoutSessions.endedAt.isNotNull() &
        _db.workoutSessions.deletedAt.isNull();
    if (since != null) {
      where = where & _db.workoutSessions.date.isBiggerOrEqualValue(since);
    }
    final ids =
        await (_db.selectOnly(_db.sessionSets).join([
                innerJoin(
                  _db.workoutSessions,
                  _db.workoutSessions.id.equalsExp(_db.sessionSets.sessionId),
                  useColumns: false,
                ),
              ])
              ..addColumns([_db.sessionSets.sessionId, ended])
              ..where(where)
              ..groupBy([_db.sessionSets.sessionId])
              ..orderBy([OrderingTerm.desc(ended)])
              // SQLite reads a negative LIMIT as none.
              ..limit(limit ?? -1))
            .map((r) => r.read(_db.sessionSets.sessionId)!)
            .get();
    if (ids.isEmpty) return const [];
    // One query for every listed workout's sets (NFR-01), grouped in Dart.
    final rows =
        await (_db.select(_db.sessionSets).join([
                innerJoin(
                  _db.workoutSessions,
                  _db.workoutSessions.id.equalsExp(_db.sessionSets.sessionId),
                ),
              ])
              ..where(
                _db.sessionSets.sessionId.isIn(ids) &
                    _db.sessionSets.exerciseId.equals(exerciseId),
              )
              ..orderBy([OrderingTerm.asc(_db.sessionSets.loggedAt)]))
            .get();
    final dates = <String, DateTime>{};
    final sets = <String, List<LoggedSet>>{};
    for (final r in rows) {
      final w = r.readTable(_db.workoutSessions);
      dates[w.id] = w.date;
      (sets[w.id] ??= []).add(_set(r.readTable(_db.sessionSets)));
    }
    return [for (final id in ids) (date: dates[id]!, sets: sets[id]!)];
  }

  Expression<bool> get _finished =>
      _db.workoutSessions.endedAt.isNotNull() &
      _db.workoutSessions.deletedAt.isNull();

  Join<HasResultSet, dynamic> get _session => innerJoin(
    _db.workoutSessions,
    _db.workoutSessions.id.equalsExp(_db.sessionSets.sessionId),
    useColumns: false,
  );

  @override
  Future<Map<String, int>> exerciseSetCounts() async {
    final n = _db.sessionSets.id.count();
    final q = _db.selectOnly(_db.sessionSets).join([_session])
      ..addColumns([_db.sessionSets.exerciseId, n])
      ..where(_finished)
      ..groupBy([_db.sessionSets.exerciseId]);
    return {
      for (final r in await q.get())
        r.read(_db.sessionSets.exerciseId)!: r.read(n)!,
    };
  }

  @override
  Future<List<({DateTime date, LoggedSet set})>> finishedSetsSince(
    DateTime? from,
  ) async {
    final q =
        _db.select(_db.sessionSets).join([
          innerJoin(
            _db.workoutSessions,
            _db.workoutSessions.id.equalsExp(_db.sessionSets.sessionId),
          ),
        ])..where(
          from == null
              ? _finished
              : _finished & _db.workoutSessions.date.isBiggerOrEqualValue(from),
        );
    return [
      for (final r in await q.get())
        (
          date: r.readTable(_db.workoutSessions).date,
          set: _set(r.readTable(_db.sessionSets)),
        ),
    ];
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
    final sets =
        await (_db.select(_db.sessionSets)
              ..where((r) => r.sessionId.equals(sessionId))
              ..orderBy([(r) => OrderingTerm.asc(r.loggedAt)]))
            .get();
    for (final exerciseId in {for (final r in sets) r.exerciseId}) {
      final mine = [
        for (final r in sets)
          if (r.exerciseId == exerciseId) _set(r),
      ];
      final prs = prSets(mine, await history(exerciseId));
      if (prs.isEmpty) continue;
      await (_db.update(_db.sessionSets)..where((r) => r.id.isIn(prs))).write(
        SessionSetsCompanion(
          isPr: const Value(true),
          updatedAt: Value(_now().toUtc()),
        ),
      );
    }
    await _writer.run(
      table: _table,
      entity: _entity,
      id: sessionId,
      op: OutboxOp.create,
      write: (now) =>
          (_db.update(
            _db.workoutSessions,
          )..where((r) => r.id.equals(sessionId))).write(
            WorkoutSessionsCompanion(
              endedAt: Value(now),
              rest: const Value(null),
            ),
          ),
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
