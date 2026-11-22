import 'dart:async';

import 'package:repforge/features/logger/domain/session_repository.dart';
import 'package:repforge/features/logger/domain/workout_session.dart';
import 'package:repforge/features/schedule/domain/day_record_repository.dart';

// Mirrors DriftSessionRepository's rules (WKT-02, LOG-01).
class FakeSessionRepository implements SessionRepository {
  FakeSessionRepository({
    this.days,
    WorkoutSession? active,
    Map<String, Map<int, LoggedSet>> last = const {},
  }) : _active = active,
       _last = {...last};

  final DayRecordRepository? days;
  WorkoutSession? _active;
  final Map<String, Map<int, LoggedSet>> _last;
  final finished = <WorkoutSession>[];
  Object? failWith;
  final _changes = StreamController<void>.broadcast();

  WorkoutSession? get active => _active;

  void _set(WorkoutSession? s) {
    _active = s;
    _changes.add(null);
  }

  void _fail() {
    if (failWith case final e?) throw e;
  }

  @override
  Stream<WorkoutSession?> watchActive() async* {
    yield _active;
    await for (final _ in _changes.stream) {
      yield _active;
    }
  }

  @override
  Future<String> start(WorkoutSession draft) async {
    _fail();
    if (_active case final a?) return a.id;
    _set(draft);
    return draft.id;
  }

  @override
  Future<void> logSet(String sessionId, LoggedSet set) async {
    _fail();
    _set(_active!.copyWith(sets: [..._active!.sets, set]));
  }

  @override
  Future<void> updateSet(
    String id, {
    required double kg,
    int? reps,
    int? seconds,
  }) async {
    _fail();
    _set(
      _active!.copyWith(
        sets: [
          for (final s in _active!.sets)
            s.id == id ? s.copyWith(kg: kg, reps: reps, seconds: seconds) : s,
        ],
      ),
    );
  }

  @override
  Future<void> deleteSet(String id) async {
    _fail();
    _set(
      _active!.copyWith(
        sets: [
          for (final s in _active!.sets)
            if (s.id != id) s,
        ],
      ),
    );
  }

  @override
  Future<void> setExercises(
    String sessionId,
    List<SessionExercise> rows,
  ) async {
    _fail();
    _set(_active!.copyWith(exercises: rows));
  }

  @override
  Future<Map<int, LoggedSet>> lastSets(String exerciseId) async =>
      _last[exerciseId] ?? const {};

  final Map<String, List<LoggedSet>> historyOf = {};

  @override
  Future<List<LoggedSet>> history(String exerciseId) async =>
      historyOf[exerciseId] ?? const [];

  @override
  Future<void> discard(String sessionId) async {
    _fail();
    _set(null);
  }

  @override
  Future<void> finish(String sessionId) async {
    _fail();
    final s = _active!;
    if (s.sets.isEmpty) throw NoSetsLogged();
    if ((s.cycleId, s.dayId, s.dayIndex) case (final c?, final d?, final i?)) {
      await days?.markDone(
        cycleId: c,
        date: s.date,
        dayId: d,
        dayIndex: i,
        fromWorkout: true,
      );
    }
    finished.add(s.copyWith(endedAt: DateTime.utc(2026)));
    _set(null);
  }
}
