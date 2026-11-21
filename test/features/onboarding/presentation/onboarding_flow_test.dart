import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/app/theme/rf_scales.dart';
import 'package:repforge/core/metrics/body.dart';
import 'package:repforge/core/metrics/energy.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/features/auth/data/providers.dart';
import 'package:repforge/features/home/presentation/home_screen.dart';
import 'package:repforge/features/onboarding/data/providers.dart';
import 'package:repforge/features/onboarding/domain/onboarding_answers.dart';
import 'package:repforge/features/onboarding/presentation/about_you_screen.dart';
import 'package:repforge/features/onboarding/presentation/goal_level_screen.dart';

import '../../auth/fake_auth_repository.dart';
import '../fake_onboarding_repository.dart';

Future<FakeOnboardingRepository> pumpOnboarding(
  WidgetTester tester, {
  String? region = 'GB',
  double textScale = 1,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  final repo = FakeOnboardingRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authChoiceMadeProvider.overrideWith((ref) => Stream.value(true)),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        onboardingRepositoryProvider.overrideWithValue(repo),
        deviceRegionProvider.overrideWithValue(region),
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
      expect(find.text('Step 1 of 2'), findsOneWidget);
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

    testWidgets('AC7 skip everything: Home in 2 taps', (tester) async {
      final repo = await pumpOnboarding(tester);
      await tapText(tester, 'Continue');
      await tapText(tester, 'Finish');
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(
        repo.saved.single,
        const OnboardingAnswers(units: UnitSystem.metric),
      );
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
      await tapText(tester, 'Finish');
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
      await tapText(tester, 'Finish');
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

    testWidgets('edge: Prefer not to say stores no sex', (tester) async {
      final repo = await toStep2(tester);
      await tapText(tester, 'Prefer not to say');
      await tapText(tester, 'Finish');
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
      await tapText(tester, 'Finish');
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
      await tapText(tester, 'Finish');
      expect(find.text("Couldn't save. Please try again."), findsOneWidget);
      expect(find.byType(AboutYouScreen), findsOneWidget);
      repo.failWith = null;
      await tapText(tester, 'Finish');
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
}
