import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/theme/rf_tokens.dart';
import 'package:repforge/app/widgets/rf_chip.dart';

import '../../helpers/pump_themed.dart';

BoxDecoration decorationOf(WidgetTester tester) =>
    tester
            .widget<DecoratedBox>(
              find.descendant(
                of: find.byType(RfChip),
                matching: find.byKey(RfChip.surfaceKey),
              ),
            )
            .decoration
        as BoxDecoration;

Color? textColour(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style?.color;

void main() {
  group('FND-02 RfChip', () {
    for (final (name, brightness, c) in [
      ('light', Brightness.light, RfColors.light),
      ('dark', Brightness.dark, RfColors.dark),
    ]) {
      testWidgets('AC10 filter chip off is outlined ($name)', (tester) async {
        await pumpThemed(
          tester,
          RfChip.filter(label: 'Chest', selected: false, onSelected: (_) {}),
          brightness: brightness,
        );
        final d = decorationOf(tester);
        expect(d.color, isNull);
        expect((d.border! as Border).top.color, c.textMuted);
        expect(textColour(tester, 'Chest'), c.textSecondary);
        expect(find.byIcon(Icons.check), findsNothing);
      });

      testWidgets('AC10 filter chip on is Ember with a check ($name)', (
        tester,
      ) async {
        await pumpThemed(
          tester,
          RfChip.filter(label: 'Chest', selected: true, onSelected: (_) {}),
          brightness: brightness,
        );
        expect(decorationOf(tester).color, c.actionFill);
        expect(textColour(tester, 'Chest'), c.onSolid);
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('AC10 status chip uses tint and on-tint ($name)', (
        tester,
      ) async {
        for (final role in RfRole.values) {
          await pumpThemed(
            tester,
            RfChip.status(label: role.name, role: role),
            brightness: brightness,
          );
          expect(decorationOf(tester).color, c.tint(role), reason: role.name);
          expect(textColour(tester, role.name), c.onTint(role));
        }
      });
    }

    testWidgets('AC10 filter chip toggles and reports selection', (
      tester,
    ) async {
      final calls = <bool>[];
      await pumpThemed(
        tester,
        RfChip.filter(label: 'Legs', selected: false, onSelected: calls.add),
      );
      await tester.tap(find.byType(RfChip));
      expect(calls, [true]);
      final data = tester.getSemantics(find.byType(RfChip)).getSemanticsData();
      expect(data.label, 'Legs');
      expect(data.flagsCollection.isSelected, Tristate.isFalse);
      expect(
        tester.getSize(find.byType(RfChip)).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('status chip is not a control', (tester) async {
      await pumpThemed(
        tester,
        const RfChip.status(label: 'PR', role: RfRole.success),
      );
      final data = tester.getSemantics(find.byType(RfChip)).getSemanticsData();
      expect(data.label, 'PR');
      expect(data.flagsCollection.isButton, isFalse);
    });
  });
}
