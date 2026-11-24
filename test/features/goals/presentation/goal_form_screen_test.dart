import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/widgets/rf_button.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/features/goals/domain/goal.dart';
import 'package:repforge/features/goals/presentation/goal_form_screen.dart';
import 'package:repforge/features/goals/presentation/goals_screen.dart';

import '../goal_app.dart';

Future<void> openNew(WidgetTester tester) async {
  await openGoals(tester);
  await tester.tap(find.byKey(GoalsScreen.newKey));
  await tester.pumpAndSettle();
}

Future<void> enterTarget(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(GoalFormScreen.targetKey), text);
  await tester.pumpAndSettle();
}

bool canSave(WidgetTester tester) =>
    tester.widget<RfButton>(find.byKey(GoalFormScreen.saveKey)).onPressed !=
    null;

Future<void> save(WidgetTester tester) async {
  await tester.tap(find.byKey(GoalFormScreen.saveKey));
  await tester.pumpAndSettle();
}

void main() {
  group('GOL-01 goal form', () {
    testWidgets('AC2 strength: pick a lift, target must be above it', (
      tester,
    ) async {
      await pumpApp(
        tester,
        finished: [bench('a', d(10), 84), bench('b', d(20), 90)],
      );
      await openNew(tester);
      expect(canSave(tester), isFalse);
      await tester.tap(find.byKey(GoalFormScreen.liftKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bench Press').last);
      await tester.pumpAndSettle();
      expect(find.text('Now: 105.0 kg'), findsOneWidget);

      await enterTarget(tester, '100');
      expect(
        find.text('Enter a target above your current value'),
        findsOneWidget,
      );
      expect(canSave(tester), isFalse);
      await enterTarget(tester, '105');
      expect(find.text("You're already there"), findsOneWidget);

      await enterTarget(tester, '110');
      expect(canSave(tester), isTrue);
      await save(tester);
      final g = goals.live.single;
      expect(g.type, GoalType.strength);
      expect(g.exerciseId, 'Bench_Press');
      expect((g.startValue, g.target), (105, 110));
      expect(find.text('Bench Press estimated 1RM'), findsOneWidget);
    });

    testWidgets('edge no lift with an e1RM yet says so', (tester) async {
      await pumpApp(tester);
      await openNew(tester);
      expect(
        find.text('Log a lift with weight and up to 12 reps first'),
        findsOneWidget,
      );
    });

    testWidgets('AC2 AC3 weight: either way, projection before saving', (
      tester,
    ) async {
      await pumpApp(tester, body: falling);
      await openNew(tester);
      await tester.tap(find.text('Body weight'));
      await tester.pumpAndSettle();
      expect(find.text('Now: 82.0 kg'), findsOneWidget);
      await enterTarget(tester, '80');
      expect(find.text('Projected: Dec 15, 2026'), findsOneWidget);
      await enterTarget(tester, '90');
      expect(find.text('Not on track at your current trend'), findsOneWidget);
      expect(canSave(tester), isTrue);
      await enterTarget(tester, '80');
      await save(tester);
      final g = goals.live.single;
      expect((g.type, g.startValue, g.target), (GoalType.bodyWeight, 82, 80));
    });

    testWidgets('edge weight with no snapshot asks for one', (tester) async {
      await pumpApp(tester);
      await openNew(tester);
      await tester.tap(find.text('Body weight'));
      await tester.pumpAndSettle();
      expect(find.text('Save a body snapshot first'), findsOneWidget);
    });

    testWidgets('AC3 too little data says so', (tester) async {
      await pumpApp(tester, body: [falling.last]);
      await openNew(tester);
      await tester.tap(find.text('Body weight'));
      await tester.pumpAndSettle();
      await enterTarget(tester, '80');
      expect(
        find.text('Not enough data yet: log it 3 times over 2 weeks'),
        findsOneWidget,
      );
    });

    testWidgets('AC11 imperial: shown and entered in pounds, stored in kg', (
      tester,
    ) async {
      await pumpApp(tester, body: falling, units: UnitSystem.imperial);
      await openNew(tester);
      await tester.tap(find.text('Body weight'));
      await tester.pumpAndSettle();
      expect(find.text('Now: 180.8 lb'), findsOneWidget);
      await enterTarget(tester, '176');
      await save(tester);
      expect(goals.live.single.target, closeTo(79.83, 0.01));
    });

    testWidgets('AC8 edit: target and deadline change, start stays', (
      tester,
    ) async {
      await pumpApp(tester, body: falling, initial: [weightGoal('a')]);
      await openGoals(tester);
      await tester.tap(find.byKey(GoalTile.menuKey('a')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit').last);
      await tester.pumpAndSettle();
      expect(find.text('Edit goal'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(GoalFormScreen.targetKey))
            .controller!
            .text,
        '80.0',
      );
      await enterTarget(tester, '82');
      expect(find.text("You're already there"), findsOneWidget);
      await enterTarget(tester, '79');
      await save(tester);
      final g = goals.byId('a')!;
      expect((g.startValue, g.target), (84, 79));
    });

    testWidgets('AC2 deadline set and cleared', (tester) async {
      await pumpApp(tester, body: falling);
      await openNew(tester);
      await tester.tap(find.text('Body weight'));
      await tester.pumpAndSettle();
      await enterTarget(tester, '80');
      await tester.tap(find.byKey(GoalFormScreen.deadlineKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Jan 19, 2027'), findsOneWidget);
      expect(find.text('On pace'), findsOneWidget);
      await tester.tap(find.byKey(GoalFormScreen.clearDeadlineKey));
      await tester.pumpAndSettle();
      expect(find.text('No deadline'), findsOneWidget);
    });

    testWidgets('NFR-06 fits at 200 % text', (tester) async {
      await pumpApp(tester, body: falling, textScale: 2);
      await openNew(tester);
      await tester.tap(find.text('Body weight'));
      await tester.pumpAndSettle();
      await enterTarget(tester, '80');
      expect(tester.takeException(), isNull);
    });
  });

  group('GOL-01 review fixes', () {
    Future<void> openEdit(WidgetTester tester, String id) async {
      await openGoals(tester);
      await tester.tap(find.byKey(GoalTile.menuKey(id)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit').last);
      await tester.pumpAndSettle();
    }

    testWidgets('AC8 a weight-loss edit must stay below now', (tester) async {
      await pumpApp(tester, body: falling, initial: [weightGoal('a')]);
      await openEdit(tester, 'a');
      await enterTarget(tester, '86');
      expect(
        find.text('Enter a target below your current value'),
        findsOneWidget,
      );
      expect(canSave(tester), isFalse);
    });

    testWidgets('AC8 a passed deadline can be changed', (tester) async {
      await pumpApp(
        tester,
        body: falling,
        initial: [weightGoal('a', deadline: d(20))],
      );
      await openEdit(tester, 'a');
      await tester.tap(find.byKey(GoalFormScreen.deadlineKey));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Jan 19, 2027'), findsOneWidget);
    });

    testWidgets('edge the shown current value in lb is already there', (
      tester,
    ) async {
      await pumpApp(tester, body: falling, units: UnitSystem.imperial);
      await openNew(tester);
      await tester.tap(find.text('Body weight'));
      await tester.pumpAndSettle();
      await enterTarget(tester, '180.8');
      expect(find.text("You're already there"), findsOneWidget);
    });
  });
}
