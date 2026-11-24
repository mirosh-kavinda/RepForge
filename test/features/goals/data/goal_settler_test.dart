import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/clock.dart';
import 'package:repforge/features/body/domain/body_snapshot.dart';
import 'package:repforge/features/goals/data/providers.dart';
import 'package:repforge/features/goals/domain/goal.dart';
import 'package:repforge/features/logger/domain/workout_session.dart';

import '../../../helpers/app_overrides.dart';
import '../../body/fake_body_repository.dart';
import '../../logger/fake_session_repository.dart';
import '../fake_goal_repository.dart';

DateTime d(int day) => DateTime.utc(2026, 11, day);

WorkoutSession bench(String id, DateTime date, double kg) => WorkoutSession(
  id: id,
  name: 'W',
  exercises: const [
    SessionExercise(id: 'r', exerciseId: 'Bench_Press', name: 'Bench'),
  ],
  date: date,
  startedAt: date.add(const Duration(hours: 9)),
  endedAt: date.add(const Duration(hours: 10)),
  sets: [
    LoggedSet(
      id: '$id-1',
      rowId: 'r',
      exerciseId: 'Bench_Press',
      setNo: 1,
      kg: kg,
      reps: 5,
    ),
  ],
);

Future<void> settle() async {
  for (var i = 0; i < 8; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GOL-01 goal settler', () {
    test(
      'AC6 a lift reaching the target is achieved on that date, unpinned',
      () async {
        // e1RM = kg × 7/6 at 5 reps: 84 → 98, 90 → 105.
        final goals = FakeGoalRepository([
          Goal(
            id: 'g',
            type: GoalType.strength,
            exerciseId: 'Bench_Press',
            startValue: 98,
            target: 100,
            pinned: true,
            createdAt: DateTime(2026, 11, 5, 9),
          ),
        ]);
        final sessions = FakeSessionRepository()
          ..finishedList.addAll([
            bench('a', d(3), 90),
            bench('b', d(10), 84),
            bench('c', d(20), 90),
          ]);
        final container = ProviderContainer(
          overrides: [
            ...signedInOverrides(goals: goals, sessions: sessions),
            clockProvider.overrideWithValue(() => DateTime(2026, 11, 24, 8)),
          ],
        );
        addTearDown(container.dispose);
        container.listen(goalSettlerProvider, (_, _) {});
        await settle();
        final g = goals.byId('g')!;
        expect(g.achievedAt, d(20), reason: 'Nov 3 was before the goal');
        expect(g.pinned, isFalse);
      },
    );

    test(
      'AC6 a weight goal going down; not yet reached stays active',
      () async {
        final goals = FakeGoalRepository([
          Goal(
            id: 'down',
            type: GoalType.bodyWeight,
            startValue: 84,
            target: 80,
            createdAt: DateTime(2026, 11, 1),
          ),
          Goal(
            id: 'far',
            type: GoalType.bodyWeight,
            startValue: 84,
            target: 75,
            createdAt: DateTime(2026, 11, 1),
          ),
        ]);
        final container = ProviderContainer(
          overrides: [
            ...signedInOverrides(
              goals: goals,
              body: FakeBodyRepository(
                snapshots: [
                  BodySnapshot(id: 'x', date: d(10), weightKg: 82),
                  BodySnapshot(id: 'y', date: d(22), weightKg: 79.8),
                ],
              ),
            ),
            clockProvider.overrideWithValue(() => DateTime(2026, 11, 24, 8)),
          ],
        );
        addTearDown(container.dispose);
        container.listen(goalSettlerProvider, (_, _) {});
        await settle();
        expect(goals.byId('down')!.achievedAt, d(22));
        expect(goals.byId('far')!.achievedAt, isNull);
      },
    );

    test('AC10 home goal: pinned, else newest active', () async {
      final goals = FakeGoalRepository([
        Goal(
          id: 'old',
          type: GoalType.bodyWeight,
          startValue: 84,
          target: 75,
          createdAt: DateTime(2026, 11, 1),
        ),
        Goal(
          id: 'new',
          type: GoalType.bodyWeight,
          startValue: 84,
          target: 76,
          createdAt: DateTime(2026, 11, 2),
        ),
      ]);
      final container = ProviderContainer(
        overrides: [...signedInOverrides(goals: goals)],
      );
      addTearDown(container.dispose);
      container.listen(homeGoalOfProvider, (_, _) {});
      await settle();
      expect(container.read(homeGoalOfProvider).value?.id, 'new');
      await goals.pin('old');
      await settle();
      expect(container.read(homeGoalOfProvider).value?.id, 'old');
    });
  });

  group('GOL-01 review fixes', () {
    test(
      'edge data dropping back below the target keeps it achieved',
      () async {
        final goals = FakeGoalRepository([
          Goal(
            id: 'g',
            type: GoalType.bodyWeight,
            startValue: 84,
            target: 80,
            createdAt: DateTime(2026, 11, 1),
            achievedAt: d(10),
          ),
        ]);
        final container = ProviderContainer(
          overrides: [
            ...signedInOverrides(
              goals: goals,
              body: FakeBodyRepository(
                snapshots: [BodySnapshot(id: 'x', date: d(20), weightKg: 83)],
              ),
            ),
            clockProvider.overrideWithValue(() => DateTime(2026, 11, 24, 8)),
          ],
        );
        addTearDown(container.dispose);
        container.listen(goalSettlerProvider, (_, _) {});
        await settle();
        expect(goals.byId('g')!.achievedAt, d(10));
      },
    );
  });
}
