import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/app/theme/rf_scales.dart';
import 'package:repforge/core/clock.dart';
import 'package:repforge/features/home/presentation/today_card.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';
import 'package:repforge/features/schedule/domain/day_record.dart';
import 'package:repforge/features/workout/data/starter_templates.dart';
import 'package:repforge/features/workout/domain/workout_template.dart';

import '../../../helpers/app_overrides.dart';
import '../../schedule/fake_cycle_repository.dart';
import '../../schedule/fake_day_record_repository.dart';
import '../../workout/fakes.dart';

final starters = [
  for (final t in starterTemplates) t.copyWith(id: t.name.toLowerCase()),
];

DateTime nov(int day, [int hour = 10]) => DateTime(2026, 11, day, hour);

// Push, Legs, Rest; anchored Mon 23 Nov 2026 on [index].
Cycle ppl({int index = 0}) => Cycle(
  id: 'c1',
  name: 'PPL',
  days: const [
    CycleDay(id: 'd1', workoutId: 'push'),
    CycleDay(id: 'd2', workoutId: 'legs'),
    CycleDay(id: 'd3'),
  ],
  isActive: true,
  startDate: DateTime.utc(2026, 11, 23),
  startDayIndex: index,
);

late DateTime now;

Future<FakeDayRecordRepository> pumpHome(
  WidgetTester tester, {
  Cycle? cycle,
  List<WorkoutTemplate>? workouts,
  double textScale = 1,
}) async {
  now = nov(23);
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  final days = FakeDayRecordRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...signedInOverrides(
          templates: FakeTemplateRepository(workouts ?? starters),
          cycles: FakeCycleRepository([cycle ?? ppl()]),
          days: days,
        ),
        exerciseCatalogProvider.overrideWith((ref) async => FakeCatalog()),
        clockProvider.overrideWithValue(() => now),
      ],
      child: MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: const RepForgeApp(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return days;
}

// The phone comes back on a later date (the resume re-reads the day).
Future<void> returnOn(WidgetTester tester, DateTime when) async {
  now = when;
  for (final s in [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(s);
  }
  await tester.pumpAndSettle();
}

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  group('SCH-02 Home today card', () {
    testWidgets('AC1 a training day not done shows the day and Mark done', (
      tester,
    ) async {
      await pumpHome(tester);
      expect(find.text('Day 1 of 3 · Push'), findsOneWidget);
      expect(find.text('Mark done'), findsOneWidget);
      expect(find.text('Next: Legs'), findsOneWidget);
      expect(find.textContaining('missed'), findsNothing);
    });

    testWidgets('AC2 Mark done shows Done in text, Undo and what is next', (
      tester,
    ) async {
      final days = await pumpHome(tester);
      await tapText(tester, 'Mark done');
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
      expect(find.text('Mark done'), findsNothing);
      expect(find.text('Next: Legs'), findsOneWidget);
      expect(days.all.map((r) => (r.date, r.dayId, r.status)), [
        (DateTime.utc(2026, 11, 23), 'd1', DayStatus.done),
      ], reason: 'AC13 stored at once');
    });

    testWidgets('AC3 Undo the same day puts it back as before', (tester) async {
      final days = await pumpHome(tester);
      await tapText(tester, 'Mark done');
      await tapText(tester, 'Undo');
      expect(find.text('Mark done'), findsOneWidget);
      expect(find.text('Done'), findsNothing);
      expect(find.text('Day 1 of 3 · Push'), findsOneWidget);
      expect(days.all, isEmpty);
    });

    testWidgets('AC4 done today: the next calendar day is day n+1', (
      tester,
    ) async {
      await pumpHome(tester);
      await tapText(tester, 'Mark done');
      await returnOn(tester, nov(24, 7));
      expect(find.text('Day 2 of 3 · Legs'), findsOneWidget);
      expect(find.text('Mark done'), findsOneWidget);
      expect(find.text('Undo'), findsNothing, reason: 'edge past days locked');
    });

    testWidgets('AC6 AC8 not done: same day tomorrow, missed yesterday', (
      tester,
    ) async {
      final days = await pumpHome(tester);
      await returnOn(tester, nov(24));
      expect(find.text('Day 1 of 3 · Push'), findsOneWidget);
      expect(find.text('Push · missed yesterday'), findsOneWidget);
      expect(days.settled.map((r) => (r.date.day, r.status)), [
        (23, DayStatus.missed),
      ]);
    });

    testWidgets('AC7 AC8 away three days: same day, missed 3 days, once each', (
      tester,
    ) async {
      final days = await pumpHome(tester);
      await returnOn(tester, nov(26));
      expect(find.text('Day 1 of 3 · Push'), findsOneWidget);
      expect(find.text('Push · missed 3 days'), findsOneWidget);
      await returnOn(tester, nov(26, 20));
      expect(days.all.map((r) => (r.date.day, r.status)), [
        (23, DayStatus.missed),
        (24, DayStatus.missed),
        (25, DayStatus.missed),
      ]);
    });

    testWidgets('AC9 a rest day shows the rest variant without Mark done', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpHome(tester, cycle: ppl(index: 2));
      expect(find.bySemanticsLabel('Rest day'), findsOneWidget);
      expect(find.text('Day 3 of 3'), findsOneWidget);
      expect(find.text('Next: Push'), findsOneWidget);
      expect(find.text('Mark done'), findsNothing);
      handle.dispose();
    });

    testWidgets('AC5 a rest day passes with no tap', (tester) async {
      final days = await pumpHome(tester, cycle: ppl(index: 2));
      await returnOn(tester, nov(24));
      expect(find.text('Day 1 of 3 · Push'), findsOneWidget);
      expect(find.textContaining('missed'), findsNothing);
      expect(days.settled.map((r) => (r.date.day, r.status)), [
        (23, DayStatus.rest),
      ]);
    });

    testWidgets('edge a deleted workout still says so and can be marked', (
      tester,
    ) async {
      final days = await pumpHome(
        tester,
        workouts: starters.where((w) => w.id != 'push').toList(),
      );
      expect(find.text('Day 1 of 3 · Workout deleted'), findsOneWidget);
      await tapText(tester, 'Mark done');
      expect(days.all.single.status, DayStatus.done);
    });

    testWidgets('edge a failed Mark done or Undo says so; card unchanged', (
      tester,
    ) async {
      final days = await pumpHome(tester);
      days.failWith = StateError('disk');
      await tapText(tester, 'Mark done');
      expect(find.text("Couldn't save. Try again."), findsOneWidget);
      expect(find.text('Mark done'), findsOneWidget);

      days.failWith = null;
      await tapText(tester, 'Mark done');
      days.failWith = StateError('disk');
      await tapText(tester, 'Undo');
      expect(find.text('Done'), findsOneWidget);
      expect(days.all, hasLength(1));
    });

    testWidgets('edge a failed settle is ignored; the day still shows', (
      tester,
    ) async {
      final days = await pumpHome(tester)
        ..failSettleWith = StateError('disk');
      await returnOn(tester, nov(24));
      expect(find.text('Push · missed yesterday'), findsOneWidget);
      days.failSettleWith = null;
      await returnOn(tester, nov(25));
      expect(days.settled.map((r) => r.date.day), [23, 24]);
    });

    testWidgets('edge clock back onto a done day offers no Undo', (
      tester,
    ) async {
      final days = await pumpHome(tester);
      await tapText(tester, 'Mark done');
      await returnOn(tester, nov(24));
      await returnOn(tester, nov(23, 18));
      expect(find.text('Day 1 of 3 · Push'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.byKey(TodayCard.actionKey), findsNothing);
      expect(days.all.first.status, DayStatus.done);
    });

    testWidgets('edge clock back onto a missed day offers no Mark done', (
      tester,
    ) async {
      await pumpHome(tester);
      await returnOn(tester, nov(24));
      await returnOn(tester, nov(23, 18));
      expect(find.text('Day 1 of 3 · Push'), findsOneWidget);
      expect(find.byKey(TodayCard.actionKey), findsNothing);
    });

    testWidgets('NFR-06 the rest variant fits at 200 % text', (tester) async {
      await pumpHome(tester, cycle: ppl(index: 2), textScale: 2);
      expect(tester.takeException(), isNull);
      expect(find.text('Rest day'), findsOneWidget);
    });

    testWidgets('NFR-06 labelled 48 dp actions; fits at 200 % text', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpHome(tester, textScale: 2);
      await returnOn(tester, nov(25));
      expect(tester.takeException(), isNull);
      final mark = find.bySemanticsLabel('Mark done');
      expect(mark, findsOneWidget);
      expect(
        tester.getSize(find.byKey(TodayCard.actionKey)).height,
        greaterThanOrEqualTo(RfSize.minTarget),
      );
      await tester.tap(find.byKey(TodayCard.actionKey));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('Undo'), findsOneWidget);
      handle.dispose();
    });
  });

  group('SCH-03 Home in weekday mode', () {
    // Stored Monday first: Mon Push, Tue Legs, Wed Rest, Thu Push, Fri Rest,
    // Sat Legs, Sun Rest. Anchored Mon 23.
    final week = ppl().copyWith(
      name: 'Week',
      mode: CycleMode.weekdays,
      days: [
        for (final (i, w) in [
          'push',
          'legs',
          null,
          'push',
          null,
          'legs',
          null,
        ].indexed)
          CycleDay(id: 'w$i', workoutId: w),
      ],
    );

    testWidgets("AC6 shows today's weekday and workout; Mark done, Undo", (
      tester,
    ) async {
      final days = await pumpHome(tester, cycle: week);
      expect(find.text('Monday · Push'), findsOneWidget);
      expect(find.text('Next: Legs'), findsOneWidget);
      await tapText(tester, 'Mark done');
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
      expect(days.all.map((r) => (r.date.day, r.dayId, r.dayIndex, r.status)), [
        (23, 'w0', 0, DayStatus.done),
      ]);
    });

    testWidgets('AC6 a weekday rest day shows Rest day, the weekday, Next', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpHome(tester, cycle: week);
      await returnOn(tester, nov(25));
      expect(find.bySemanticsLabel('Rest day'), findsOneWidget);
      expect(find.text('Wednesday'), findsOneWidget);
      expect(find.text('Next: Push'), findsOneWidget);
      expect(find.text('Mark done'), findsNothing);
      handle.dispose();
    });

    testWidgets('AC7 a missed day passes: next weekday, missed once, no line', (
      tester,
    ) async {
      final days = await pumpHome(tester, cycle: week);
      await returnOn(tester, nov(24));
      expect(find.text('Tuesday · Legs'), findsOneWidget);
      expect(find.textContaining('missed'), findsNothing);
      await returnOn(tester, nov(26));
      expect(find.text('Thursday · Push'), findsOneWidget);
      await returnOn(tester, nov(26, 20));
      expect(days.all.map((r) => (r.date.day, r.status)), [
        (23, DayStatus.missed),
        (24, DayStatus.missed),
        (25, DayStatus.rest),
      ]);
    });

    testWidgets('edge a deleted workout still says so and can be marked', (
      tester,
    ) async {
      final days = await pumpHome(
        tester,
        cycle: week,
        workouts: starters.where((w) => w.id != 'push').toList(),
      );
      expect(find.text('Monday · Workout deleted'), findsOneWidget);
      await tapText(tester, 'Mark done');
      expect(days.all.single.status, DayStatus.done);
    });

    testWidgets('NFR-06 weekday heading and rest variant fit at 200 % text', (
      tester,
    ) async {
      await pumpHome(
        tester,
        cycle: week,
        workouts: starters.where((w) => w.id != 'push').toList(),
        textScale: 2,
      );
      expect(find.text('Monday · Workout deleted'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await returnOn(tester, nov(25));
      expect(find.text('Wednesday'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
