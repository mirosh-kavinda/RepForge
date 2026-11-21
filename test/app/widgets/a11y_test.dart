import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/theme/rf_scales.dart';
import 'package:repforge/app/theme/rf_tokens.dart';
import 'package:repforge/app/widgets/rf_button.dart';
import 'package:repforge/app/widgets/rf_chip.dart';
import 'package:repforge/app/widgets/rf_day_tile.dart';
import 'package:repforge/app/widgets/rf_stepper.dart';

import '../../helpers/pump_themed.dart';

Widget gallery() => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    for (final variant in RfButtonVariant.values)
      for (final size in RfButtonSize.values)
        RfButton(
          label: 'Start workout',
          variant: variant,
          size: size,
          onPressed: () {},
        ),
    RfStepper(
      label: 'Weight',
      unit: 'kg',
      value: 62.5,
      step: 2.5,
      min: 0,
      max: 500,
      onChanged: (_) {},
    ),
    Wrap(
      spacing: RfSpace.s8,
      children: [
        RfChip.filter(label: 'Chest', selected: true, onSelected: (_) {}),
        RfChip.filter(label: 'Legs', selected: false, onSelected: (_) {}),
        for (final role in RfRole.values)
          RfChip.status(label: role.name, role: role),
      ],
    ),
    Wrap(
      spacing: RfSpace.s4,
      runSpacing: RfSpace.s4,
      children: [
        for (final (i, state) in RfDayState.values.indexed)
          RfDayTile(day: i + 1, state: state, onTap: () {}),
      ],
    ),
  ],
);

void main() {
  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('FND-02 AC12 ${brightness.name} theme at ${scale}x text', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        await pumpThemed(
          tester,
          gallery(),
          brightness: brightness,
          textScale: scale,
          size: const Size(360, 2400),
        );
        expect(
          tester.getBottomLeft(find.byType(RfDayTile).last).dy,
          lessThan(2400),
          reason: 'everything on screen, so the guidelines see it all',
        );

        expect(tester.takeException(), isNull);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        semantics.dispose();
      });
    }
  }
}
