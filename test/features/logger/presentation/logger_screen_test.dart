import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/app/theme/rf_scales.dart';
import 'package:repforge/core/clock.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/features/home/presentation/today_card.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/library/presentation/exercise_picker_screen.dart';
import 'package:repforge/features/logger/domain/workout_session.dart';
import 'package:repforge/features/logger/presentation/logger_screen.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';
import 'package:repforge/features/schedule/domain/day_record.dart';
import 'package:repforge/features/workout/domain/workout_template.dart';

import '../../../helpers/app_overrides.dart';
import '../../schedule/fake_cycle_repository.dart';
import '../../schedule/fake_day_record_repository.dart';
import '../../workout/fakes.dart';
import '../fake_session_repository.dart';

const legs = WorkoutTemplate(
  id: 'legs',
  name: 'Legs',
  exercises: [
    TemplateExercise(
      id: 't1',
      exerciseId: 'Barbell_Squat',
      sets: 2,
      repMin: 5,
      repMax: 8,
      targetKg: 100,
    ),
    TemplateExercise(
      id: 't2',
      exerciseId: 'Plank',
      sets: 1,
      kind: TargetKind.time,
      seconds: 40,
    ),
  ],
);

const core = WorkoutTemplate(
  id: 'core',
  name: 'Core',
  exercises: [TemplateExercise(id: 'k1', exerciseId: 'Plank', sets: 2)],
);

final cycle = Cycle(
  id: 'c1',
  name: 'Legs only',
  days: const [
    CycleDay(id: 'd1', workoutId: 'legs'),
    CycleDay(id: 'd2'),
  ],
  isActive: true,
  startDate: DateTime.utc(2026, 11, 23),
  startDayIndex: 0,
);

LoggedSet squat(int n, double kg, int reps) => LoggedSet(
  id: 'last$n',
  rowId: 'old',
  exerciseId: 'Barbell_Squat',
  setNo: n,
  kg: kg,
  reps: reps,
);

late FakeSessionRepository sessions;
late FakeDayRecordRepository days;

// Opens Home, then the logger through Start workout.
Future<void> openLogger(
  WidgetTester tester, {
  Map<String, Map<int, LoggedSet>> last = const {},
  UnitSystem units = UnitSystem.metric,
  double textScale = 1,
  bool start = true,
  WorkoutSession? active,
  List<DayRecord> records = const [],
  Map<String, List<LoggedSet>> history = const {},
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  days = FakeDayRecordRepository(records);
  sessions = FakeSessionRepository(days: days, last: last, active: active)
    ..historyOf.addAll(history);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...signedInOverrides(
          templates: FakeTemplateRepository(const [legs, core]),
          cycles: FakeCycleRepository([cycle]),
          days: days,
          sessions: sessions,
          units: units,
        ),
        exerciseCatalogProvider.overrideWith((ref) async => FakeCatalog()),
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 23, 10)),
      ],
      child: MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: const RepForgeApp(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  if (start) {
    await tester.tap(find.byKey(TodayCard.startKey));
    await tester.pumpAndSettle();
  }
}

Finder setLabel(String label) => find.bySemanticsLabel(RegExp('^$label'));

Future<void> tapSet(WidgetTester tester, String label) async {
  await tester.ensureVisible(setLabel(label));
  await tester.pumpAndSettle();
  await tester.tap(setLabel(label));
}

Future<void> logSet(WidgetTester tester, int n, {int skip = 0}) async {
  final f = find.bySemanticsLabel('Log set $n').at(skip);
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  group('WKT-02 start from Home', () {
    testWidgets("AC1 Start workout opens today's workout in one tap", (
      tester,
    ) async {
      await openLogger(tester);
      expect(find.byType(LoggerScreen), findsOneWidget);
      expect(find.text('Legs'), findsOneWidget);
      expect(find.text('Barbell Squat'), findsOneWidget);
      expect(find.text('Set 2'), findsOneWidget);
      expect(find.text('Plank'), findsOneWidget);
      final s = sessions.active!;
      expect(s.exercises.map((e) => (e.name, e.plannedSets)), [
        ('Barbell Squat', 2),
        ('Plank', 1),
      ]);
      expect(
        (s.templateId, s.cycleId, s.dayId, s.date),
        ('legs', 'c1', 'd1', DateTime.utc(2026, 11, 23)),
      );
    });

    testWidgets('AC1 a swapped day starts the swapped workout', (tester) async {
      await openLogger(
        tester,
        records: [
          DayRecord(
            id: 'p',
            cycleId: 'c1',
            date: DateTime.utc(2026, 11, 23),
            dayId: 'd1',
            dayIndex: 0,
            status: DayStatus.planned,
            workoutId: 'core',
          ),
        ],
      );
      expect(sessions.active!.name, 'Core');
      expect(sessions.active!.templateId, 'core');
      await logSet(tester, 1);
      await tester.tap(find.byKey(LoggerScreen.finishKey));
      await tester.pumpAndSettle();
      expect(
        (days.all.single.status, days.all.single.workoutId),
        (DayStatus.done, 'core'),
      );
    });

    testWidgets('AC8 leaving keeps the workout; Home offers Resume', (
      tester,
    ) async {
      await openLogger(tester);
      await logSet(tester, 1);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Resume workout'), findsOneWidget);
      expect(find.text('Start workout'), findsNothing);
      await tester.tap(find.byKey(TodayCard.startKey));
      await tester.pumpAndSettle();
      expect(sessions.active!.sets, hasLength(1));
      expect(find.text('Done'), findsOneWidget);
    });
  });

  group('LOG-01 logging sets', () {
    testWidgets('AC2 no history: template target and bottom of the range', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openLogger(tester);
      await logSet(tester, 1);
      final s = sessions.active!.sets.single;
      expect((s.kg, s.reps, s.seconds), (100.0, 5, null));
      handle.dispose();
    });

    testWidgets('AC2 LOG-02 AC5 last time drives the prefill, by set number', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openLogger(
        tester,
        last: {
          'Barbell_Squat': {1: squat(1, 110, 6), 2: squat(2, 112.5, 5)},
        },
      );
      await logSet(tester, 2);
      final s = sessions.active!.sets.single;
      expect((s.setNo, s.kg, s.reps), (2, 112.5, 6), reason: 'target: + 1 rep');
      handle.dispose();
    });

    testWidgets('AC3 one tap logs; a stepper then Log is two', (tester) async {
      final handle = tester.ensureSemantics();
      await openLogger(tester);
      await tester.tap(find.bySemanticsLabel('Increase Weight').first);
      await tester.pumpAndSettle();
      await logSet(tester, 1);
      expect(sessions.active!.sets.single.kg, 102.5);
      handle.dispose();
    });

    testWidgets('AC4 a logged set shows Done; the next gets its values', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openLogger(tester);
      await tester.tap(find.bySemanticsLabel('Increase Reps').first);
      await tester.pumpAndSettle();
      await logSet(tester, 1);
      expect(
        setLabel('Barbell Squat, Set 1, 100 kg · 6 reps, Done'),
        findsOneWidget,
      );
      await logSet(tester, 2);
      expect(sessions.active!.sets.last.reps, 6);
      handle.dispose();
    });

    testWidgets('AC5 a logged set can be changed or deleted', (tester) async {
      final handle = tester.ensureSemantics();
      await openLogger(tester);
      await logSet(tester, 1);
      await tapSet(tester, 'Barbell Squat, Set 1');
      await tester.pumpAndSettle();
      expect(find.text('Barbell Squat · Edit set 1'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Decrease Weight').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(sessions.active!.sets.single.kg, 97.5);
      await tapSet(tester, 'Barbell Squat, Set 1');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete set'));
      await tester.pumpAndSettle();
      expect(sessions.active!.sets, isEmpty);
      handle.dispose();
    });

    testWidgets('AC6 + Set adds one more set', (tester) async {
      await openLogger(tester);
      await tester.tap(find.text('+ Set').first);
      await tester.pumpAndSettle();
      expect(find.text('Set 3'), findsOneWidget);
      expect(sessions.active!.exercises.first.plannedSets, 3);
    });

    testWidgets('AC7 add and swap an exercise from the library', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openLogger(tester);
      await tester.scrollUntilVisible(
        find.byKey(LoggerScreen.addExerciseKey),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(LoggerScreen.addExerciseKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Leg Press'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ExercisePickerScreen.addKey));
      await tester.pumpAndSettle();
      expect(sessions.active!.exercises.last.name, 'Leg Press');

      await tester.scrollUntilVisible(
        find.byTooltip('Actions for Barbell Squat'),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await logSet(tester, 1);
      await tester.ensureVisible(find.byTooltip('Actions for Barbell Squat'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Actions for Barbell Squat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Swap exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Romanian Deadlift'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ExercisePickerScreen.addKey));
      await tester.pumpAndSettle();
      final rows = sessions.active!.exercises;
      expect(rows.map((r) => (r.name, r.plannedSets)).take(2), [
        ('Barbell Squat', 1),
        ('Romanian Deadlift', 1),
      ]);
      expect(sessions.active!.sets.single.exerciseId, 'Barbell_Squat');
      handle.dispose();
    });

    testWidgets('AC9 Finish saves, marks today done, back to Home', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openLogger(tester);
      await logSet(tester, 1);
      await tester.tap(find.byKey(LoggerScreen.finishKey));
      await tester.pumpAndSettle();
      expect(find.byType(LoggerScreen), findsNothing);
      expect(sessions.finished.single.sets, hasLength(1));
      expect(days.all.single.status, DayStatus.done);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Start workout'), findsNothing);
      handle.dispose();
    });

    testWidgets('AC9 Finish with no sets says so', (tester) async {
      await openLogger(tester);
      await tester.tap(find.byKey(LoggerScreen.finishKey));
      await tester.pumpAndSettle();
      expect(find.text('Log at least one set'), findsOneWidget);
      expect(find.byType(LoggerScreen), findsOneWidget);
    });

    testWidgets('AC8 Discard asks first, then removes the workout', (
      tester,
    ) async {
      await openLogger(tester);
      await tester.tap(find.byKey(LoggerScreen.menuKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard workout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep going'));
      await tester.pumpAndSettle();
      expect(sessions.active, isNotNull);
      await tester.tap(find.byKey(LoggerScreen.menuKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard workout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(sessions.active, isNull);
      expect(find.text('Start workout'), findsOneWidget);
    });

    testWidgets('edge a failed set write says so and logs nothing', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openLogger(tester);
      sessions.failWith = Exception('disk full');
      await logSet(tester, 1);
      expect(find.text("Couldn't save. Try again."), findsOneWidget);
      expect(sessions.active!.sets, isEmpty);
      handle.dispose();
    });
  });

  group('LOG-01 display', () {
    testWidgets('edge timed and bodyweight sets read in words', (tester) async {
      final handle = tester.ensureSemantics();
      await openLogger(tester);
      await tester.scrollUntilVisible(
        find.bySemanticsLabel('Log set 1').last,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await logSet(tester, 1, skip: 1);
      expect(setLabel('Plank, Set 1, 0 kg · 40 s, Done'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('edge imperial shows lb and stores kg that round-trips', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openLogger(tester, units: UnitSystem.imperial);
      await tester.tap(find.bySemanticsLabel('Increase Weight').first);
      await tester.pumpAndSettle();
      await logSet(tester, 1);
      final kg = sessions.active!.sets.single.kg;
      expect(kgToLb(kg), closeTo(225, 0.01));
      expect(
        setLabel('Barbell Squat, Set 1, 225 lb · 5 reps, Done'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('NFR-06 set rows fit at 200 % text with 48 dp controls', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openLogger(tester, textScale: 2);
      expect(tester.takeException(), isNull);
      final log = find.bySemanticsLabel('Log set 1').first;
      expect(
        tester.getSize(log).height,
        greaterThanOrEqualTo(RfSize.minTarget),
      );
      for (var i = 0; i < 6; i++) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      handle.dispose();
    });

    testWidgets('edge a bodyweight exercise reads Bodyweight, not 0 kg', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openLogger(
        tester,
        active: WorkoutSession(
          id: 's',
          name: 'Calisthenics',
          date: DateTime.utc(2026, 11, 23),
          startedAt: DateTime.utc(2026, 11, 23, 9),
          exercises: const [
            SessionExercise(
              id: 'b1',
              exerciseId: 'dips',
              name: 'Dips',
              plannedSets: 1,
              bodyweight: true,
            ),
          ],
        ),
      );
      expect(find.text('Resume workout'), findsNothing, reason: 'opened');
      expect(find.text('Bodyweight'), findsOneWidget);
      await logSet(tester, 1);
      expect(
        setLabel('Dips, Set 1, Bodyweight · 8 reps, Done'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('LOG-02 ghost, target and PR', () {
    final notTop = {
      'Barbell_Squat': {1: squat(1, 110, 6), 2: squat(2, 112.5, 5)},
    };

    testWidgets('AC1 AC5 ghost and target lines; one tap logs the target', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openLogger(tester, last: notTop);
      expect(find.text('Last: 110 kg × 6'), findsOneWidget);
      expect(find.text('Target: 110 kg × 7'), findsOneWidget);
      expect(find.text('Last: 112.5 kg × 5'), findsOneWidget);
      await logSet(tester, 1);
      final s = sessions.active!.sets.single;
      expect((s.kg, s.reps), (110.0, 7));
      handle.dispose();
    });

    testWidgets('AC2 every set at the top last time: + 2.5 kg', (tester) async {
      await openLogger(
        tester,
        last: {
          'Barbell_Squat': {1: squat(1, 100, 8), 2: squat(2, 100, 8)},
        },
      );
      expect(find.text('Target: 102.5 kg × 5'), findsNWidgets(2));
    });

    testWidgets('AC5 no history: no ghost or target, LOG-01 prefill', (
      tester,
    ) async {
      await openLogger(tester);
      expect(find.textContaining('Last:'), findsNothing);
      expect(find.textContaining('Target:'), findsNothing);
    });

    testWidgets('AC6 AC7 PR in text; deleting it moves the PR', (tester) async {
      final handle = tester.ensureSemantics();
      await openLogger(
        tester,
        last: {
          'Barbell_Squat': {1: squat(1, 100, 5), 2: squat(2, 100, 5)},
        },
        history: {
          'Barbell_Squat': [squat(1, 100, 5), squat(2, 100, 5)],
        },
      );
      await logSet(tester, 1);
      await logSet(tester, 2);
      expect(
        setLabel('Barbell Squat, Set 1, 100 kg · 6 reps, Done, PR'),
        findsOneWidget,
      );
      expect(
        setLabel('Barbell Squat, Set 2, 100 kg · 6 reps, Done, Last'),
        findsOneWidget,
        reason: 'equal to set 1, not a PR',
      );
      expect(find.text('PR'), findsOneWidget);
      await tapSet(tester, 'Barbell Squat, Set 1');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete set'));
      await tester.pumpAndSettle();
      expect(
        setLabel('Barbell Squat, Set 2, 100 kg · 6 reps, Done, PR'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('NFR-06 ghost, target and PR fit at 200 % text', (
      tester,
    ) async {
      await openLogger(
        tester,
        last: notTop,
        history: {
          'Barbell_Squat': [squat(1, 110, 6)],
        },
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Target: 110 kg × 7'), findsOneWidget);
      await logSet(tester, 1);
      expect(tester.takeException(), isNull);
      expect(find.text('PR'), findsOneWidget);
      for (var i = 0; i < 6; i++) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('AC1 timed and bodyweight ghosts; no ghost for a new set', (
      tester,
    ) async {
      LoggedSet hold(int n, int secs) => LoggedSet(
        id: 'h$n',
        rowId: 'old',
        exerciseId: 'Plank',
        setNo: n,
        kg: 0,
        seconds: secs,
      );
      await openLogger(
        tester,
        last: {
          'Barbell_Squat': {1: squat(1, 110, 6)},
          'Plank': {1: hold(1, 40)},
        },
      );
      expect(find.textContaining('Last: 110 kg'), findsOneWidget);
      expect(find.textContaining('Last:'), findsNWidgets(2), reason: 'set 2');
      await tester.scrollUntilVisible(
        find.text('Last: 40 s'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Target: 45 s'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());

      await openLogger(
        tester,
        last: {
          'dips': {
            1: const LoggedSet(
              id: 'd1',
              rowId: 'old',
              exerciseId: 'dips',
              setNo: 1,
              kg: 0,
              reps: 12,
            ),
          },
        },
        active: WorkoutSession(
          id: 's',
          name: 'Calisthenics',
          date: DateTime.utc(2026, 11, 23),
          startedAt: DateTime.utc(2026, 11, 23, 9),
          exercises: const [
            SessionExercise(
              id: 'b1',
              exerciseId: 'dips',
              name: 'Dips',
              plannedSets: 1,
              bodyweight: true,
            ),
          ],
        ),
      );
      expect(find.text('Last: Bodyweight × 12'), findsOneWidget);
      expect(find.text('Target: Bodyweight × 13'), findsOneWidget);
    });

    testWidgets('AC7 editing the PR set down removes its badge', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openLogger(
        tester,
        last: {
          'Barbell_Squat': {1: squat(1, 100, 5)},
        },
        history: {
          'Barbell_Squat': [squat(1, 100, 5)],
        },
      );
      await logSet(tester, 1);
      expect(find.text('PR'), findsOneWidget);
      await tapSet(tester, 'Barbell Squat, Set 1');
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Decrease Reps').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(sessions.active!.sets.single.reps, 5);
      expect(find.text('PR'), findsNothing);
      handle.dispose();
    });

    testWidgets('edge imperial: ghost and target in lb on the 5 lb grid', (
      tester,
    ) async {
      await openLogger(
        tester,
        units: UnitSystem.imperial,
        last: {
          'Barbell_Squat': {1: squat(1, 100, 6)},
        },
      );
      expect(find.text('Last: 220.5 lb × 6'), findsOneWidget);
      expect(find.text('Target: 220 lb × 7'), findsOneWidget);
    });
  });
}
