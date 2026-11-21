import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/theme/rf_tokens.dart';
import 'package:repforge/app/widgets/rf_button.dart';
import 'package:repforge/app/widgets/rf_chip.dart';
import 'package:repforge/app/widgets/rf_day_tile.dart';
import 'package:repforge/app/widgets/rf_stepper.dart';
import 'package:repforge/app/widgets/rf_tappable.dart';

import '../../helpers/pump_themed.dart';

Future<void> focusAndPress(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pump();
  await tester.sendKeyEvent(key);
  await tester.pump();
}

void main() {
  group('FND-02 AC12 keyboard and switch access', () {
    for (final key in [LogicalKeyboardKey.enter, LogicalKeyboardKey.space]) {
      testWidgets('RfButton activates with ${key.keyLabel}', (tester) async {
        var taps = 0;
        await pumpThemed(
          tester,
          RfButton(label: 'Go', onPressed: () => taps++),
        );
        await focusAndPress(tester, key);
        expect(taps, 1);
      });
    }

    testWidgets('RfChip, RfDayTile and RfStepper activate from the keyboard', (
      tester,
    ) async {
      final chip = <bool>[];
      var tile = 0;
      final stepper = <double>[];
      await pumpThemed(
        tester,
        Column(
          children: [
            RfChip.filter(label: 'Legs', selected: false, onSelected: chip.add),
            RfDayTile(day: 1, state: RfDayState.planned, onTap: () => tile++),
            RfStepper(
              label: 'Reps',
              value: 5,
              step: 1,
              min: 0,
              max: 10,
              onChanged: stepper.add,
            ),
          ],
        ),
      );
      await focusAndPress(tester, LogicalKeyboardKey.enter);
      expect(chip, [true]);
      await focusAndPress(tester, LogicalKeyboardKey.enter);
      expect(tile, 1);
      await focusAndPress(tester, LogicalKeyboardKey.enter);
      expect(stepper, [4]);
      await focusAndPress(tester, LogicalKeyboardKey.enter);
      expect(stepper, [4, 5]);
    });

    testWidgets('focused control shows an Ember-ink focus ring', (
      tester,
    ) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      await pumpThemed(tester, RfButton(label: 'Go', onPressed: () {}));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final ring = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(RfTappable),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final border = (ring.decoration as BoxDecoration).border! as Border;
      expect(border.top.color, RfColors.light.actionInk);
      expect(border.top.width, 2);
    });

    testWidgets('disabled controls are skipped by focus', (tester) async {
      await pumpThemed(tester, const RfButton(label: 'Go', onPressed: null));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<RfButton>(),
        isNull,
      );
    });
  });
}
