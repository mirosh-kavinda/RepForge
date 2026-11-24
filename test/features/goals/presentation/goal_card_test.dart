import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/features/goals/presentation/goal_card.dart';
import 'package:repforge/features/goals/presentation/goal_form_screen.dart';
import 'package:repforge/features/goals/presentation/goals_screen.dart';

import '../goal_app.dart';

Future<void> scrollToCard(WidgetTester tester, Finder f) => tester
    .scrollUntilVisible(f, 200, scrollable: find.byType(Scrollable).first);

void main() {
  group('GOL-01 Home goal card', () {
    testWidgets('AC10 no active goal: Set a goal opens New goal', (
      tester,
    ) async {
      await pumpApp(tester);
      await scrollToCard(tester, find.byKey(GoalCard.setKey));
      await tester.tap(find.byKey(GoalCard.setKey));
      await tester.pumpAndSettle();
      expect(find.byType(GoalFormScreen), findsOneWidget);
    });

    testWidgets('AC10 the pinned goal, else the newest; tap opens Goals', (
      tester,
    ) async {
      await pumpApp(
        tester,
        body: falling,
        initial: [
          weightGoal('old', target: 81, pinned: true),
          weightGoal('new', target: 78, day: 5),
        ],
      );
      await scrollToCard(tester, find.byKey(GoalCard.cardKey));
      expect(find.text('84.0 kg → 82.0 kg → 81.0 kg'), findsOneWidget);
      expect(find.text('67 %'), findsOneWidget);
      await tester.tap(find.byKey(GoalCard.cardKey));
      await tester.pumpAndSettle();
      expect(find.byType(GoalsScreen), findsOneWidget);
    });

    testWidgets('AC10 with none pinned, the newest active goal', (
      tester,
    ) async {
      await pumpApp(
        tester,
        body: falling,
        initial: [
          weightGoal('old', target: 81),
          weightGoal('new', target: 78, day: 5),
        ],
      );
      await scrollToCard(tester, find.byKey(GoalCard.cardKey));
      expect(find.text('84.0 kg → 82.0 kg → 78.0 kg'), findsOneWidget);
    });

    testWidgets('NFR-06 one label for screen readers; 200 % text', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpApp(
        tester,
        body: falling,
        initial: [weightGoal('a', pinned: true)],
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      await scrollToCard(tester, find.byKey(GoalCard.cardKey));
      expect(
        tester.getSemantics(find.byKey(GoalCard.cardKey)),
        matchesSemantics(
          label:
              'Body weight: 84.0 kg → 82.0 kg → 80.0 kg, 50 %. '
              'Projected: Dec 15, 2026',
          hint: 'Opens Goals',
          isButton: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });
  });

  group('GOL-01 review fixes', () {
    testWidgets('edge reaching the pinned goal falls back to the newest', (
      tester,
    ) async {
      await pumpApp(
        tester,
        body: falling,
        initial: [
          // 83 is already reached (Nov 3), so it is achieved and unpinned.
          weightGoal('reached', target: 83, pinned: true, day: 9),
          weightGoal('next', target: 78, day: 5),
        ],
      );
      await scrollToCard(tester, find.byKey(GoalCard.cardKey));
      expect(find.text('84.0 kg → 82.0 kg → 78.0 kg'), findsOneWidget);
      expect(goals.byId('reached')!.pinned, isFalse);
    });
  });
}
