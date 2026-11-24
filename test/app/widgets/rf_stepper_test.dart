import 'dart:ui' show Tristate;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/widgets/rf_stepper.dart';

import '../../helpers/pump_themed.dart';

class Harness extends StatefulWidget {
  const Harness({
    required this.initial,
    required this.step,
    this.min = 0,
    this.max = 500,
    this.changes,
    super.key,
  });

  final double initial;
  final double step;
  final double min;
  final double max;
  final List<double>? changes;

  @override
  State<Harness> createState() => _HarnessState();
}

class _HarnessState extends State<Harness> {
  late double value = widget.initial;

  @override
  Widget build(BuildContext context) => RfStepper(
    label: 'Weight',
    unit: 'kg',
    value: value,
    step: widget.step,
    min: widget.min,
    max: widget.max,
    onChanged: (v) {
      widget.changes?.add(v);
      setState(() => value = v);
    },
  );
}

Finder get plus => find.bySemanticsLabel('Increase Weight');
Finder get minus => find.bySemanticsLabel('Decrease Weight');

void main() {
  group('FND-02 RfStepper', () {
    testWidgets('AC9 tap changes the value by one step', (tester) async {
      final changes = <double>[];
      await pumpThemed(
        tester,
        Harness(initial: 60, step: 2.5, changes: changes),
      );
      expect(find.text('60 kg', findRichText: true), findsOneWidget);
      await tester.tap(plus);
      await tester.pump();
      expect(changes, [62.5]);
      expect(find.text('62.5 kg', findRichText: true), findsOneWidget);
      await tester.tap(minus);
      await tester.tap(minus);
      await tester.pump();
      expect(changes, [62.5, 60, 57.5]);
    });

    testWidgets('AC9 no float noise with 0.1 steps', (tester) async {
      final changes = <double>[];
      await pumpThemed(
        tester,
        Harness(initial: 70, step: 0.1, changes: changes),
      );
      for (var i = 0; i < 3; i++) {
        await tester.tap(plus);
        await tester.pump();
      }
      expect(changes.last, 70.3);
      expect(find.text('70.3 kg', findRichText: true), findsOneWidget);
    });

    testWidgets('AC9 never passes min or max; blocked button says so', (
      tester,
    ) async {
      final changes = <double>[];
      await pumpThemed(
        tester,
        Harness(initial: 0, step: 1, max: 2, changes: changes),
      );
      await tester.tap(minus);
      await tester.pump();
      expect(changes, isEmpty);
      final minusNode = tester.getSemantics(minus);
      expect(minusNode.getSemanticsData().hint, 'at minimum');
      expect(minusNode.flagsCollection.isEnabled, Tristate.isFalse);

      for (var i = 0; i < 4; i++) {
        await tester.tap(plus);
        await tester.pump();
      }
      expect(changes, [1, 2]);
      expect(tester.getSemantics(plus).getSemanticsData().hint, 'at maximum');
    });

    testWidgets('AC9 haptic tick on every step', (tester) async {
      final haptics = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            haptics.add(call.arguments as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await pumpThemed(tester, const Harness(initial: 10, step: 1));
      await tester.tap(plus);
      await tester.tap(minus);
      await tester.pump();
      expect(haptics, [
        'HapticFeedbackType.selectionClick',
        'HapticFeedbackType.selectionClick',
      ]);
    });

    testWidgets('AC9 long-press repeats until release', (tester) async {
      final changes = <double>[];
      await pumpThemed(tester, Harness(initial: 10, step: 1, changes: changes));
      final gesture = await tester.startGesture(tester.getCenter(plus));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 10));
      for (var i = 0; i < 5; i++) {
        await tester.pump(RfStepper.repeatInterval);
      }
      final held = changes.length;
      expect(held, greaterThanOrEqualTo(5));
      await gesture.up();
      await tester.pump(RfStepper.repeatInterval * 5);
      expect(changes.length, held);
      expect(changes, [for (var i = 1; i <= held; i++) 10.0 + i]);
    });

    testWidgets('AC9 long-press stops at a bound', (tester) async {
      final changes = <double>[];
      await pumpThemed(
        tester,
        Harness(initial: 8, step: 1, max: 10, changes: changes),
      );
      final gesture = await tester.startGesture(tester.getCenter(plus));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 10));
      for (var i = 0; i < 10; i++) {
        await tester.pump(RfStepper.repeatInterval);
      }
      await gesture.up();
      expect(changes, [9, 10]);
    });

    testWidgets('AC9 value is adjustable and announced to screen readers', (
      tester,
    ) async {
      final changes = <double>[];
      await pumpThemed(
        tester,
        Harness(initial: 60, step: 2.5, changes: changes),
      );
      final value = find.byKey(RfStepper.valueKey);
      final data = tester.getSemantics(value).getSemanticsData();
      expect(data.label, 'Weight');
      expect(data.value, '60 kg');
      expect(data.increasedValue, '62.5 kg');
      expect(data.decreasedValue, '57.5 kg');
      expect(data.flagsCollection.isLiveRegion, isTrue);

      tester.semantics.performAction(
        find.semantics.byLabel('Weight'),
        SemanticsAction.increase,
      );
      await tester.pump();
      expect(changes, [62.5]);
    });

    testWidgets('AC9 an off-grid value snaps to the step grid', (tester) async {
      final changes = <double>[];
      await pumpThemed(
        tester,
        Harness(initial: 61, step: 2.5, changes: changes),
      );
      await tester.tap(plus);
      await tester.pump();
      await tester.tap(minus);
      await tester.tap(minus);
      await tester.pump();
      expect(changes, [62.5, 60, 57.5]);
    });

    testWidgets('AC9 a value outside min/max is clamped', (tester) async {
      await pumpThemed(tester, const Harness(initial: 600, step: 1, max: 500));
      expect(find.text('500 kg', findRichText: true), findsOneWidget);
    });

    testWidgets('WKT-01 format replaces number and unit', (tester) async {
      await pumpThemed(
        tester,
        RfStepper(
          label: 'Rest',
          value: 90,
          step: 15,
          min: 0,
          max: 600,
          format: (v) =>
              '${v ~/ 60}:${(v % 60).round().toString().padLeft(2, '0')}',
          onChanged: (_) {},
        ),
      );
      expect(find.text('1:30'), findsOneWidget);
      expect(tester.getSemantics(find.byKey(RfStepper.valueKey)).value, '1:30');
    });
  });
}
