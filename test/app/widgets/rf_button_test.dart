import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/theme/rf_theme.dart';
import 'package:repforge/app/theme/rf_tokens.dart';
import 'package:repforge/app/widgets/rf_button.dart';

import '../../helpers/pump_themed.dart';

Color? fillOf(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byType(RfButton),
      matching: find.byKey(RfButton.surfaceKey),
    ),
  );
  return (box.decoration as BoxDecoration).color;
}

void main() {
  group('FND-02 RfButton', () {
    testWidgets('AC8 fires on tap in every variant', (tester) async {
      for (final variant in RfButtonVariant.values) {
        var taps = 0;
        await pumpThemed(
          tester,
          RfButton(label: 'Save', variant: variant, onPressed: () => taps++),
        );
        await tester.tap(find.byType(RfButton));
        expect(taps, 1, reason: variant.name);
      }
    });

    testWidgets('AC8 sizes lg 52 and md 44, both with a 48 dp hit area', (
      tester,
    ) async {
      await pumpThemed(tester, RfButton(label: 'Go', onPressed: () {}));
      expect(tester.getSize(find.byKey(RfButton.surfaceKey)).height, 52);

      await pumpThemed(
        tester,
        RfButton(label: 'Go', size: RfButtonSize.md, onPressed: () {}),
      );
      expect(tester.getSize(find.byKey(RfButton.surfaceKey)).height, 44);
      expect(tester.getSize(find.byType(RfButton)).height, 48);
    });

    testWidgets('AC8 pressed darkens the fill by 8 % lightness', (
      tester,
    ) async {
      await pumpThemed(tester, RfButton(label: 'Go', onPressed: () {}));
      const c = RfColors.light;
      expect(fillOf(tester), c.actionFill);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(RfButton)),
      );
      await tester.pump();
      expect(fillOf(tester), rfPressed(c.actionFill));
      await gesture.up();
      await tester.pump();
      expect(fillOf(tester), c.actionFill);

      final hsl = HSLColor.fromColor(c.actionFill);
      expect(
        HSLColor.fromColor(rfPressed(c.actionFill)).lightness,
        closeTo(hsl.lightness - 0.08, 0.005),
      );
    });

    testWidgets('AC8 disabled is 40 % opacity and does not fire', (
      tester,
    ) async {
      await pumpThemed(tester, const RfButton(label: 'Go', onPressed: null));
      final opacity = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(RfButton),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, 0.4);
      expect(
        tester.getSemantics(find.byType(RfButton)),
        matchesSemantics(
          label: 'Go',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
    });

    testWidgets('AC8 loading keeps the label, shows a spinner, does not fire', (
      tester,
    ) async {
      var taps = 0;
      await pumpThemed(
        tester,
        RfButton(label: 'Save', loading: true, onPressed: () => taps++),
        settle: false,
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Save'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(RfButton));
      expect(taps, 0);
      expect(tester.getSemantics(find.byType(RfButton)).label, 'Save, Loading');
    });

    testWidgets('AC8 pressed secondary darkens its ink by 8 % lightness', (
      tester,
    ) async {
      await pumpThemed(
        tester,
        RfButton(
          label: 'Go',
          variant: RfButtonVariant.secondary,
          onPressed: () {},
        ),
      );
      const c = RfColors.light;
      Color outline() =>
          ((tester
                              .widget<DecoratedBox>(
                                find.byKey(RfButton.surfaceKey),
                              )
                              .decoration
                          as BoxDecoration)
                      .border!
                  as Border)
              .top
              .color;
      expect(outline(), c.actionInk);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(RfButton)),
      );
      await tester.pump();
      expect(outline(), rfPressed(c.actionInk));
      expect(
        tester.widget<Text>(find.text('Go')).style?.color,
        rfPressed(c.actionInk),
      );
      await gesture.up();
    });
  });
}
