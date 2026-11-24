import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/core/clock.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/progress/data/providers.dart';
import 'package:repforge/features/progress/presentation/adherence_section.dart';
import 'package:repforge/features/progress/presentation/progress_charts.dart';
import 'package:repforge/features/progress/presentation/progress_sections.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';
import 'package:repforge/features/schedule/domain/day_record.dart';
import 'package:repforge/features/workout/domain/workout_template.dart';

import '../../../helpers/app_overrides.dart';
import '../../library/library_fakes.dart';
import '../../schedule/fake_cycle_repository.dart';
import '../../schedule/fake_day_record_repository.dart';
import '../../workout/fakes.dart';

DateTime d(int day, [int month = 11]) => DateTime.utc(2026, month, day);

// Push, Pull, Rest from Nov 1; today is Tue Nov 24 (a rest row).
final cycle = Cycle(
  id: 'c',
  name: 'Two on',
  days: const [
    CycleDay(id: 'a', workoutId: 'w-a'),
    CycleDay(id: 'b', workoutId: 'w-b'),
    CycleDay(id: 'off'),
  ],
  isActive: true,
  startDate: d(1),
  startDayIndex: 0,
);

const _rows = ['a', 'b', 'off'];

// Nov 1–24. Done 10, missed 4, skipped 2: 10 of 16, 63 %. Streak 4 (21–24),
// best 7 (12–19, the skip on 16 is neutral).
const _plan = {
  4: DayStatus.missed,
  7: DayStatus.skipped,
  10: DayStatus.missed,
  11: DayStatus.missed,
  16: DayStatus.skipped,
  20: DayStatus.missed,
};

List<DayRecord> month({
  Map<int, DayStatus> plan = _plan,
  bool rest = false,
}) => [
  for (var day = 1; day <= 24; day++)
    () {
      final i = (day - 1) % 3;
      return DayRecord(
        id: 'r$day',
        cycleId: 'c',
        date: d(day),
        dayId: _rows[i],
        dayIndex: i,
        status: i == 2 || rest ? DayStatus.rest : plan[day] ?? DayStatus.done,
      );
    }(),
];

Future<void> openProgress(
  WidgetTester tester, {
  List<DayRecord>? records,
  double textScale = 1,
  bool failing = false,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...signedInOverrides(
          cycles: FakeCycleRepository([cycle]),
          days: FakeDayRecordRepository(records ?? month()),
          // w-b is gone, so its days show the fallback name.
          templates: FakeTemplateRepository([
            const WorkoutTemplate(id: 'w-a', name: 'Push', exercises: []),
          ]),
        ),
        exerciseCatalogProvider.overrideWith((ref) async => LibraryCatalog()),
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 24, 8)),
        if (failing)
          statusHistoryProvider.overrideWithValue(
            AsyncError(StateError('db'), StackTrace.empty),
          ),
      ],
      child: MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: const RepForgeApp(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Progress'),
    ),
  );
  await tester.pumpAndSettle();
}

Finder inCard(Finder f) =>
    find.descendant(of: find.byType(AdherenceSection), matching: f);

Finder labelled(String label) => find.byWidgetPredicate(
  (w) => w is Semantics && w.properties.label == label,
);

Future<void> scrollTo(WidgetTester tester, Finder f) => tester
    .scrollUntilVisible(f, 200, scrollable: find.byType(Scrollable).first);

void main() {
  group('PRG-02 adherence card', () {
    testWidgets('AC3 AC4 percentage, counts and streaks above Strength', (
      tester,
    ) async {
      await openProgress(tester);
      expect(inCard(find.text('63 %')), findsOneWidget);
      expect(inCard(find.text('10 of 16 training days')), findsOneWidget);
      expect(inCard(find.text('Streak: 4 days')), findsOneWidget);
      expect(inCard(find.text('Best: 7 days')), findsOneWidget);
      final list = tester.widget<ListView>(find.byType(ListView).first);
      final types = [
        for (final w
            in (list.childrenDelegate as SliverChildListDelegate).children)
          w.runtimeType,
      ];
      expect(
        types.indexOf(AdherenceSection),
        lessThan(types.indexOf(StrengthSection)),
      );
    });

    testWidgets('AC8 one summary for screen readers', (tester) async {
      await openProgress(tester);
      expect(
        labelled(
          'Adherence, 3 months: 63 %, 10 of 16 training days. '
          'Streak: 4 days, Best: 7 days',
        ),
        findsOneWidget,
      );
      expect(
        labelled(
          'Each week, 3 months: 5 weeks, 0 with no training planned, '
          'this week 100 %',
        ),
        findsOneWidget,
      );
    });

    testWidgets('AC5 a week with nothing planned is marked, not 0 %', (
      tester,
    ) async {
      // Nov 9–15 (a Monday week) only rest.
      await openProgress(
        tester,
        records: [
          for (final r in month())
            r.date.day >= 9 && r.date.day <= 15
                ? r.copyWith(status: DayStatus.rest)
                : r,
        ],
      );
      final chart = tester.widget<ProgressBarChart>(
        inCard(find.byType(ProgressBarChart)),
      );
      expect(
        [for (final p in chart.points) p.date],
        [DateTime.utc(2026, 10, 26), d(2), d(9), d(16), d(23)],
      );
      expect(chart.noData, {d(9)});
      expect(chart.noDataText, 'No training planned');
      expect(chart.maxY, 100);
      expect(
        labelled(
          'Each week, 3 months: 5 weeks, 1 with no training planned, '
          'this week 100 %',
        ),
        findsOneWidget,
      );
    });

    testWidgets('AC3 the range switch applies', (tester) async {
      // A missed day from an older cycle, before the 3-month range.
      await openProgress(
        tester,
        records: [
          DayRecord(
            id: 'old',
            cycleId: 'old',
            date: d(1, 8),
            dayId: 'x',
            dayIndex: 0,
            status: DayStatus.missed,
          ),
          ...month(),
        ],
      );
      expect(inCard(find.text('63 %')), findsOneWidget);
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      expect(inCard(find.text('59 %')), findsOneWidget);
      expect(inCard(find.text('10 of 17 training days')), findsOneWidget);
    });

    testWidgets('AC6 missed and skipped newest first; Show all', (
      tester,
    ) async {
      await openProgress(tester);
      await scrollTo(tester, find.byKey(AdherenceSection.showAllKey));
      expect(find.text('Fri, Nov 20 · Workout · Missed'), findsOneWidget);
      expect(find.text('Mon, Nov 16 · Push · Skipped'), findsOneWidget);
      expect(find.text('Sat, Nov 7 · Push · Skipped'), findsOneWidget);
      expect(find.text('Wed, Nov 4 · Push · Missed'), findsNothing);
      final rows = [
        for (final e in tester.widgetList<Text>(inCard(find.byType(Text))))
          if (e.data?.contains(' · ') ?? false) e.data!,
      ];
      expect(rows.first, startsWith('Fri, Nov 20'));
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(AdherenceSection.showAllKey));
      await tester.pumpAndSettle();
      expect(
        find.text('Wed, Nov 4 · Push · Missed', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.byKey(AdherenceSection.showAllKey), findsNothing);
    });

    testWidgets('AC6 no missed days says so', (tester) async {
      await openProgress(tester, records: month(plan: const {}));
      await scrollTo(tester, find.text('No missed days'));
      expect(find.text('No missed days'), findsOneWidget);
      expect(inCard(find.text('100 %')), findsWidgets);
    });

    testWidgets('AC7 nothing planned: not enough data, no bars', (
      tester,
    ) async {
      await openProgress(tester, records: month(rest: true));
      expect(inCard(find.text('Not enough data')), findsOneWidget);
      expect(inCard(find.byType(ProgressBarChart)), findsNothing);
      expect(inCard(find.text('Streak: 24 days')), findsOneWidget);
    });

    testWidgets('a failing history says not enough data', (tester) async {
      await openProgress(tester, failing: true);
      expect(inCard(find.text('Not enough data')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('NFR-06 fits at 200 % text', (tester) async {
      await openProgress(tester, textScale: 2);
      expect(tester.takeException(), isNull);
      await scrollTo(tester, find.byKey(AdherenceSection.showAllKey));
      expect(
        tester.getSize(find.byKey(AdherenceSection.showAllKey)).height,
        greaterThanOrEqualTo(48),
      );
    });
  });
}
