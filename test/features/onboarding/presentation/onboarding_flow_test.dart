import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/app/theme/rf_scales.dart';
import 'package:repforge/core/clock.dart';
import 'package:repforge/core/metrics/body.dart';
import 'package:repforge/core/metrics/energy.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/features/auth/data/providers.dart';
import 'package:repforge/features/home/presentation/home_screen.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/onboarding/data/providers.dart';
import 'package:repforge/features/onboarding/domain/onboarding_answers.dart';
import 'package:repforge/features/onboarding/presentation/about_you_screen.dart';
import 'package:repforge/features/onboarding/presentation/goal_level_screen.dart';
import 'package:repforge/features/onboarding/presentation/plan_screen.dart';
import 'package:repforge/features/schedule/data/providers.dart';
import 'package:repforge/features/schedule/presentation/cycle_editor_screen.dart';
import 'package:repforge/features/workout/data/providers.dart';
import 'package:repforge/features/workout/data/starter_templates.dart';
import 'package:repforge/features/workout/domain/workout_template.dart';

import '../../auth/fake_auth_repository.dart';
import '../../schedule/fake_cycle_repository.dart';
import '../../workout/fakes.dart';
import '../fake_onboarding_repository.dart';

final starters = [
  for (final t in starterTemplates) t.copyWith(id: t.name.toLowerCase()),
];
late FakeCycleRepository cycles;

Future<FakeOnboardingRepository> pumpOnboarding(
  WidgetTester tester, {
  String? region = 'GB',
  double textScale = 1,
  List<WorkoutTemplate>? workouts,
}) async {
  cycles = FakeCycleRepository();
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  final repo = FakeOnboardingRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authChoiceMadeProvider.overrideWith((ref) => Stream.value(true)),
        authRepositoryProvider.overrideWithValue(
          FakeAuthRepository()..online = false,
        ),
        onboardingRepositoryProvider.overrideWithValue(repo),
        deviceRegionProvider.overrideWithValue(region),
        templateRepositoryProvider.overrideWithValue(
          FakeTemplateRepository(workouts ?? starters),
        ),
        cycleRepositoryProvider.overrideWithValue(cycles),
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
  return repo;
}

// Step 2 Continue; when that reaches step 3, finish without a plan.
Future<void> finishStep2(WidgetTester tester) async {
  await tapText(tester, 'Continue');
  if (find.text('Skip for now').evaluate().isNotEmpty) {
    await tapText(tester, 'Skip for now');
  }
}

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).first);
  await tester.tap(find.text(text).first);
  await tester.pumpAndSettle();
}

Future<void> type(WidgetTester tester, Key key, String text) async {
  final f = find.byWidgetPredicate(
    (w) => w is TextFormField && '${w.key}'.contains('$key'.split("'")[1]),
  );
  await tester.ensureVisible(f.first);
  await tester.enterText(f.first, text);
  await tester.pump();
}

void main() {
  group('ONB-01 step 1', () {
    testWidgets('AC3 goal cards with meanings, experience, all optional', (
      tester,
    ) async {
      await pumpOnboarding(tester);
      expect(find.byType(GoalLevelScreen), findsOneWidget);
      expect(find.text('Step 1 of 3'), findsOneWidget);
      for (final goal in [
        'Build muscle',
        'Get stronger',
        'Lose fat',
        'Stay consistent',
      ]) {
        expect(find.text(goal), findsOneWidget);
      }
      expect(find.text('Hypertrophy: 8–12 reps, more volume'), findsOneWidget);
      await tapText(tester, 'Get stronger');
      expect(
        tester.getSemantics(find.bySemanticsLabel(RegExp('^Get stronger'))),
        matchesSemantics(
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          isInMutuallyExclusiveGroup: true,
          hasTapAction: true,
          label: 'Get stronger. Strength: 3–6 reps, heavier loads',
        ),
      );
      // Tapping again clears it: goal is optional.
      await tapText(tester, 'Get stronger');
      expect(
        tester
            .getSemantics(find.bySemanticsLabel(RegExp('^Get stronger')))
            .flagsCollection
            .isSelected
            .toBoolOrNull(),
        isNot(true),
      );
    });

    testWidgets('AC7 skip everything: Home in 3 taps with PPL + Rest', (
      tester,
    ) async {
      final repo = await pumpOnboarding(tester);
      await tapText(tester, 'Continue');
      await tapText(tester, 'Continue');
      expect(find.byType(PlanScreen), findsOneWidget);
      await tester.tap(find.byKey(PlanScreen.startKey));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(
        repo.saved.single,
        const OnboardingAnswers(units: UnitSystem.metric),
      );
      expect(cycles.saved.single.name, 'PPL + Rest');
      expect(find.text('Day 1 of 4 · Push'), findsOneWidget);
    });

    testWidgets('AC8 back and forward keeps answers', (tester) async {
      await pumpOnboarding(tester);
      await tapText(tester, 'Lose fat');
      await tapText(tester, 'Advanced');
      await tapText(tester, 'Continue');
      await type(tester, AboutYouScreen.birthYearKey, '1990');
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(GoalLevelScreen), findsOneWidget);
      await tapText(tester, 'Continue');
      expect(find.text('1990'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(
        tester
            .getSemantics(find.bySemanticsLabel(RegExp('^Lose fat')))
            .flagsCollection
            .isSelected
            .toBoolOrNull(),
        isTrue,
      );
    });
  });

  group('ONB-01 step 2', () {
    Future<FakeOnboardingRepository> toStep2(
      WidgetTester tester, {
      String? region = 'GB',
    }) async {
      final repo = await pumpOnboarding(tester, region: region);
      await tapText(tester, 'Continue');
      expect(find.byType(AboutYouScreen), findsOneWidget);
      return repo;
    }

    testWidgets('AC4 AC6 metric answers are saved as typed', (tester) async {
      final repo = await toStep2(tester);
      await tapText(tester, 'Female');
      await type(tester, AboutYouScreen.birthYearKey, '1994');
      await type(tester, AboutYouScreen.heightKey, '165');
      await type(tester, AboutYouScreen.weightKey, '61.5');
      await type(tester, AboutYouScreen.waistKey, '72');
      await tapText(tester, 'Choose (optional)');
      await tapText(tester, 'Active · on my feet most of the day');
      await finishStep2(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(
        repo.saved.single,
        const OnboardingAnswers(
          units: UnitSystem.metric,
          sex: Sex.female,
          birthYear: 1994,
          heightCm: 165,
          weightKg: 61.5,
          waistCm: 72,
          activity: ActivityLevel.active,
        ),
      );
    });

    testWidgets('AC4 a US phone defaults to imperial; stored in metric', (
      tester,
    ) async {
      final repo = await toStep2(tester, region: 'US');
      expect(find.text('Height (ft)'), findsOneWidget);
      await type(tester, AboutYouScreen.heightKey, '5');
      await type(tester, AboutYouScreen.heightInchesKey, '10');
      await type(tester, AboutYouScreen.weightKey, '180');
      await type(tester, AboutYouScreen.waistKey, '32');
      await finishStep2(tester);
      final a = repo.saved.single;
      expect(a.units, UnitSystem.imperial);
      expect(a.heightCm, closeTo(177.8, 1e-9));
      expect(a.weightKg, closeTo(81.647, 0.001));
      expect(a.waistCm, closeTo(81.28, 1e-9));
    });

    testWidgets('AC4 switching units converts what was typed', (tester) async {
      await toStep2(tester);
      await type(tester, AboutYouScreen.heightKey, '180');
      await type(tester, AboutYouScreen.weightKey, '100');
      await tapText(tester, 'lb · in');
      expect(find.text('5'), findsOneWidget);
      expect(find.text('10.9'), findsOneWidget);
      expect(find.text('220.5'), findsOneWidget);
    });

    testWidgets('AC4 switching units back and forth never drifts values', (
      tester,
    ) async {
      final repo = await toStep2(tester);
      await type(tester, AboutYouScreen.heightKey, '180');
      await type(tester, AboutYouScreen.weightKey, '74.2');
      await tapText(tester, 'lb · in');
      await tapText(tester, 'kg · cm');
      await tapText(tester, 'lb · in');
      await finishStep2(tester);
      expect(repo.saved.single.heightCm, 180);
      expect(repo.saved.single.weightKg, 74.2);
    });

    testWidgets('edge: imperial height needs whole feet and under 12 in', (
      tester,
    ) async {
      final repo = await toStep2(tester, region: 'US');
      await type(tester, AboutYouScreen.heightKey, '5.5');
      await finishStep2(tester);
      expect(find.textContaining('Enter a height'), findsOneWidget);
      await type(tester, AboutYouScreen.heightKey, '5');
      await type(tester, AboutYouScreen.heightInchesKey, '12');
      await finishStep2(tester);
      expect(find.textContaining('Enter a height'), findsOneWidget);
      expect(repo.saved, isEmpty);
    });

    testWidgets('AC9 offline: the whole flow still saves', (tester) async {
      // Onboarding never touches the network; the auth fake is offline too.
      final repo = await toStep2(tester);
      await type(tester, AboutYouScreen.weightKey, '70');
      await finishStep2(tester);
      expect(repo.saved.single.weightKg, 70);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('edge: Prefer not to say stores no sex', (tester) async {
      final repo = await toStep2(tester);
      await tapText(tester, 'Prefer not to say');
      await finishStep2(tester);
      expect(repo.saved.single.sex, isNull);
    });

    testWidgets('AC5 out-of-range values show inline and save nothing', (
      tester,
    ) async {
      final repo = await toStep2(tester);
      await type(tester, AboutYouScreen.birthYearKey, '2020');
      await type(tester, AboutYouScreen.heightKey, '30');
      await type(tester, AboutYouScreen.weightKey, '900');
      await type(tester, AboutYouScreen.waistKey, '10');
      await finishStep2(tester);
      expect(
        find.text('Enter a birth year for an age of 13 to 100.'),
        findsOneWidget,
      );
      expect(find.textContaining('Enter a height'), findsOneWidget);
      expect(find.textContaining('Enter a weight'), findsOneWidget);
      expect(find.textContaining('Enter a waist'), findsOneWidget);
      expect(repo.saved, isEmpty);
      expect(find.byType(AboutYouScreen), findsOneWidget);
    });

    testWidgets('a failed save shows retry and stays', (tester) async {
      final repo = await toStep2(tester)
        ..failWith = Exception('disk full');
      await finishStep2(tester);
      expect(find.text("Couldn't save. Please try again."), findsOneWidget);
      expect(find.byType(PlanScreen), findsOneWidget);
      repo.failWith = null;
      await tapText(tester, 'Skip for now');
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('NFR-06 fits at 200 % text; segments are 48 dp', (
      tester,
    ) async {
      await pumpOnboarding(tester, textScale: 2);
      expect(tester.takeException(), isNull);
      await tapText(tester, 'Continue');
      expect(tester.takeException(), isNull);
      final segment = find.bySemanticsLabel('Female');
      expect(
        tester.getSize(segment).height,
        greaterThanOrEqualTo(RfSize.minTarget),
      );
    });
  });

  group('SCH-01 AC10 onboarding step 3', () {
    Future<FakeOnboardingRepository> toStep3(
      WidgetTester tester, {
      List<WorkoutTemplate>? workouts,
    }) async {
      final repo = await pumpOnboarding(tester, workouts: workouts);
      await tapText(tester, 'Continue');
      await tapText(tester, 'Continue');
      expect(find.text('Step 3 of 3'), findsOneWidget);
      expect(find.text('Pick a starting plan'), findsOneWidget);
      return repo;
    }

    testWidgets('step 2 saves nothing; three plans, PPL recommended', (
      tester,
    ) async {
      final repo = await toStep3(tester);
      expect(repo.saved, isEmpty);
      for (final p in ['PPL + Rest', 'Upper / Lower', 'Full Body + Rest']) {
        expect(find.text(p), findsOneWidget);
      }
      expect(find.text('Recommended'), findsOneWidget);
    });

    testWidgets('picking Upper / Lower saves it active from today', (
      tester,
    ) async {
      final repo = await toStep3(tester);
      await tapText(tester, 'Upper / Lower');
      await tester.tap(find.byKey(PlanScreen.startKey));
      await tester.pumpAndSettle();
      final c = cycles.saved.single;
      expect(c.days.map((d) => d.workoutId), [
        'upper',
        'lower',
        null,
        'upper',
        'lower',
        null,
      ]);
      expect(
        (c.isActive, c.startDate, c.startDayIndex),
        (true, DateTime.utc(2026, 11, 23), 0),
      );
      expect(repo.saved, hasLength(1));
    });

    testWidgets('Skip finishes with no cycle', (tester) async {
      final repo = await toStep3(tester);
      await tapText(tester, 'Skip for now');
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(repo.saved, hasLength(1));
      expect(cycles.saved, isEmpty);
    });

    testWidgets('Build my own finishes and opens the builder', (tester) async {
      final repo = await toStep3(tester);
      await tapText(tester, 'Build my own cycle instead');
      expect(repo.saved, hasLength(1));
      expect(find.byType(CycleEditorScreen), findsOneWidget);
    });

    testWidgets('edge a plan missing a starter workout is hidden', (
      tester,
    ) async {
      await toStep3(
        tester,
        workouts: starters.where((w) => w.name != 'Upper').toList(),
      );
      expect(find.text('Upper / Lower'), findsNothing);
      expect(find.text('PPL + Rest'), findsOneWidget);
    });

    testWidgets('NFR-06 step 3 fits at 200 % text', (tester) async {
      await pumpOnboarding(tester, textScale: 2);
      await tapText(tester, 'Continue');
      await tapText(tester, 'Continue');
      expect(tester.takeException(), isNull);
      expect(find.byType(PlanScreen), findsOneWidget);
    });
  });
}
