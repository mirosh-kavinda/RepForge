import 'goal.dart';

abstract interface class GoalRepository {
  // Live goals, newest first.
  Stream<List<Goal>> watchAll();

  // Creates a goal (AC2).
  Future<void> save(Goal goal);

  // AC8: only these two, so an achievement written meanwhile is kept.
  Future<void> updateTarget(String id, double target, DateTime? deadline);

  // AC10: pins [id] and unpins every other goal, together.
  Future<void> pin(String id);

  Future<void> unpin(String id);

  // AC6, AC7: achieved on [date], and unpinned.
  Future<void> achieve(String id, DateTime date);

  // AC9.
  Future<void> delete(String id);

  // Restores unpinned, so only one goal is ever pinned (AC10).
  Future<void> restore(String id);
}
