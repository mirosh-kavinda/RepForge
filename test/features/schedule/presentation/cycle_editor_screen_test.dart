import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/l10n/generated/app_localizations.dart';
import 'package:repforge/app/theme/rf_theme.dart';
import 'package:repforge/app/widgets/rf_button.dart';
import 'package:repforge/app/widgets/rf_segmented.dart';
import 'package:repforge/core/clock.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/schedule/data/providers.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';
import 'package:repforge/features/schedule/domain/day_record.dart';
import 'package:repforge/features/schedule/presentation/cycle_editor_screen.dart';
import 'package:repforge/features/workout/data/providers.dart';
import 'package:repforge/features/workout/domain/workout_template.dart';

import '../../workout/fakes.dart';
import '../fake_cycle_repository.dart';
import '../fake_day_record_repository.dart';

// Monday 23 Nov 2026, 10:00.
final now = DateTime(2026, 11, 23, 10);

const push = WorkoutTemplate(
  id: 'push',
  name: 'Push',
  exercises: [TemplateExercise(id: 'r1', exerciseId: 'Barbell_Squat')],
);
const legs = WorkoutTemplate(
  id: 'legs',
  name: 'Legs',
  exercises: [
    TemplateExercise(id: 'r2', exerciseId: 'Leg_Press'),
    TemplateExercise(id: 'r3', exerciseId: 'Romanian_Deadlift'),
  ],
);

// Anchored today (Mon 23) on index 2 (Rest).
final ppl = Cycle(
  id: 'c1',
  name: 'PPL',
  days: const [
    CycleDay(id: 'd1', workoutId: 'push'),
    CycleDay(id: 'd2', workoutId: 'legs'),
    CycleDay(id: 'd3'),
  ],
  isActive: true,
  startDate: DateTime.utc(2026, 11, 23),
  startDayIndex: 2,
);

Future<FakeCycleRepository> pumpBuilder(
  WidgetTester tester, {
  String? id,
  String? copyOf,
  List<WorkoutTemplate> workouts = const [push, legs],
  FakeCycleRepository? repo,
  FakeTemplateRepository? templates,
  FakeDayRecordRepository? days,
  double textScale = 1,
  Locale? locale,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  final r = repo ?? FakeCycleRepository([ppl]);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        cycleRepositoryProvider.overrideWithValue(r),
        dayRecordRepositoryProvider.overrideWithValue(
          days ?? FakeDayRecordRepository(),
        ),
        templateRepositoryProvider.overrideWithValue(
          templates ?? FakeTemplateRepository(workouts),
        ),
        exerciseCatalogProvider.overrideWith((ref) async => FakeCatalog()),
        clockProvider.overrideWithValue(() => now),
      ],
      child: MaterialApp(
        theme: rfTheme(Brightness.dark),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: locale,
        supportedLocales: [locale ?? const Locale('en')],
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: app!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CycleEditorScreen(id: id, copyOf: copyOf),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return r;
}

bool saveEnabled(WidgetTester tester) =>
    tester.widget<RfButton>(find.byKey(CycleEditorScreen.saveKey)).onPressed !=
    null;

Future<void> scrollTo(WidgetTester tester, Finder f) => tester
    .scrollUntilVisible(f, 200, scrollable: find.byType(Scrollable).first);

Future<void> addTraining(WidgetTester tester, String workout) async {
  await scrollTo(tester, find.byKey(CycleEditorScreen.addTrainingKey));
  await tester.tap(find.byKey(CycleEditorScreen.addTrainingKey));
  await tester.pumpAndSettle();
  await tester.tap(find.text(workout).last);
  await tester.pumpAndSettle();
}

Future<void> addRest(WidgetTester tester) async {
  await scrollTo(tester, find.byKey(CycleEditorScreen.addRestKey));
  await tester.tap(find.byKey(CycleEditorScreen.addRestKey));
  await tester.pumpAndSettle();
}

Future<void> dayAction(WidgetTester tester, int n, String action) async {
  await tester.tap(find.byTooltip('Actions for day $n'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(action).last);
  await tester.pumpAndSettle();
}

// Day titles in list order, read from each tile's semantics label.
List<String> dayTitles(WidgetTester tester) {
  final labels = <String>[];
  for (var n = 1; n <= 14; n++) {
    final f = find.bySemanticsLabel(RegExp('^Day $n, '));
    if (f.evaluate().isEmpty) break;
    final label = tester.getSemantics(f.first).label;
    labels.add(label.split(', ')[1]);
  }
  return labels;
}

Future<void> save(WidgetTester tester) async {
  await tester.tap(find.byKey(CycleEditorScreen.saveKey));
  await tester.pumpAndSettle();
}

void main() {
  group('SCH-01 builder: new cycle', () {
    testWidgets('AC1 AC2 add days; counts; Save needs name and training', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpBuilder(tester);
      expect(find.text('New cycle'), findsOneWidget);
      expect(saveEnabled(tester), isFalse);
      expect(find.text('Add at least one day.'), findsNothing);

      await tester.enterText(find.byKey(CycleEditorScreen.nameKey), 'PPL');
      await tester.pump();
      expect(find.text('Add at least one day.'), findsOneWidget);
      await addRest(tester);
      expect(find.text('Add at least one training day.'), findsOneWidget);
      expect(saveEnabled(tester), isFalse);

      await addTraining(tester, 'Push');
      await addTraining(tester, 'Push');
      expect(find.text('3 days · 2 train, 1 rest'), findsOneWidget);
      expect(dayTitles(tester), ['Rest', 'Push', 'Push']);
      expect(find.text('Quads · Glutes · 1 ex'), findsNWidgets(2));
      expect(saveEnabled(tester), isTrue);
      handle.dispose();
    });

    testWidgets('AC4 AC5 preview from today; Today is day n; saves active', (
      tester,
    ) async {
      final repo = await pumpBuilder(tester);
      await tester.enterText(find.byKey(CycleEditorScreen.nameKey), ' UL ');
      await addTraining(tester, 'Push');
      await addTraining(tester, 'Legs');
      await addRest(tester);
      await tester.scrollUntilVisible(find.text('Preview · starts today'), 200);
      expect(find.text('Mon, Nov 23'), findsOneWidget);
      expect(find.text('Mon, Nov 30'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Increase Today is day'));
      await tester.pumpAndSettle();
      // Today is day 2 (Legs): Mon Legs, Tue Rest, Wed Push.
      final rows = [
        for (final d in ['Mon, Nov 23', 'Tue, Nov 24', 'Wed, Nov 25'])
          tester
              .widgetList<Text>(
                find.descendant(
                  of: find.ancestor(
                    of: find.text(d),
                    matching: find.byType(Row),
                  ),
                  matching: find.byType(Text),
                ),
              )
              .last
              .data,
      ];
      expect(rows, ['Legs', 'Rest', 'Push']);

      await save(tester);
      expect(find.byType(CycleEditorScreen), findsNothing);
      final c = repo.saved.single;
      expect(c.name, 'UL');
      expect(
        (c.isActive, c.startDate, c.startDayIndex),
        (true, DateTime.utc(2026, 11, 23), 1),
      );
      expect(repo.active.firstWhere((x) => x.id == 'c1').isActive, isFalse);
    });

    testWidgets('AC2 the 14th day disables both add buttons and says why', (
      tester,
    ) async {
      await pumpBuilder(tester);
      for (var i = 0; i < 14; i++) {
        await addRest(tester);
      }
      await scrollTo(tester, find.text('Up to 14 days in a cycle.'));
      final rest = tester.widget<RfButton>(
        find.byKey(CycleEditorScreen.addRestKey),
      );
      expect(rest.onPressed, isNull);
      final training = tester.widget<RfButton>(
        find.byKey(CycleEditorScreen.addTrainingKey),
      );
      expect(training.onPressed, isNull);
    });

    testWidgets('edge Today is day n resets to 1 when the length drops', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpBuilder(tester);
      await addTraining(tester, 'Push');
      await addTraining(tester, 'Legs');
      await addRest(tester);
      await scrollTo(tester, find.byKey(CycleEditorScreen.startDayKey));
      await tester.tap(find.bySemanticsLabel('Increase Today is day'));
      await tester.tap(find.bySemanticsLabel('Increase Today is day'));
      await tester.pumpAndSettle();
      String value() => tester
          .getSemantics(
            find.descendant(
              of: find.byKey(CycleEditorScreen.startDayKey),
              matching: find.bySemanticsLabel('Today is day'),
            ),
          )
          .value;
      expect(value(), '3');
      await dayAction(tester, 3, 'Remove');
      await scrollTo(tester, find.byKey(CycleEditorScreen.startDayKey));
      expect(value(), '1');
      handle.dispose();
    });
  });

  group('SCH-01 builder: editing', () {
    testWidgets('AC3 change, make rest, make training, move, remove', (
      tester,
    ) async {
      await pumpBuilder(tester, id: 'c1');
      expect(find.text('Edit cycle'), findsOneWidget);
      expect(dayTitles(tester), ['Push', 'Legs', 'Rest']);

      await dayAction(tester, 1, 'Change workout');
      await tester.tap(find.text('Legs').last);
      await tester.pumpAndSettle();
      expect(dayTitles(tester), ['Legs', 'Legs', 'Rest']);

      await dayAction(tester, 2, 'Make rest day');
      await dayAction(tester, 3, 'Make training day');
      await tester.tap(find.text('Push').last);
      await tester.pumpAndSettle();
      expect(dayTitles(tester), ['Legs', 'Rest', 'Push']);

      await dayAction(tester, 3, 'Move up');
      expect(dayTitles(tester), ['Legs', 'Push', 'Rest']);
      await dayAction(tester, 1, 'Move down');
      expect(dayTitles(tester), ['Push', 'Legs', 'Rest']);
      await dayAction(tester, 2, 'Remove');
      expect(dayTitles(tester), ['Push', 'Rest']);
    });

    testWidgets('AC8 saving the active cycle keeps today on its row', (
      tester,
    ) async {
      final repo = await pumpBuilder(tester, id: 'c1');
      // Today (Mon) is index 2 = the Rest row d3. Move it to the top.
      await dayAction(tester, 3, 'Move up');
      await dayAction(tester, 2, 'Move up');
      expect(dayTitles(tester), ['Rest', 'Push', 'Legs']);
      await save(tester);
      final c = repo.saved.single;
      expect(c.days[c.startDayIndex].id, 'd3');
      expect(c.startDate, DateTime.utc(2026, 11, 23));
      expect(c.isActive, isTrue);
    });

    testWidgets('AC11 a deleted workout is flagged and can be re-picked', (
      tester,
    ) async {
      await pumpBuilder(tester, id: 'c1', workouts: const [legs]);
      expect(dayTitles(tester), ['Workout deleted', 'Legs', 'Rest']);
      expect(find.text('Pick workout'), findsOneWidget);
      expect(find.text('2 days · 2 train, 1 rest'), findsNothing);
      expect(find.text('3 days · 2 train, 1 rest'), findsOneWidget);
      await tester.tap(find.text('Workout deleted').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Legs').last);
      await tester.pumpAndSettle();
      expect(dayTitles(tester), ['Legs', 'Legs', 'Rest']);
    });

    testWidgets('AC3 dragging a day by its handle reorders it', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpBuilder(tester, id: 'c1');
      final row = find.byKey(const ValueKey('d1'));
      final h = tester.getSize(row).height;
      final grip = find.descendant(
        of: row,
        matching: find.byIcon(Icons.drag_indicator),
      );
      final gesture = await tester.startGesture(tester.getCenter(grip));
      await tester.pump(const Duration(milliseconds: 600));
      for (var i = 0; i < 10; i++) {
        await gesture.moveBy(Offset(0, h * 0.9 / 10));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(dayTitles(tester), ['Legs', 'Push', 'Rest']);
      handle.dispose();
    });

    testWidgets('AC11 undoing the workout delete shows the day normally', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final templates = FakeTemplateRepository(const [push, legs]);
      await pumpBuilder(tester, id: 'c1', templates: templates);
      await templates.delete('push');
      await tester.pumpAndSettle();
      expect(dayTitles(tester).first, 'Workout deleted');
      await templates.restore('push');
      await tester.pumpAndSettle();
      expect(dayTitles(tester).first, 'Push');
      handle.dispose();
    });

    testWidgets('NFR-06 a 14-day cycle fits at 200 % text', (tester) async {
      final long = ppl.copyWith(
        days: [
          for (var i = 0; i < 14; i++)
            CycleDay(id: 'x$i', workoutId: i.isEven ? 'push' : null),
        ],
      );
      await pumpBuilder(
        tester,
        id: 'c1',
        repo: FakeCycleRepository([long]),
        textScale: 2,
      );
      for (var i = 0; i < 12; i++) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('edge a copy saves inactive with "(copy)"', (tester) async {
      final repo = await pumpBuilder(tester, copyOf: 'c1');
      expect(find.text('PPL (copy)'), findsOneWidget);
      expect(find.byKey(CycleEditorScreen.startDayKey), findsNothing);
      await save(tester);
      final c = repo.saved.single;
      expect((c.name, c.isActive), ('PPL (copy)', false));
      expect(repo.active.firstWhere((x) => x.id == 'c1').isActive, isTrue);
    });
  });

  group('SCH-01 builder: leaving and a11y', () {
    testWidgets('AC12 discard prompt only with changes', (tester) async {
      final repo = await pumpBuilder(tester, id: 'c1');
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(CycleEditorScreen), findsNothing);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await dayAction(tester, 3, 'Remove');
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(find.byType(CycleEditorScreen), findsNothing);
      expect(repo.saved, isEmpty);
    });

    testWidgets('NFR-06 labelled controls, fits at 200 % text', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpBuilder(tester, id: 'c1', textScale: 2);
      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('Reorder day 1'), findsOneWidget);
      expect(find.byTooltip('Actions for day 1'), findsOneWidget);
      handle.dispose();
    });
  });

  group('SCH-02 builder follows the rolled day', () {
    // Anchored Sat 21 on Push, done Sat; Legs waited Sun → today is Legs.
    final rolled = ppl.copyWith(
      startDate: DateTime.utc(2026, 11, 21),
      startDayIndex: 0,
    );
    final records = [
      DayRecord(
        id: 'r1',
        cycleId: 'c1',
        date: DateTime.utc(2026, 11, 21),
        dayId: 'd1',
        dayIndex: 0,
        status: DayStatus.done,
      ),
    ];

    String previewOn(WidgetTester tester, String date) => tester
        .widgetList<Text>(
          find.descendant(
            of: find.ancestor(of: find.text(date), matching: find.byType(Row)),
            matching: find.byType(Text),
          ),
        )
        .last
        .data!;

    testWidgets('AC12 preview and save keep today on the rolled row', (
      tester,
    ) async {
      final repo = await pumpBuilder(
        tester,
        id: 'c1',
        repo: FakeCycleRepository([rolled]),
        days: FakeDayRecordRepository(records),
      );
      await scrollTo(tester, find.text('Mon, Nov 23'));
      expect(previewOn(tester, 'Mon, Nov 23'), 'Legs');
      expect(previewOn(tester, 'Tue, Nov 24'), 'Rest');

      await tester.scrollUntilVisible(
        find.byTooltip('Actions for day 2'),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await dayAction(tester, 2, 'Move up');
      expect(dayTitles(tester), ['Legs', 'Push', 'Rest']);
      await save(tester);
      final c = repo.saved.single;
      expect(c.days[c.startDayIndex].id, 'd2');
      expect(c.startDate, DateTime.utc(2026, 11, 23));
    });
  });

  group('SCH-03 builder: weekday mode', () {
    const gb = Locale('en', 'GB'), us = Locale('en', 'US');
    // Stored Monday first: Mon Push, Tue Legs, Wed Rest, Thu Push, Fri Rest,
    // Sat Legs, Sun Rest. Rolling, active, anchored Sat 21 on Thu Push.
    final week = ppl.copyWith(
      id: 'c1',
      name: 'Week',
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
      startDate: DateTime.utc(2026, 11, 21),
      startDayIndex: 3,
    );
    final weekdays = week.copyWith(mode: CycleMode.weekdays);

    // (weekday, title) per row in list order, from each tile's semantics.
    List<(String, String)> rows(WidgetTester tester) {
      final f = find.bySemanticsLabel(
        RegExp('^(Mon|Tues|Wednes|Thurs|Fri|Satur|Sun)day, '),
      );
      return [
        for (var i = 0; i < f.evaluate().length; i++)
          switch (tester.getSemantics(f.at(i)).label.split(', ')) {
            [final w, final t, ...] => (w, t),
            _ => throw StateError('bad label'),
          },
      ];
    }

    Future<void> pickMode(WidgetTester tester, String mode) async {
      await tester.tap(
        find.descendant(
          of: find.byKey(CycleEditorScreen.modeKey),
          matching: find.text(mode),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> weekdayAction(
      WidgetTester tester,
      String weekday,
      String action,
    ) async {
      await tester.tap(find.byTooltip('Actions for $weekday'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(action).last);
      await tester.pumpAndSettle();
    }

    testWidgets('AC1 Rolling by default; Weekdays is saved with the cycle', (
      tester,
    ) async {
      final repo = await pumpBuilder(
        tester,
        id: 'c1',
        repo: FakeCycleRepository([week]),
      );
      final seg = tester.widget<RfSegmented<CycleMode>>(
        find.byKey(CycleEditorScreen.modeKey),
      );
      expect(seg.selected, CycleMode.rolling);
      await pickMode(tester, 'Weekdays');
      await save(tester);
      expect(repo.saved.single.mode, CycleMode.weekdays);
    });

    testWidgets('AC2 not 7 days: Weekdays cannot be chosen and says why', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpBuilder(tester, id: 'c1');
      expect(find.text('Weekday mode needs exactly 7 days'), findsOneWidget);
      await pickMode(tester, 'Weekdays');
      expect(
        tester
            .widget<RfSegmented<CycleMode>>(
              find.byKey(CycleEditorScreen.modeKey),
            )
            .selected,
        CycleMode.rolling,
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Weekdays')),
        matchesSemantics(
          isButton: true,
          hasEnabledState: true,
          isInMutuallyExclusiveGroup: true,
          hasSelectedState: true,
          label: 'Weekdays',
        ),
      );
      handle.dispose();
    });

    testWidgets('AC2 in Weekdays, adding and removing days is disabled', (
      tester,
    ) async {
      await pumpBuilder(
        tester,
        id: 'c1',
        repo: FakeCycleRepository([weekdays]),
      );
      await scrollTo(tester, find.byKey(CycleEditorScreen.addRestKey));
      for (final k in [
        CycleEditorScreen.addRestKey,
        CycleEditorScreen.addTrainingKey,
      ]) {
        expect(tester.widget<RfButton>(find.byKey(k)).onPressed, isNull);
      }
      expect(find.text('Weekday mode needs exactly 7 days'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byTooltip('Actions for Monday'),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byTooltip('Actions for Monday'));
      await tester.pumpAndSettle();
      expect(find.text('Remove'), findsNothing);
    });

    testWidgets('AC3 Monday-first locale: weekday rows from Monday', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpBuilder(
        tester,
        id: 'c1',
        repo: FakeCycleRepository([week]),
        locale: gb,
      );
      await pickMode(tester, 'Weekdays');
      expect(rows(tester), [
        ('Monday', 'Push'),
        ('Tuesday', 'Legs'),
        ('Wednesday', 'Rest'),
        ('Thursday', 'Push'),
        ('Friday', 'Rest'),
        ('Saturday', 'Legs'),
      ]);
      expect(find.text('Mon'), findsOneWidget, reason: 'badge');
      await scrollTo(tester, find.byTooltip('Actions for Sunday'));
      expect(rows(tester).last, ('Sunday', 'Rest'));
      handle.dispose();
    });

    testWidgets('AC3 Sunday-first locale lists Sunday first; same plan', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpBuilder(
        tester,
        id: 'c1',
        repo: FakeCycleRepository([weekdays]),
        locale: us,
      );
      expect(rows(tester).first, ('Sunday', 'Rest'));
      expect(rows(tester)[1], ('Monday', 'Push'));
      handle.dispose();
    });

    testWidgets('AC3 a new Weekdays cycle has no Today is day n; preview by '
        'weekday', (tester) async {
      await pumpBuilder(tester, locale: us);
      await tester.enterText(find.byKey(CycleEditorScreen.nameKey), 'Week');
      for (final w in ['Push', 'Legs', 'Push', 'Legs']) {
        await addTraining(tester, w);
      }
      for (var i = 0; i < 3; i++) {
        await addRest(tester);
      }
      await scrollTo(tester, find.byKey(CycleEditorScreen.startDayKey));
      await tester.scrollUntilVisible(
        find.byKey(CycleEditorScreen.modeKey),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await pickMode(tester, 'Weekdays');
      expect(find.byKey(CycleEditorScreen.startDayKey), findsNothing);
      await scrollTo(tester, find.text('Sun, Nov 29'));
      // Stored Mon..Sun = Push Legs Push Legs Rest Rest Rest; today is Monday.
      String on(String date) => tester
          .widgetList<Text>(
            find.descendant(
              of: find.ancestor(
                of: find.text(date),
                matching: find.byType(Row),
              ),
              matching: find.byType(Text),
            ),
          )
          .last
          .data!;
      expect(on('Mon, Nov 23'), 'Push');
      expect(on('Tue, Nov 24'), 'Legs');
      expect(on('Sun, Nov 29'), 'Rest');
      expect(on('Mon, Nov 30'), 'Push');
    });

    testWidgets('AC4 moving a row moves its workout to that weekday', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final repo = await pumpBuilder(
        tester,
        id: 'c1',
        repo: FakeCycleRepository([weekdays]),
        locale: us,
      );
      // Sunday-first: Sun Rest, Mon Push … Move Push down onto Tuesday.
      await weekdayAction(tester, 'Monday', 'Move down');
      expect(rows(tester).sublist(0, 3), [
        ('Sunday', 'Rest'),
        ('Monday', 'Legs'),
        ('Tuesday', 'Push'),
      ]);
      await save(tester);
      final c = repo.saved.single;
      expect(c.days.map((x) => x.id).take(2), ['w1', 'w0']);
      expect(c.days[6].id, 'w6', reason: 'Sunday unchanged');
      handle.dispose();
    });

    testWidgets('AC4 changing a row changes that weekday only', (tester) async {
      final repo = await pumpBuilder(
        tester,
        id: 'c1',
        repo: FakeCycleRepository([weekdays]),
        locale: us,
      );
      await weekdayAction(tester, 'Sunday', 'Make training day');
      await tester.tap(find.text('Legs').last);
      await tester.pumpAndSettle();
      await save(tester);
      final c = repo.saved.single;
      expect(c.days[6].workoutId, 'legs');
      expect(c.days[0].workoutId, 'push');
    });

    testWidgets("AC9 Rolling → Weekdays: today is today's weekday row", (
      tester,
    ) async {
      final repo = await pumpBuilder(
        tester,
        id: 'c1',
        repo: FakeCycleRepository([week]),
      );
      await pickMode(tester, 'Weekdays');
      await save(tester);
      final c = repo.saved.single;
      expect(
        (c.mode, c.startDate, c.startDayIndex),
        (CycleMode.weekdays, DateTime.utc(2026, 11, 23), 0),
      );
    });

    testWidgets("AC9 Weekdays → Rolling starts today on today's weekday row", (
      tester,
    ) async {
      final repo = await pumpBuilder(
        tester,
        id: 'c1',
        repo: FakeCycleRepository([weekdays]),
      );
      await scrollTo(tester, find.text('Mon, Nov 23'));
      await tester.scrollUntilVisible(
        find.byKey(CycleEditorScreen.modeKey),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await pickMode(tester, 'Rolling');
      await save(tester);
      final c = repo.saved.single;
      expect(
        (c.mode, c.startDate, c.startDayIndex),
        (CycleMode.rolling, DateTime.utc(2026, 11, 23), 0),
      );
    });

    testWidgets('edge a copy keeps Weekdays and saves inactive', (
      tester,
    ) async {
      final repo = await pumpBuilder(
        tester,
        copyOf: 'c1',
        repo: FakeCycleRepository([weekdays]),
      );
      await save(tester);
      final c = repo.saved.single;
      expect((c.mode, c.isActive), (CycleMode.weekdays, false));
    });

    testWidgets('NFR-06 weekdays at 200 % text', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpBuilder(
        tester,
        id: 'c1',
        repo: FakeCycleRepository([weekdays]),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('Cycle mode'), findsOneWidget);
      for (var i = 0; i < 10; i++) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      handle.dispose();
    });

    testWidgets('AC1 a new cycle starts as Rolling', (tester) async {
      await pumpBuilder(tester);
      expect(
        tester
            .widget<RfSegmented<CycleMode>>(
              find.byKey(CycleEditorScreen.modeKey),
            )
            .selected,
        CycleMode.rolling,
      );
    });

    testWidgets('AC9 a mode switch keeps earlier day history', (tester) async {
      final days = FakeDayRecordRepository([
        DayRecord(
          id: 'r1',
          cycleId: 'c1',
          date: DateTime.utc(2026, 11, 21),
          dayId: 'w3',
          dayIndex: 3,
          status: DayStatus.done,
        ),
      ]);
      await pumpBuilder(
        tester,
        id: 'c1',
        repo: FakeCycleRepository([week]),
        days: days,
      );
      await pickMode(tester, 'Weekdays');
      await save(tester);
      expect(days.all.map((r) => r.id), contains('r1'));
    });

    testWidgets('AC4 dragging a weekday row moves its workout to that day', (
      tester,
    ) async {
      final repo = await pumpBuilder(
        tester,
        id: 'c1',
        repo: FakeCycleRepository([weekdays]),
        locale: us,
      );
      // Sunday-first: drag Monday (Push) one row down onto Tuesday.
      final row = find.byKey(const ValueKey('w0'));
      final h = tester.getSize(row).height;
      final grip = find.descendant(
        of: row,
        matching: find.byIcon(Icons.drag_indicator),
      );
      final gesture = await tester.startGesture(tester.getCenter(grip));
      await tester.pump(const Duration(milliseconds: 600));
      for (var i = 0; i < 10; i++) {
        await gesture.moveBy(Offset(0, h * 0.9 / 10));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();
      await save(tester);
      expect(repo.saved.single.days.map((x) => x.id).take(2), ['w1', 'w0']);
    });
  });
}
