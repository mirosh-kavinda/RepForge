import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/app/router.dart';
import 'package:repforge/core/clock.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/features/home/presentation/today_card.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/logger/domain/workout_session.dart';
import 'package:repforge/features/logger/presentation/logger_screen.dart';
import 'package:repforge/features/logger/presentation/summary_screen.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';
import 'package:repforge/features/workout/domain/workout_template.dart';

import '../../../helpers/app_overrides.dart';
import '../../schedule/fake_cycle_repository.dart';
import '../../schedule/fake_day_record_repository.dart';
import '../../workout/fakes.dart';
import '../fake_session_repository.dart';
import '../fake_summary_share.dart';

const legs = WorkoutTemplate(
  id: 'legs',
  name: 'Legs',
  exercises: [
    TemplateExercise(id: 't1', exerciseId: 'Barbell_Squat', sets: 2, repMin: 5),
  ],
);

final cycle = Cycle(
  id: 'c1',
  name: 'Legs only',
  days: const [CycleDay(id: 'd1', workoutId: 'legs')],
  isActive: true,
  startDate: DateTime.utc(2026, 11, 23),
  startDayIndex: 0,
);

const squat = SessionExercise(
  id: 'r1',
  exerciseId: 'Barbell_Squat',
  name: 'Barbell Squat',
);
const plank = SessionExercise(
  id: 'r2',
  exerciseId: 'Plank',
  name: 'Plank',
  kind: TargetKind.time,
);

LoggedSet sq(String id, int n, double kg, {bool pr = false}) => LoggedSet(
  id: id,
  rowId: 'r1',
  exerciseId: 'Barbell_Squat',
  setNo: n,
  kg: kg,
  reps: 5,
  isPr: pr,
);

WorkoutSession done(
  String id,
  DateTime start,
  Duration took,
  List<LoggedSet> sets,
) => WorkoutSession(
  id: id,
  name: 'Legs',
  templateId: 'legs',
  exercises: const [squat, plank],
  date: DateTime.utc(start.year, start.month, start.day),
  startedAt: start,
  endedAt: start.add(took),
  sets: sets,
);

final previous = done(
  'p',
  DateTime.utc(2026, 11, 16, 9),
  const Duration(hours: 1, minutes: 5),
  [sq('p1', 1, 100), sq('p2', 2, 100)],
);

final today = done(
  't',
  DateTime.utc(2026, 11, 23, 9),
  const Duration(hours: 1, minutes: 2),
  [
    sq('t1', 1, 105, pr: true),
    sq('t2', 2, 100),
    const LoggedSet(
      id: 't3',
      rowId: 'r2',
      exerciseId: 'Plank',
      setNo: 1,
      kg: 0,
      seconds: 60,
    ),
  ],
);

late FakeSessionRepository sessions;
late FakeSummaryShare share;

Future<void> pumpApp(
  WidgetTester tester, {
  List<WorkoutSession> finished = const [],
  UnitSystem units = UnitSystem.metric,
  double textScale = 1,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  final days = FakeDayRecordRepository();
  sessions = FakeSessionRepository(days: days)..finishedList.addAll(finished);
  share = FakeSummaryShare();
  SummaryScreen.capture = (_) async => Uint8List.fromList([1, 2, 3]);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...signedInOverrides(
          templates: FakeTemplateRepository([legs]),
          cycles: FakeCycleRepository([cycle]),
          days: days,
          sessions: sessions,
          share: share,
          units: units,
        ),
        exerciseCatalogProvider.overrideWith((ref) async => FakeCatalog()),
        clockProvider.overrideWithValue(() => DateTime.utc(2026, 11, 23, 10)),
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

Future<void> go(WidgetTester tester, String location) async {
  ProviderScope.containerOf(
    tester.element(find.byType(RepForgeApp)),
  ).read(routerProvider).go(location);
  await tester.pumpAndSettle();
}

Future<void> openSummary(
  WidgetTester tester, {
  List<WorkoutSession>? finished,
  UnitSystem units = UnitSystem.metric,
  double textScale = 1,
}) async {
  await pumpApp(
    tester,
    finished: finished ?? [previous, today],
    units: units,
    textScale: textScale,
  );
  await go(tester, Routes.summary('t', afterFinish: true));
}

Future<void> typeNote(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.byKey(SummaryScreen.noteKey),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.enterText(find.byKey(SummaryScreen.noteKey), text);
}

void main() {
  group('LOG-05 summary', () {
    testWidgets(
      'AC1 Finish opens the summary; back goes Home, not the logger',
      (tester) async {
        final handle = tester.ensureSemantics();
        await pumpApp(tester);
        await tester.tap(find.byKey(TodayCard.startKey));
        await tester.pumpAndSettle();
        final f = find.bySemanticsLabel('Log set 1').first;
        await tester.ensureVisible(f);
        await tester.pumpAndSettle();
        await tester.tap(f);
        await tester.pumpAndSettle();
        sessions.endAt = DateTime.utc(2026, 11, 23, 10, 42);
        await tester.tap(find.byKey(LoggerScreen.finishKey));
        await tester.pumpAndSettle();
        expect(find.byType(SummaryScreen), findsOneWidget);
        expect(find.text('Workout done'), findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(SummaryScreen), findsNothing);
        expect(find.byType(LoggerScreen), findsNothing);
        expect(find.byKey(TodayCard.startKey), findsNothing, reason: 'done');
        handle.dispose();
      },
    );

    testWidgets('AC2 name, date, duration, sets and volume', (tester) async {
      await openSummary(tester);
      expect(find.text('Legs · Mon, Nov 23, 2026'), findsOneWidget);
      expect(find.text('1:02 h'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('1,025 kg'), findsWidgets);
    });

    testWidgets('AC2 edge imperial users see lb', (tester) async {
      await openSummary(tester, units: UnitSystem.imperial);
      expect(find.text('2,260 lb'), findsWidgets);
      expect(find.textContaining('kg'), findsNothing);
    });

    testWidgets('AC3 each exercise with its sets and total', (tester) async {
      await openSummary(tester);
      expect(find.text('Barbell Squat'), findsOneWidget);
      expect(find.text('105 kg × 5, 100 kg × 5'), findsOneWidget);
      expect(find.text('1,025 kg · +25 kg vs last time'), findsOneWidget);
      expect(find.text('Plank'), findsOneWidget);
      expect(find.text('60 s'), findsOneWidget);
      expect(find.text('1:00 min'), findsOneWidget);
    });

    testWidgets('AC4 PRs listed at the top in text; none, no section', (
      tester,
    ) async {
      await openSummary(tester);
      expect(find.text('1 PR'), findsOneWidget);
      expect(find.text('PR · Barbell Squat 105 kg × 5'), findsOneWidget);

      await go(tester, Routes.summary('p'));
      expect(find.textContaining('PR'), findsNothing);
    });

    testWidgets('AC5 changes from the previous workout', (tester) async {
      await openSummary(tester);
      expect(find.text('−3 min vs last time'), findsOneWidget);
      expect(find.text('+1 set vs last time'), findsOneWidget);
      expect(find.text('+25 kg vs last time'), findsOneWidget);
      expect(find.text('First time — nothing to compare yet'), findsNothing);
    });

    testWidgets('AC5 with no previous workout, nothing to compare', (
      tester,
    ) async {
      await openSummary(tester, finished: [today]);
      expect(find.text('First time — nothing to compare yet'), findsOneWidget);
      expect(find.textContaining('vs last time'), findsNothing);
    });

    testWidgets('AC6 the note is saved on leaving and shown again', (
      tester,
    ) async {
      await openSummary(tester);
      await typeNote(tester, ' Felt strong ');
      await tester.tap(find.byKey(SummaryScreen.doneKey));
      await tester.pumpAndSettle();
      expect(sessions.notes['t'], 'Felt strong');
      await go(tester, Routes.summary('t'));
      await tester.scrollUntilVisible(
        find.text('Felt strong'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Felt strong'), findsOneWidget);
    });

    testWidgets('AC6 leaving without a change writes nothing', (tester) async {
      await openSummary(tester);
      await tester.tap(find.byKey(SummaryScreen.doneKey));
      await tester.pumpAndSettle();
      expect(sessions.notes, isEmpty);
    });

    testWidgets('AC6 a failed note save says so and stays', (tester) async {
      await openSummary(tester);
      sessions.noteFails = Exception('disk');
      await typeNote(tester, 'Hi');
      await tester.tap(find.byKey(SummaryScreen.doneKey));
      await tester.pumpAndSettle();
      expect(find.text("Couldn't save the note"), findsOneWidget);
      expect(find.byType(SummaryScreen), findsOneWidget);
    });

    testWidgets('AC6 the note is saved when the app goes to the background', (
      tester,
    ) async {
      await openSummary(tester);
      await typeNote(tester, 'Later');
      tester.binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
        ..handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pumpAndSettle();
      expect(sessions.notes['t'], 'Later');
    });

    testWidgets('AC7 Share sends the card image with a line of text', (
      tester,
    ) async {
      await openSummary(tester);
      await tester.tap(find.byKey(SummaryScreen.shareKey));
      await tester.pumpAndSettle();
      final s = share.shared.single;
      expect(s.png, [1, 2, 3]);
      expect(s.fileName, endsWith('.png'));
      expect(s.text, 'Legs · Mon, Nov 23, 2026 · 1:02 h · 1,025 kg');
    });

    testWidgets('AC7 the shared card renders to a PNG', (tester) async {
      await openSummary(tester);
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find
            .ancestor(
              of: find.byKey(SummaryScreen.cardKey),
              matching: find.byType(RepaintBoundary),
            )
            .first,
      );
      final png = await tester.runAsync<Uint8List>(
        () => SummaryScreen.defaultCapture(boundary),
      );
      expect(png!.sublist(1, 4), 'PNG'.codeUnits);
    });

    testWidgets('AC7 Share still works after scrolling to the note', (
      tester,
    ) async {
      await openSummary(tester);
      await typeNote(tester, 'x');
      await tester.tap(find.byKey(SummaryScreen.shareKey));
      await tester.pumpAndSettle();
      expect(share.shared, hasLength(1));
    });

    testWidgets('edge a cancelled share changes nothing', (tester) async {
      await openSummary(tester);
      await tester.tap(find.byKey(SummaryScreen.shareKey));
      await tester.pumpAndSettle();
      expect(find.byType(SummaryScreen), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      expect(sessions.notes, isEmpty);
    });

    testWidgets('edge an exercise gone from the library keeps its name', (
      tester,
    ) async {
      final gone = today.copyWith(
        exercises: const [
          SessionExercise(id: 'r1', exerciseId: 'Old_Lift', name: 'Old Lift'),
        ],
        sets: [sq('t1', 1, 80).copyWith(exerciseId: 'Old_Lift')],
      );
      await openSummary(tester, finished: [gone]);
      expect(find.text('Old Lift'), findsOneWidget);
    });

    testWidgets('AC5 volume not comparable when last time had none', (
      tester,
    ) async {
      final bw = previous.copyWith(sets: [sq('p1', 1, 0), sq('p2', 2, 0)]);
      await openSummary(tester, finished: [bw, today]);
      expect(find.text('— vs last time'), findsOneWidget);
    });

    testWidgets('AC7 a failed share says so', (tester) async {
      await openSummary(tester);
      share.failWith = Exception('no app');
      await tester.tap(find.byKey(SummaryScreen.shareKey));
      await tester.pumpAndSettle();
      expect(find.text("Couldn't share"), findsOneWidget);
    });

    testWidgets('error an unknown workout says so; Done goes Home', (
      tester,
    ) async {
      await pumpApp(tester);
      await go(tester, Routes.summary('gone'));
      expect(find.text("Couldn't load this workout"), findsOneWidget);
      await tester.tap(find.byKey(SummaryScreen.doneKey));
      await tester.pumpAndSettle();
      expect(find.byType(SummaryScreen), findsNothing);
    });

    testWidgets('NFR-06 spoken changes, labelled controls, 200 % text', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openSummary(tester, textScale: 2);
      expect(tester.takeException(), isNull);
      expect(
        find.bySemanticsLabel('Time, 1:02 h, down 3 min vs last time'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Volume, 1,025 kg, up 25 kg vs last time'),
        findsOneWidget,
      );
      expect(find.byTooltip('Share'), findsOneWidget);
      expect(
        tester.getSize(find.byKey(SummaryScreen.shareKey)).height,
        greaterThanOrEqualTo(48),
      );
      handle.dispose();
    });
  });
}
