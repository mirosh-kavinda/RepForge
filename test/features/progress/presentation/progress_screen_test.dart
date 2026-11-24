import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/core/clock.dart';
import 'package:repforge/core/metrics/estimate.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/features/body/domain/body_snapshot.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/logger/domain/workout_session.dart';
import 'package:repforge/features/progress/presentation/progress_sections.dart';

import '../../../helpers/app_overrides.dart';
import '../../body/fake_body_repository.dart';
import '../../library/library_fakes.dart';
import '../../logger/fake_session_repository.dart';
import '../fake_progress_prefs.dart';

DateTime d(int day, [int month = 11]) => DateTime.utc(2026, month, day);

WorkoutSession done(String id, DateTime date, String ex, double kg, int reps) =>
    WorkoutSession(
      id: id,
      name: 'W',
      exercises: [SessionExercise(id: 'r', exerciseId: ex, name: ex)],
      date: date,
      startedAt: date.add(const Duration(hours: 9)),
      endedAt: date.add(const Duration(hours: 10)),
      sets: [
        LoggedSet(
          id: '$id-1',
          rowId: 'r',
          exerciseId: ex,
          setNo: 1,
          kg: kg,
          reps: reps,
        ),
      ],
    );

// e1RM = kg × 7/6 at 5 reps: 96 → 112, 102 → 119, 108 → 126; 60 → 70.
final history = [
  done('old', d(1, 8), 'Bench_Press', 60, 5),
  done('a', d(3), 'Bench_Press', 96, 5),
  done('b', d(10), 'Bench_Press', 102, 5),
  done('c', d(17), 'Bench_Press', 108, 5),
  done('s', d(23), 'Barbell_Squat', 100, 10),
];

final snapshots = [
  BodySnapshot(id: 'x', date: d(10), weightKg: 82),
  BodySnapshot(id: 'y', date: d(20), weightKg: 81),
];

late FakeProgressPrefs prefs;

Future<void> openProgress(
  WidgetTester tester, {
  List<WorkoutSession> finished = const [],
  List<BodySnapshot> body = const [],
  UnitSystem units = UnitSystem.metric,
  double textScale = 1,
  String? saved,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  prefs = FakeProgressPrefs()..saved = saved;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...signedInOverrides(
          sessions: FakeSessionRepository()..finishedList.addAll(finished),
          body: FakeBodyRepository(snapshots: body),
          units: units,
          prefs: prefs,
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
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Progress'),
    ),
  );
  await tester.pumpAndSettle();
}

// A chart's screen-reader summary, built even when scrolled out of view.
Finder labelled(String label) => find.byWidgetPredicate(
  (w) => w is Semantics && w.properties.label == label,
);

Future<void> scrollTo(WidgetTester tester, Finder f) => tester
    .scrollUntilVisible(f, 200, scrollable: find.byType(Scrollable).first);

void main() {
  group('PRG-01 progress dashboard', () {
    testWidgets('AC1 AC2 3 months by default; the most-logged lift', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openProgress(tester, finished: history);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          'Estimated 1RM, 3 months: 112 kg to 126 kg, +14 kg in this range',
        ),
        findsOneWidget,
      );
      expect(find.text('Best: 126 kg'), findsOneWidget);
      expect(find.text('Best set: 108.0 kg × 5'), findsOneWidget);

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel(RegExp('^Estimated 1RM, All: 70 kg to 126 kg')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('AC2 Change exercise picks another and remembers it', (
      tester,
    ) async {
      await openProgress(
        tester,
        finished: [...history, done('s2', d(16), 'Barbell_Squat', 90, 10)],
      );
      await tester.tap(find.byKey(StrengthSection.changeKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Barbell Squat').last);
      await tester.pumpAndSettle();
      expect(find.text('Barbell Squat'), findsOneWidget);
      expect(prefs.saved, 'Barbell_Squat');
    });

    testWidgets('AC3 weekly volume with this week in text', (tester) async {
      await openProgress(tester, finished: history);
      await scrollTo(tester, find.text('This week: 1,000 kg'));
      expect(find.text('This week: 1,000 kg'), findsOneWidget);
    });

    testWidgets('AC4 weight trend: latest and change', (tester) async {
      await openProgress(tester, finished: history, body: snapshots);
      await scrollTo(tester, find.text('Weight: 81.0 kg'));
      expect(find.text('Weight: 81.0 kg'), findsOneWidget);
      expect(find.text('−1.0 kg in this range'), findsOneWidget);
    });

    testWidgets('AC5 too little data says so', (tester) async {
      await openProgress(
        tester,
        finished: [done('a', d(10), 'Bench_Press', 100, 5)],
        body: [snapshots.first],
      );
      expect(
        find.text('Log this lift in 2 workouts to see a trend'),
        findsOneWidget,
      );
      await scrollTo(tester, find.text('Save 2 body snapshots to see a trend'));
      expect(find.text('Save 2 body snapshots to see a trend'), findsOneWidget);
    });

    testWidgets('AC5 nothing logged yet', (tester) async {
      await openProgress(tester);
      expect(
        find.text('Finish a workout to see your strength here'),
        findsOneWidget,
      );
      expect(find.text('No weighted sets in this range'), findsOneWidget);
    });

    testWidgets('AC6 imperial: pounds everywhere', (tester) async {
      await openProgress(tester, finished: history, units: UnitSystem.imperial);
      expect(find.text('Best: 278 lb'), findsOneWidget);
      expect(find.textContaining(' kg'), findsNothing);
    });

    testWidgets('AC1 the range switch moves volume and body too', (
      tester,
    ) async {
      await openProgress(
        tester,
        finished: history,
        body: [
          BodySnapshot(id: 'o', date: d(1, 6), weightKg: 90),
          ...snapshots,
        ],
      );
      await scrollTo(tester, find.text('Weight: 81.0 kg'));
      expect(
        labelled('Weekly volume, 3 months: 14 weeks, this week 1,000 kg'),
        findsOneWidget,
      );
      expect(
        labelled('Weight, 3 months: 82.0 kg to 81.0 kg, −1.0 kg in this range'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('All'),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.text('Weight: 81.0 kg'));
      expect(
        labelled('Weekly volume, All: 18 weeks, this week 1,000 kg'),
        findsOneWidget,
      );
      expect(
        labelled('Weight, All: 90.0 kg to 81.0 kg, −9.0 kg in this range'),
        findsOneWidget,
      );
    });

    testWidgets('AC2 a remembered exercise beats the most-logged one', (
      tester,
    ) async {
      await openProgress(
        tester,
        finished: [...history, done('s2', d(16), 'Barbell_Squat', 90, 10)],
        saved: 'Barbell_Squat',
      );
      expect(find.text('Barbell Squat'), findsOneWidget);
      expect(find.text('Bench Press'), findsNothing);
    });

    testWidgets('edge a bodyweight lift shows best reps', (tester) async {
      await openProgress(
        tester,
        finished: [
          done('a', d(10), 'Dips', 0, 10),
          done('b', d(17), 'Dips', 0, 12),
        ],
      );
      expect(find.text('Best reps'), findsWidgets);
      expect(find.text('Best: 12 reps'), findsOneWidget);
    });

    testWidgets('AC4 AC7 body fat line with its summary', (tester) async {
      final handle = tester.ensureSemantics();
      await openProgress(
        tester,
        body: [
          BodySnapshot(
            id: 'x',
            date: d(10),
            weightKg: 82,
            results: {BodyMetric.bodyFat: const Estimated(20)},
          ),
          BodySnapshot(id: 'y', date: d(20), weightKg: 81, scaleBodyFatPct: 19),
        ],
      );
      await scrollTo(tester, find.text('Body fat: 19.0 %'));
      expect(find.text('Body fat: 19.0 %'), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          'Body fat, 3 months: 20.0 % to 19.0 %, −1.0 % in this range',
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('AC5 weight without body fat says why', (tester) async {
      await openProgress(tester, body: snapshots);
      await scrollTo(
        tester,
        find.text('Save body fat in 2 snapshots to see its trend'),
      );
      expect(
        find.text('Save body fat in 2 snapshots to see its trend'),
        findsOneWidget,
      );
    });

    testWidgets('AC6 imperial: body and volume in pounds', (tester) async {
      await openProgress(
        tester,
        finished: [...history, done('t', d(23), 'Bench_Press', 100, 5)],
        body: snapshots,
        units: UnitSystem.imperial,
      );
      await scrollTo(tester, find.text('Weight: 178.6 lb'));
      expect(find.text('Weight: 178.6 lb'), findsOneWidget);
      expect(find.textContaining('This week: '), findsOneWidget);
      expect(find.textContaining(' kg'), findsNothing);
    });

    testWidgets('NFR-06 fits at 200 % text', (tester) async {
      await openProgress(
        tester,
        finished: history,
        body: snapshots,
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
