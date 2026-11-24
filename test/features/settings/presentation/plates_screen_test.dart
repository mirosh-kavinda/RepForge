import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/features/settings/domain/settings.dart';
import 'package:repforge/features/settings/presentation/plates_screen.dart';
import 'package:repforge/features/settings/presentation/profile_screen.dart';

import '../fake_settings_repository.dart';
import '../settings_app.dart';

Future<void> openPlates(
  WidgetTester tester, {
  FakeSettingsRepository? repo,
}) async {
  await pumpProfile(tester, repo: repo);
  await scrollTo(tester, find.byKey(ProfileScreen.platesKey));
  await tester.tap(find.byKey(ProfileScreen.platesKey));
  await tester.pumpAndSettle();
}

void main() {
  group('SET-01 plates screen', () {
    testWidgets('AC5 the defaults, all on', (tester) async {
      await openPlates(tester);
      expect(find.text('25 kg plate'), findsOneWidget);
      expect(find.text('1.25 kg plate'), findsOneWidget);
      final on = tester
          .widgetList<SwitchListTile>(find.byType(SwitchListTile))
          .where((s) => s.value);
      expect(on, hasLength(7));
    });

    testWidgets('AC5 turning a plate off and the bar up is saved in kg', (
      tester,
    ) async {
      await openPlates(tester);
      await tester.tap(find.byKey(PlatesScreen.plateKey(1.25)));
      await tester.pumpAndSettle();
      expect(settings.settings.platesKgMetric, [25, 20, 15, 10, 5, 2.5]);
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();
      expect(settings.settings.barKgMetric, 22.5);
    });

    testWidgets('AC5 at least one plate stays on', (tester) async {
      await openPlates(
        tester,
        repo: FakeSettingsRepository(
          settings: const TrainingSettings(platesKgMetric: [25]),
        ),
      );
      await tester.tap(find.byKey(PlatesScreen.plateKey(25)));
      await tester.pumpAndSettle();
      expect(find.text('Keep at least one plate'), findsOneWidget);
      expect(settings.settings.platesKgMetric, [25]);
    });

    testWidgets('edge imperial shows its own list in pounds', (tester) async {
      await openPlates(
        tester,
        repo: FakeSettingsRepository(
          settings: const TrainingSettings(units: UnitSystem.imperial),
        ),
      );
      expect(find.text('45 lb plate'), findsOneWidget);
      expect(find.text('1.25 kg plate'), findsNothing);
    });

    testWidgets('NFR-06 fits at 200 % text', (tester) async {
      await pumpProfile(tester, textScale: 2);
      await scrollTo(tester, find.byKey(ProfileScreen.platesKey));
      await tester.tap(find.byKey(ProfileScreen.platesKey));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
