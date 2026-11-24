import 'dart:async';

import 'package:repforge/features/goals/domain/goal.dart';
import 'package:repforge/features/goals/domain/goal_repository.dart';

class FakeGoalRepository implements GoalRepository {
  FakeGoalRepository([List<Goal> initial = const []]) {
    for (final g in initial) {
      _all[g.id] = g;
    }
  }

  final _all = <String, Goal>{};
  final _deleted = <String>{};
  final _changes = StreamController<void>.broadcast();
  Object? failWith;

  List<Goal> get live => [
    for (final g in _all.values)
      if (!_deleted.contains(g.id)) g,
  ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Goal? byId(String id) => _all[id];

  @override
  Stream<List<Goal>> watchAll() async* {
    yield live;
    await for (final _ in _changes.stream) {
      yield live;
    }
  }

  Future<void> _change(void Function() f) async {
    if (failWith case final e?) throw e;
    f();
    _changes.add(null);
  }

  @override
  Future<void> save(Goal goal) => _change(() => _all[goal.id] = goal);

  @override
  Future<void> updateTarget(String id, double target, DateTime? deadline) =>
      _change(
        () => _all[id] = _all[id]!.copyWith(target: target, deadline: deadline),
      );

  @override
  Future<void> pin(String id) => _change(() {
    for (final g in _all.values.toList()) {
      _all[g.id] = g.copyWith(pinned: g.id == id);
    }
  });

  @override
  Future<void> unpin(String id) =>
      _change(() => _all[id] = _all[id]!.copyWith(pinned: false));

  @override
  Future<void> achieve(String id, DateTime date) => _change(
    () => _all[id] = _all[id]!.copyWith(achievedAt: date, pinned: false),
  );

  @override
  Future<void> delete(String id) => _change(() => _deleted.add(id));

  @override
  Future<void> restore(String id) => _change(() {
    _deleted.remove(id);
    _all[id] = _all[id]!.copyWith(pinned: false);
  });
}
