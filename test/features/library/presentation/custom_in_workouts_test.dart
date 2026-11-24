import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/app/router.dart';
import 'package:repforge/core/clock.dart';
import 'package:repforge/features/home/presentation/today_card.dart';
import 'package:repforge/features/library/data/combined_catalog.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/library/domain/exercise.dart';
import 'package:repforge/features/logger/presentation/logger_screen.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';
import 'package:repforge/features/workout/data/providers.dart';
import 'package:repforge/features/workout/domain/workout_template.dart';

import '../../../helpers/app_overrides.dart';
import '../../logger/fake_session_repository.dart';
import '../../schedule/fake_cycle_repository.dart';
import '../../schedule/fake_day_record_repository.dart';
import '../../workout/fakes.dart';
import '../fake_custom_exercise_repository.dart';
import '../library_fakes.dart';

const legs = WorkoutTemplate(
  id: 'legs',
  name: 'Legs',
  exercises: [TemplateExercise(id: 't1', exerciseId: 'c1', sets: 2)],
);

final cycle = Cycle(
  id: 'c1',
  name: 'Legs only',
  days: const [CycleDay(id: 'd1', workoutId: 'legs')],
  isActive: true,
  startDate: DateTime.utc(2026, 11, 23),
  startDayIndex: 0,
);

final hack = ex('c1', 'Hack Squat', [
  Muscle.quadriceps,
], equipment: Equipment.machine).copyWith(custom: true);

late FakeCustomExerciseRepository custom;
late FakeSessionRepository sessions;

Future<ProviderContainer> pumpApp(WidgetTester tester) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  final days = FakeDayRecordRepository();
  sessions = FakeSessionRepository(days: days);
  custom = FakeCustomExerciseRepository([hack]);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...signedInOverrides(
          templates: FakeTemplateRepository([legs]),
          cycles: FakeCycleRepository([cycle]),
          days: days,
          sessions: sessions,
          custom: custom,
        ),
        exerciseCatalogProvider.overrideWith(
          (ref) async => CombinedCatalog(LibraryCatalog(), custom),
        ),
        clockProvider.overrideWithValue(() => DateTime.utc(2026, 11, 23, 10)),
      ],
      child: const RepForgeApp(),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(RepForgeApp)));
}

Future<void> startAndFinish(WidgetTester tester) async {
  await tester.tap(find.byKey(TodayCard.startKey));
  await tester.pumpAndSettle();
  expect(find.byType(LoggerScreen), findsOneWidget);
  expect(find.text('Hack Squat'), findsOneWidget);
  final log = find.bySemanticsLabel('Log set 1').first;
  await tester.ensureVisible(log);
  await tester.pumpAndSettle();
  await tester.tap(log);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(LoggerScreen.finishKey));
  await tester.pumpAndSettle();
}

void main() {
  group('EXL-03 custom exercises in workouts', () {
    testWidgets('AC7 a workout with a deleted one still starts and logs', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpApp(tester);
      await custom.delete('c1');
      await tester.pumpAndSettle();
      await startAndFinish(tester);
      final s = sessions.finishedList.single;
      expect(s.exercises.single.name, 'Hack Squat');
      expect(s.sets.single.exerciseId, 'c1');
      handle.dispose();
    });

    testWidgets('AC6 finished workouts keep the logged name after an edit', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpApp(tester);
      await startAndFinish(tester);
      await custom.save(hack.copyWith(name: 'Hack Squat (Gym 2)'));
      await tester.pumpAndSettle();
      expect(sessions.finishedList.single.exercises.single.name, 'Hack Squat');
      handle.dispose();
    });

    testWidgets('AC6 the template builder shows the edited name', (
      tester,
    ) async {
      final router = (await pumpApp(tester)).read(routerProvider);
      await custom.save(hack.copyWith(name: 'Hack Squat (Gym 2)'));
      router.go(Routes.workoutEdit('legs'));
      await tester.pumpAndSettle();
      expect(find.text('Hack Squat (Gym 2)'), findsOneWidget);
    });

    testWidgets('AC6 a workout\'s muscles follow an edit (Schedule tiles)', (
      tester,
    ) async {
      final container = await pumpApp(tester);
      final sub = container.listen(workoutMusclesProvider('legs'), (_, _) {});
      addTearDown(sub.close);
      await tester.pumpAndSettle();
      expect(container.read(workoutMusclesProvider('legs')).value, [
        Muscle.quadriceps,
      ]);
      await custom.save(hack.copyWith(primaryMuscles: [Muscle.chest]));
      await tester.pumpAndSettle();
      expect(container.read(workoutMusclesProvider('legs')).value, [
        Muscle.chest,
      ]);
    });
  });
}
