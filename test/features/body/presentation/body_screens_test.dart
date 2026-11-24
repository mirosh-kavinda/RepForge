import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/app/widgets/rf_button.dart';
import 'package:repforge/core/clock.dart';
import 'package:repforge/core/metrics/body.dart';
import 'package:repforge/core/metrics/energy.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/features/body/domain/body_rules.dart';
import 'package:repforge/features/body/domain/body_snapshot.dart';
import 'package:repforge/features/body/presentation/body_card.dart';
import 'package:repforge/features/body/presentation/body_form_screen.dart';
import 'package:repforge/features/body/presentation/body_history_screen.dart';

import '../../../helpers/app_overrides.dart';
import '../fake_body_repository.dart';

const man = BodyProfile(sex: Sex.male, birthYear: 1996, heightCm: 180);
final today = DateTime.utc(2026, 11, 24);

BodySnapshot snap(String id, DateTime date, double kg, {double? scale}) {
  final input = BodyInput(
    weightKg: kg,
    activity: ActivityLevel.moderate,
    scaleBodyFatPct: scale,
  );
  return BodySnapshot(
    id: id,
    date: date,
    weightKg: kg,
    scaleBodyFatPct: scale,
    activity: ActivityLevel.moderate,
    results: computeBodyResults(input, man, today),
  );
}

late FakeBodyRepository body;

Future<void> openProgress(
  WidgetTester tester, {
  BodyProfile profile = man,
  List<BodySnapshot> snapshots = const [],
  UnitSystem units = UnitSystem.metric,
  double textScale = 1,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  body = FakeBodyRepository(profile: profile, snapshots: snapshots);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...signedInOverrides(body: body, units: units),
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

Future<void> openForm(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byKey(BodyCard.newKey),
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(BodyCard.newKey));
  await tester.pumpAndSettle();
}

Future<void> type(WidgetTester tester, Key key, String text) async {
  await tester.ensureVisible(find.byKey(key));
  await tester.enterText(find.byKey(key), text);
  await tester.pumpAndSettle();
}

bool saveEnabled(WidgetTester tester) =>
    tester.widget<RfButton>(find.byKey(BodyFormScreen.saveKey)).onPressed !=
    null;

Future<void> save(WidgetTester tester) async {
  await tester.tap(find.byKey(BodyFormScreen.saveKey));
  await tester.pumpAndSettle();
}

Future<void> scrollTo(WidgetTester tester, Finder f) =>
    tester.scrollUntilVisible(f, 200, scrollable: find.byType(Scrollable).last);

void main() {
  group('BOD-01 body snapshot', () {
    testWidgets('AC1 empty: no snapshot yet, with New snapshot', (
      tester,
    ) async {
      await openProgress(tester);
      expect(find.text('No body snapshot yet'), findsOneWidget);
      expect(find.byKey(BodyCard.newKey), findsOneWidget);
    });

    testWidgets('AC1 the latest snapshot and its results', (tester) async {
      await openProgress(
        tester,
        snapshots: [
          snap('a', DateTime.utc(2026, 11, 20), 82),
          snap('b', DateTime.utc(2026, 11, 23), 81),
        ],
      );
      await tester.scrollUntilVisible(
        find.text('Mon, Nov 23, 2026'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Mon, Nov 23, 2026'), findsOneWidget);
      expect(find.text('81.0 kg · Body fat —'), findsOneWidget);
      expect(find.text('25.0'), findsOneWidget, reason: 'BMI');
    });

    testWidgets('AC2 men see no hip; women do; activity remembered', (
      tester,
    ) async {
      await openProgress(tester);
      await openForm(tester);
      expect(find.byKey(BodyFormScreen.hipKey), findsNothing);
      expect(
        find.text('Moderate · on my feet part of the day'),
        findsOneWidget,
      );
      expect(find.text('kg'), findsOneWidget);

      await openProgress(
        tester,
        profile: const BodyProfile(
          sex: Sex.female,
          birthYear: 1994,
          heightCm: 165,
          activity: ActivityLevel.light,
        ),
        units: UnitSystem.imperial,
      );
      await openForm(tester);
      expect(find.byKey(BodyFormScreen.hipKey), findsOneWidget);
      expect(find.text('Light · some walking each day'), findsOneWidget);
      expect(find.text('lb'), findsOneWidget);
    });

    testWidgets('AC2 weight is required and range-checked', (tester) async {
      await openProgress(tester);
      await openForm(tester);
      expect(saveEnabled(tester), isFalse);
      await type(tester, BodyFormScreen.weightKey, '5');
      expect(find.text('Enter a weight between 25 and 350'), findsOneWidget);
      expect(saveEnabled(tester), isFalse);
      await type(tester, BodyFormScreen.weightKey, '81');
      expect(saveEnabled(tester), isTrue);
    });

    testWidgets('AC3 AC4 save: stored in kg / cm, results shown at once', (
      tester,
    ) async {
      await openProgress(tester, units: UnitSystem.imperial);
      await openForm(tester);
      await type(tester, BodyFormScreen.weightKey, '178.6');
      await type(tester, BodyFormScreen.waistKey, '33.5');
      await type(tester, BodyFormScreen.neckKey, '15');
      await save(tester);
      final s = body.saves.single;
      expect(s.weightKg, closeTo(81.0, 0.02));
      expect(s.waistCm, closeTo(85.09, 0.01));
      expect(s.activity, ActivityLevel.moderate);
      expect(find.byType(BodySnapshotScreen), findsOneWidget);
      expect(find.text('Body fat'), findsOneWidget);
      expect(find.text('BMI'), findsOneWidget);
      expect(body.profile.activity, ActivityLevel.moderate);
    });

    testWidgets('AC4 a scale value is used and marked', (tester) async {
      final handle = tester.ensureSemantics();
      await openProgress(tester);
      await openForm(tester);
      await type(tester, BodyFormScreen.weightKey, '81');
      await type(tester, BodyFormScreen.scaleKey, '18');
      await save(tester);
      expect(find.text('18.0 %'), findsOneWidget);
      expect(find.text('from scale'), findsOneWidget);
      expect(find.bySemanticsLabel('Weight, 81.0 kilograms'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Body fat, 18.0 percent, from scale'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('AC5 missing inputs show a dash and the reason', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openProgress(tester, profile: const BodyProfile(sex: Sex.male));
      await openForm(tester);
      await type(tester, BodyFormScreen.weightKey, '81');
      await save(tester);
      expect(find.text('Add your height in Profile'), findsWidgets);
      expect(find.text('Add waist and neck for body fat'), findsWidgets);
      expect(
        find.bySemanticsLabel('BMI, not available, Add your height in Profile'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('AC6 saving again today replaces it', (tester) async {
      await openProgress(tester);
      await openForm(tester);
      await type(tester, BodyFormScreen.weightKey, '81');
      await save(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await openForm(tester);
      await type(tester, BodyFormScreen.weightKey, '80.5');
      await save(tester);
      expect(body.active, hasLength(1));
      expect(body.active.single.weightKg, 80.5);
    });

    testWidgets('AC7 history newest first; open one; delete with Undo', (
      tester,
    ) async {
      await openProgress(
        tester,
        snapshots: [
          snap('a', DateTime.utc(2026, 11, 20), 82, scale: 19),
          snap('b', DateTime.utc(2026, 11, 23), 81),
        ],
      );
      await tester.scrollUntilVisible(
        find.byKey(BodyCard.openKey),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      final title = find.descendant(
        of: find.byKey(BodyCard.openKey),
        matching: find.text('Body'),
      );
      await tester.ensureVisible(title);
      await tester.pumpAndSettle();
      await tester.tap(title);
      await tester.pumpAndSettle();
      expect(find.byType(BodyHistoryScreen), findsOneWidget);
      final dates = [
        for (final t in tester.widgetList<Text>(
          find.descendant(
            of: find.byType(ListView),
            matching: find.textContaining('Nov'),
          ),
        ))
          t.data,
      ];
      expect(dates, ['Mon, Nov 23, 2026', 'Fri, Nov 20, 2026']);
      expect(
        find.text('82.0 kg · Body fat 19.0 % · from scale'),
        findsOneWidget,
      );
      await tester.tap(find.text('Fri, Nov 20, 2026'));
      await tester.pumpAndSettle();
      expect(find.byType(BodySnapshotScreen), findsOneWidget);
      await tester.tap(find.byKey(BodySnapshotScreen.deleteKey));
      await tester.pumpAndSettle();
      expect(find.byType(BodyHistoryScreen), findsOneWidget);
      expect(find.text('Fri, Nov 20, 2026'), findsNothing);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('Fri, Nov 20, 2026'), findsOneWidget);
    });

    testWidgets('edge an onboarding snapshot shows results worked out now', (
      tester,
    ) async {
      await openProgress(
        tester,
        snapshots: [
          BodySnapshot(id: 'o', date: DateTime.utc(2026, 11, 1), weightKg: 81),
        ],
      );
      await tester.scrollUntilVisible(
        find.byKey(BodyCard.openKey),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      final title = find.descendant(
        of: find.byKey(BodyCard.openKey),
        matching: find.text('Body'),
      );
      await tester.ensureVisible(title);
      await tester.pumpAndSettle();
      await tester.tap(title);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sun, Nov 1, 2026'));
      await tester.pumpAndSettle();
      expect(find.text('25.0'), findsOneWidget);
    });

    testWidgets('NFR-06 form and results fit at 200 % text', (tester) async {
      await openProgress(tester, textScale: 2);
      await openForm(tester);
      expect(tester.takeException(), isNull);
      await type(tester, BodyFormScreen.weightKey, '81');
      await save(tester);
      expect(tester.takeException(), isNull);
    });
  });
}
