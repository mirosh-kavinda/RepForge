import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/features/logger/domain/workout_session.dart';
import 'package:repforge/features/logger/presentation/plates_sheet.dart';
import 'package:repforge/features/logger/presentation/set_row.dart';
import 'package:repforge/features/settings/data/providers.dart';
import 'package:repforge/features/settings/domain/settings.dart';

import '../../../helpers/pump_themed.dart';
import '../../settings/fake_settings_repository.dart';

Future<void> sheet(
  WidgetTester tester,
  double kg, {
  UnitSystem units = UnitSystem.metric,
  TrainingSettings settings = const TrainingSettings(),
  double textScale = 1,
}) => pumpThemed(
  tester,
  ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(
        FakeSettingsRepository(settings: settings),
      ),
    ],
    child: PlatesSheet(kg: kg, units: units),
  ),
  textScale: textScale,
);

const row = SessionExercise(id: 'r', exerciseId: 'Bench_Press', name: 'Bench');

void main() {
  group('SET-01 plates sheet', () {
    testWidgets('AC6 each side, heaviest first', (tester) async {
      await sheet(tester, 85);
      expect(find.text('Plates for 85 kg'), findsOneWidget);
      expect(find.text('Each side: 25, 5, 2.5 kg'), findsOneWidget);
    });

    testWidgets('AC6 in pounds with the pound plates', (tester) async {
      await sheet(tester, lbToKg(225), units: UnitSystem.imperial);
      expect(find.text('Each side: 45, 45 lb'), findsOneWidget);
    });

    testWidgets('AC7 closest lighter load and what is missing', (tester) async {
      await sheet(
        tester,
        63,
        settings: const TrainingSettings(platesKgMetric: [20, 10, 5]),
      );
      expect(find.text('Each side: 20 kg'), findsOneWidget);
      expect(find.text('3 kg short'), findsOneWidget);
    });

    testWidgets('AC7 lighter than the bar; just the bar', (tester) async {
      await sheet(tester, 15);
      expect(find.text('Lighter than the bar'), findsOneWidget);
      await sheet(tester, 20);
      expect(find.text('Just the bar'), findsOneWidget);
    });

    testWidgets('AC6 the Plates button opens it; not for bodyweight', (
      tester,
    ) async {
      Widget steppers(SessionExercise r, double kg) => SetSteppers(
        row: r,
        values: (kg: kg, reps: 5, seconds: null),
        units: UnitSystem.metric,
        onChanged: (_) {},
      );
      final overrides = [
        settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
      ];
      await pumpThemed(tester, steppers(row, 60), overrides: overrides);
      await tester.tap(find.byKey(SetSteppers.platesKey));
      await tester.pumpAndSettle();
      expect(find.text('Each side: 20 kg'), findsOneWidget);

      await pumpThemed(
        tester,
        steppers(row.copyWith(bodyweight: true), 0),
        overrides: overrides,
      );
      expect(find.byKey(SetSteppers.platesKey), findsNothing);
    });

    testWidgets('NFR-06 fits at 200 % text', (tester) async {
      await sheet(tester, 85, textScale: 2);
      expect(tester.takeException(), isNull);
    });
  });
}
