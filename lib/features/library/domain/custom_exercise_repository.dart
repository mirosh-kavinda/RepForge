import 'exercise.dart';

enum NameClash { none, custom, catalog }

abstract interface class CustomExerciseRepository {
  // Active ones, A–Z.
  Stream<List<Exercise>> watchAll();

  // Including deleted ones, so old workouts keep their names (AC7).
  Future<Exercise?> byId(String id);

  // Creates or updates, with its outbox row in the same transaction (AC1, AC8).
  Future<void> save(Exercise exercise);

  Future<void> delete(String id);

  Future<void> restore(String id);

  // AC2: against my active exercises (except [exceptId]) and the catalog.
  Future<NameClash> nameClash(String name, {String? exceptId});
}
