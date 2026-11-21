import 'workout_template.dart';

abstract interface class TemplateRepository {
  // Active workouts, A–Z by name.
  Stream<List<WorkoutTemplate>> watchAll();

  Future<WorkoutTemplate?> byId(String id);

  // Creates or updates, with its outbox row in the same transaction (AC13).
  Future<void> save(WorkoutTemplate template);

  Future<void> delete(String id);

  Future<void> restore(String id);

  // Seeds the starter workouts once per local user (AC12).
  Future<void> ensureStarters();
}
