import 'cycle.dart';

abstract interface class CycleRepository {
  // Active (not deleted) cycles, A–Z by name.
  Stream<List<Cycle>> watchAll();

  Stream<Cycle?> watchActive();

  Future<Cycle?> byId(String id);

  // Creates or updates; saving an active cycle deactivates the others in the
  // same transaction, each with its outbox row (AC5, AC13).
  Future<void> save(Cycle cycle);

  // Refuses the active cycle (AC9).
  Future<void> delete(String id);

  Future<void> restore(String id);
}

class ActiveCycleDeleteError extends StateError {
  ActiveCycleDeleteError() : super('The active cycle cannot be deleted');
}
