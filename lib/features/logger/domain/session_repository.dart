import 'workout_session.dart';

class NoSetsLogged implements Exception {}

typedef ExerciseLogEntry = ({DateTime date, List<LoggedSet> sets});

abstract interface class SessionRepository {
  // The workout in progress, with its sets; null when none (AC8).
  Stream<WorkoutSession?> watchActive();

  // Starts [draft], or returns the id of the one already in progress (edge).
  Future<String> start(WorkoutSession draft);

  // In-progress writes stay on the phone; nothing is queued (NFR-10).
  Future<void> logSet(String sessionId, LoggedSet set);

  Future<void> updateSet(
    String id, {
    required double kg,
    int? reps,
    int? seconds,
  });

  Future<void> deleteSet(String id);

  // Replaces the workout copy's rows (+ Set, add, swap; AC6, AC7).
  Future<void> setExercises(String sessionId, List<SessionExercise> rows);

  // The last finished session's sets of [exerciseId] by set number (AC2).
  Future<Map<int, LoggedSet>> lastSets(String exerciseId);

  // LOG-02 AC6: every finished set of [exerciseId], oldest first.
  Future<List<LoggedSet>> history(String exerciseId);

  // EXL-01 AC1: exercises in finished workouts, most recently done first.
  Future<List<String>> recentExerciseIds({int limit = 10});

  // Re-emits when workouts change, so an open Library stays current.
  Stream<List<String>> watchRecentExerciseIds({int limit = 10});

  // EXL-02 AC7: the last [limit] finished workouts with [exerciseId], newest
  // first, each with its date and that exercise's sets.
  Future<List<ExerciseLogEntry>> exerciseLog(
    String exerciseId, {
    int limit = 5,
  });

  Future<void> discard(String sessionId);

  // LOG-03: the running rest, or null for none. Kept with the workout.
  Future<void> setRest(String sessionId, Rest? rest);

  // LOG-05: a finished workout with its sets, or null when gone.
  Future<WorkoutSession?> finished(String id);

  // LOG-05 AC5: the latest finished workout of the same template that ended
  // before [s] started, with its sets.
  Future<WorkoutSession?> previousOf(WorkoutSession s);

  // LOG-05 AC5: per exercise, its sets from the last finished workout before
  // [before] that has any.
  Future<Map<String, List<LoggedSet>>> lastBefore(
    Iterable<String> exerciseIds,
    DateTime before,
  );

  // LOG-05 AC8: finished workouts for the calendar date [date].
  Future<List<({String id, String name})>> finishedOn(DateTime date);

  // LOG-05 AC6: null or blank clears it; queued for sync with the workout.
  Future<void> setNote(String id, String? note);

  // AC9: ends it, stores each set's PR flag (LOG-02), queues it once and marks
  // its day done, together. Throws
  // [NoSetsLogged] and writes nothing when no set was logged.
  Future<void> finish(String sessionId);
}
