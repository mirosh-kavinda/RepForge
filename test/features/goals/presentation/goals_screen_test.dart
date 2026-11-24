import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/features/goals/presentation/goal_form_screen.dart';
import 'package:repforge/features/goals/presentation/goals_screen.dart';

import '../goal_app.dart';

Future<void> menu(WidgetTester tester, String id, String action) async {
  await tester.tap(find.byKey(GoalTile.menuKey(id)));
  await tester.pumpAndSettle();
  await tester.tap(find.text(action).last);
  await tester.pumpAndSettle();
}

void main() {
  group('GOL-01 goals screen', () {
    testWidgets('AC1 none yet: says so, with New goal', (tester) async {
      await pumpApp(tester);
      await openGoals(tester);
      expect(find.text('No goals yet'), findsOneWidget);
      await tester.tap(find.text('New goal').last);
      await tester.pumpAndSettle();
      expect(find.byType(GoalFormScreen), findsOneWidget);
    });

    testWidgets('AC4 AC5 path, percent, projection and pace in words', (
      tester,
    ) async {
      await pumpApp(
        tester,
        body: falling,
        initial: [
          weightGoal('a', deadline: d(1, 1, 2027)),
          weightGoal('b', target: 78, deadline: d(1, 12), day: 2),
        ],
      );
      await openGoals(tester);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('84.0 kg → 82.0 kg → 80.0 kg'), findsOneWidget);
      expect(find.text('50 %'), findsOneWidget);
      expect(find.text('Projected: Dec 15, 2026'), findsOneWidget);
      expect(find.text('Deadline: Jan 1, 2027 · On pace'), findsOneWidget);
      expect(find.text('Deadline: Dec 1, 2026 · Behind'), findsOneWidget);
    });

    testWidgets('AC7 Mark achieved moves it to Achieved with today', (
      tester,
    ) async {
      await pumpApp(tester, body: falling, initial: [weightGoal('a')]);
      await openGoals(tester);
      await menu(tester, 'a', 'Mark achieved');
      expect(find.text('Achieved'), findsOneWidget);
      expect(find.text('Achieved Nov 24, 2026'), findsOneWidget);
      expect(find.text('Active'), findsNothing);
    });

    testWidgets('AC9 delete, then Undo brings it back', (tester) async {
      await pumpApp(tester, body: falling, initial: [weightGoal('a')]);
      await openGoals(tester);
      await menu(tester, 'a', 'Delete');
      expect(find.text('No goals yet'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('84.0 kg → 82.0 kg → 80.0 kg'), findsOneWidget);
    });

    testWidgets('AC10 pin to Home, one at a time', (tester) async {
      await pumpApp(
        tester,
        body: falling,
        initial: [weightGoal('a', pinned: true), weightGoal('b', day: 2)],
      );
      await openGoals(tester);
      expect(find.text('Pinned to Home'), findsOneWidget);
      await menu(tester, 'b', 'Pin to Home');
      expect(find.text('Pinned to Home'), findsOneWidget);
      expect(goals.byId('b')!.pinned, isTrue);
      expect(goals.byId('a')!.pinned, isFalse);
    });

    testWidgets('AC6 data already past the target: achieved by itself', (
      tester,
    ) async {
      await pumpApp(
        tester,
        body: falling,
        initial: [weightGoal('a', target: 83)],
      );
      await openGoals(tester);
      expect(find.text('Achieved Nov 3, 2026'), findsOneWidget);
    });

    testWidgets('NFR-06 fits at 200 %; menu is a labelled 48 dp control', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpApp(
        tester,
        body: falling,
        initial: [weightGoal('a', deadline: d(1, 1, 2027))],
        textScale: 2,
      );
      await openGoals(tester);
      expect(tester.takeException(), isNull);
      expect(find.byTooltip('Goal actions'), findsOneWidget);
      expect(
        tester.getSize(find.byKey(GoalTile.menuKey('a'))).height,
        greaterThanOrEqualTo(48),
      );
      handle.dispose();
    });
  });

  group('GOL-01 review fixes', () {
    testWidgets('AC5 a passed deadline says so in words', (tester) async {
      await pumpApp(
        tester,
        body: falling,
        initial: [weightGoal('a', deadline: d(20))],
      );
      await openGoals(tester);
      expect(
        find.text('Deadline: Nov 20, 2026 · Deadline passed'),
        findsOneWidget,
      );
    });
  });
}
