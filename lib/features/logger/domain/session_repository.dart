import 'workout_session.dart';

class NoSetsLogged implements Exception {}

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

  Future<void> discard(String sessionId);

  // AC9: ends it, stores each set's PR flag (LOG-02), queues it once and marks
  // its day done, together. Throws
  // [NoSetsLogged] and writes nothing when no set was logged.
  Future<void> finish(String sessionId);
}
