import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/clock.dart';
import '../../../core/metrics/projection.dart';
import '../../../data/local/database_provider.dart';
import '../../body/data/providers.dart';
import '../../library/data/providers.dart';
import '../../logger/data/providers.dart';
import '../../progress/data/providers.dart';
import '../domain/goal.dart';
import '../domain/goal_repository.dart';
import '../domain/goal_rules.dart';
import 'drift_goal_repository.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
GoalRepository goalRepository(Ref ref) =>
    DriftGoalRepository(ref.watch(appDatabaseProvider));

// Newest first, achieved ones included.
@riverpod
Stream<List<Goal>> goals(Ref ref) =>
    ref.watch(goalRepositoryProvider).watchAll();

// AC3, AC4: a lift's per-workout best e1RM, or body weight; oldest first.
@riverpod
Future<List<Measurement>> goalHistory(
  Ref ref,
  GoalType type,
  String? exerciseId,
) async {
  switch (type) {
    case GoalType.strength:
      // A finished workout changes it.
      ref.watch(activeSessionProvider);
      final log = await ref
          .read(sessionRepositoryProvider)
          .exerciseLog(exerciseId!, limit: null);
      return strengthHistory(log);
    case GoalType.bodyWeight:
      return weightHistory(await ref.watch(bodySnapshotsProvider.future));
  }
}

// AC4, AC5.
@riverpod
Future<GoalStatus> goalStatusOf(Ref ref, Goal goal) async => goalStatus(
  goal,
  await ref.watch(goalHistoryProvider(goal.type, goal.exerciseId).future),
  ref.watch(todayProvider),
);

// AC6: marks active goals achieved once their data reaches the target. Re-runs
// whenever goals or their data change; its own write leaves nothing to do.
@riverpod
Future<void> goalSettler(Ref ref) async {
  final all = await ref.watch(goalsProvider.future);
  final repo = ref.read(goalRepositoryProvider);
  for (final g in all.where((g) => g.isActive)) {
    final history = await ref.watch(
      goalHistoryProvider(g.type, g.exerciseId).future,
    );
    if (reachedOn(g, history) case final date?) {
      try {
        await repo.achieve(g.id, date);
      } on Object {
        // Retried on the next change.
      }
    }
  }
}

// AC10.
@riverpod
AsyncValue<Goal?> homeGoalOf(Ref ref) =>
    ref.watch(goalsProvider).whenData(homeGoal);

// AC2, edge: logged lifts that have an estimated 1RM, with the current one.
@riverpod
Future<List<({String id, String name, double current})>> goalLifts(
  Ref ref,
) async {
  final lifts = await ref.watch(loggedExercisesProvider.future);
  final histories = await Future.wait([
    for (final l in lifts)
      ref.watch(goalHistoryProvider(GoalType.strength, l.id).future),
  ]);
  return [
    for (final (i, l) in lifts.indexed)
      if (histories[i].lastOrNull case final m?)
        (id: l.id, name: l.name, current: m.value),
  ];
}

// Edge: a deleted custom exercise still has its name.
@riverpod
Future<String> goalLiftName(Ref ref, String id) async =>
    (await ref.watch(exerciseByIdProvider(id).future))?.name ??
    id.replaceAll('_', ' ');
