import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/core/clock.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/features/body/domain/body_snapshot.dart';
import 'package:repforge/features/goals/domain/goal.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/logger/domain/workout_session.dart';
import 'package:repforge/features/progress/presentation/progress_screen.dart';

import '../../helpers/app_overrides.dart';
import '../body/fake_body_repository.dart';
import '../library/library_fakes.dart';
import '../logger/fake_session_repository.dart';
import 'fake_goal_repository.dart';

DateTime d(int day, [int month = 11, int year = 2026]) =>
    DateTime.utc(year, month, day);

// e1RM = kg × 7/6 at 5 reps: 90 → 105.
WorkoutSession bench(String id, DateTime date, double kg) => WorkoutSession(
  id: id,
  name: 'W',
  exercises: const [
    SessionExercise(id: 'r', exerciseId: 'Bench_Press', name: 'Bench Press'),
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

// 84 → 83 → 82 kg, a fortnight apart: 1 kg per 14 days, so 80 kg lands on
// Dec 15 (today is Nov 24).
final falling = [
  BodySnapshot(id: 'w1', date: d(20, 10), weightKg: 84),
  BodySnapshot(id: 'w2', date: d(3), weightKg: 83),
  BodySnapshot(id: 'w3', date: d(17), weightKg: 82),
];

Goal weightGoal(
  String id, {
  double target = 80,
  DateTime? deadline,
  bool pinned = false,
  int day = 1,
}) => Goal(
  id: id,
  type: GoalType.bodyWeight,
  startValue: 84,
  target: target,
  deadline: deadline,
  pinned: pinned,
  createdAt: DateTime(2026, 10, day),
);

late FakeGoalRepository goals;

Future<void> pumpApp(
  WidgetTester tester, {
  List<Goal> initial = const [],
  List<WorkoutSession> finished = const [],
  List<BodySnapshot> body = const [],
  UnitSystem units = UnitSystem.metric,
  double textScale = 1,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  goals = FakeGoalRepository(initial);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...signedInOverrides(
          goals: goals,
          sessions: FakeSessionRepository()..finishedList.addAll(finished),
          body: FakeBodyRepository(snapshots: body),
          units: units,
        ),
        exerciseCatalogProvider.overrideWith((ref) async => LibraryCatalog()),
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 24, 8)),
      ],
      child: MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: const RepForgeApp(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> openGoals(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Progress'),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ProgressScreen.goalsKey));
  await tester.pumpAndSettle();
}
