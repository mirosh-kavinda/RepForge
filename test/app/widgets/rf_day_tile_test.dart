import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/theme/rf_tokens.dart';
import 'package:repforge/app/widgets/rf_day_tile.dart';

import '../../helpers/pump_themed.dart';

BoxDecoration decorationOf(WidgetTester tester) =>
    tester.widget<DecoratedBox>(find.byKey(RfDayTile.surfaceKey)).decoration
        as BoxDecoration;

void main() {
  const labels = {
    RfDayState.done: 'Done',
    RfDayState.today: 'Today',
    RfDayState.rest: 'Rest',
    RfDayState.missed: 'Missed',
    RfDayState.planned: 'Planned',
  };

  group('FND-02 RfDayTile', () {
    for (final (name, brightness, c) in [
      ('light', Brightness.light, RfColors.light),
      ('dark', Brightness.dark, RfColors.dark),
    ]) {
      testWidgets('AC11 every state has a text label ($name)', (tester) async {
        for (final MapEntry(key: state, value: label) in labels.entries) {
          await pumpThemed(
            tester,
            RfDayTile(day: 21, state: state),
            brightness: brightness,
          );
          expect(find.text(label), findsOneWidget, reason: state.name);
          expect(find.text('21'), findsOneWidget);
          expect(
            tester.getSemantics(find.byType(RfDayTile)).label,
            '21, $label',
          );
        }
      });

      testWidgets('AC11 state styling matches design.md ($name)', (
        tester,
      ) async {
        await pumpThemed(
          tester,
          const RfDayTile(day: 1, state: RfDayState.done),
          brightness: brightness,
        );
        expect(decorationOf(tester).color, c.successTint);

        await pumpThemed(
          tester,
          const RfDayTile(day: 1, state: RfDayState.rest),
          brightness: brightness,
        );
        expect(decorationOf(tester).color, c.restTint);

        await pumpThemed(
          tester,
          const RfDayTile(day: 1, state: RfDayState.missed),
          brightness: brightness,
        );
        expect(decorationOf(tester).color, c.missedTint);

        await pumpThemed(
          tester,
          const RfDayTile(day: 1, state: RfDayState.today),
          brightness: brightness,
        );
        final side = (decorationOf(tester).border! as Border).top;
        expect(side.color, c.actionInk);
        expect(side.width, 2);

        await pumpThemed(
          tester,
          const RfDayTile(day: 1, state: RfDayState.planned),
          brightness: brightness,
        );
        expect(decorationOf(tester).border, isNull);
        expect(find.byKey(RfDayTile.dashedKey), findsOneWidget);
      });
    }

    testWidgets('tappable tile is a 48 dp control', (tester) async {
      var taps = 0;
      await pumpThemed(
        tester,
        RfDayTile(day: 3, state: RfDayState.planned, onTap: () => taps++),
      );
      await tester.tap(find.byType(RfDayTile));
      expect(taps, 1);
      final size = tester.getSize(find.byType(RfDayTile));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(
        tester
            .getSemantics(find.byType(RfDayTile))
            .getSemanticsData()
            .flagsCollection
            .isButton,
        isTrue,
      );
    });
  });
}
