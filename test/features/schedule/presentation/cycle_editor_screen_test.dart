import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/l10n/generated/app_localizations.dart';
import 'package:repforge/app/theme/rf_theme.dart';
import 'package:repforge/app/widgets/rf_button.dart';
import 'package:repforge/core/clock.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/schedule/data/providers.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';
import 'package:repforge/features/schedule/presentation/cycle_editor_screen.dart';
import 'package:repforge/features/workout/data/providers.dart';
import 'package:repforge/features/workout/domain/workout_template.dart';

import '../../workout/fakes.dart';
import '../fake_cycle_repository.dart';

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

// Started Sat 21 Nov at day 1 → Mon 23 is index 2 (Rest).
final ppl = Cycle(
  id: 'c1',
  name: 'PPL',
  days: const [
    CycleDay(id: 'd1', workoutId: 'push'),
    CycleDay(id: 'd2', workoutId: 'legs'),
    CycleDay(id: 'd3'),
  ],
  isActive: true,
  startDate: DateTime.utc(2026, 11, 21),
  startDayIndex: 0,
);

Future<FakeCycleRepository> pumpBuilder(
  WidgetTester tester, {
  String? id,
  String? copyOf,
  List<WorkoutTemplate> workouts = const [push, legs],
  FakeCycleRepository? repo,
  double textScale = 1,
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
        templateRepositoryProvider.overrideWithValue(
          FakeTemplateRepository(workouts),
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
        supportedLocales: const [Locale('en')],
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
}
