import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/features/settings/domain/settings.dart';
import 'package:repforge/features/settings/presentation/plates_screen.dart';
import 'package:repforge/features/settings/presentation/profile_screen.dart';
import 'package:repforge/features/settings/presentation/reminder_screen.dart';

import '../fake_settings_repository.dart';
import '../settings_app.dart';

void main() {
  group('SET-01 profile settings', () {
    testWidgets('AC1 each setting with its value in words', (tester) async {
      await pumpProfile(tester);
      await scrollTo(tester, find.byKey(ProfileScreen.reminderKey));
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Metric (kg, cm)'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('2:00'), findsOneWidget);
      expect(find.text('20 kg bar · 7 plates'), findsOneWidget);
      expect(find.text('Off'), findsOneWidget);
    });

    testWidgets('AC2 units switch at once; plates follow the unit', (
      tester,
    ) async {
      await pumpProfile(tester);
      await scrollTo(tester, find.text('Imperial (lb, in)'));
      await tester.tap(find.text('Imperial (lb, in)'));
      await tester.pumpAndSettle();
      expect(settings.settings.units, UnitSystem.imperial);
      await scrollTo(tester, find.byKey(ProfileScreen.platesKey));
      expect(find.text('45 lb bar · 6 plates'), findsOneWidget);
    });

    testWidgets('AC3 theme switches at once and is saved', (tester) async {
      await pumpProfile(tester);
      await scrollTo(tester, find.text('Dark'));
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(settings.theme, ThemePref.dark);
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark,
      );
    });

    testWidgets('AC4 default rest in 15 s steps', (tester) async {
      await pumpProfile(tester);
      await scrollTo(tester, find.byKey(ProfileScreen.restKey));
      await tester.tap(find.byKey(ProfileScreen.restKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add).last);
      await tester.pumpAndSettle();
      expect(find.text('2:15'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(settings.settings.restSec, 135);
      expect(find.text('2:15'), findsOneWidget);
    });

    testWidgets('AC5 AC8 rows open the plates and reminder screens', (
      tester,
    ) async {
      await pumpProfile(tester);
      await scrollTo(tester, find.byKey(ProfileScreen.platesKey));
      await tester.tap(find.byKey(ProfileScreen.platesKey));
      await tester.pumpAndSettle();
      expect(find.byType(PlatesScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await scrollTo(tester, find.byKey(ProfileScreen.reminderKey));
      await tester.tap(find.byKey(ProfileScreen.reminderKey));
      await tester.pumpAndSettle();
      expect(find.byType(ReminderScreen), findsOneWidget);
    });

    testWidgets('a failed save says so', (tester) async {
      await pumpProfile(
        tester,
        repo: FakeSettingsRepository()..failWith = StateError('db'),
      );
      await scrollTo(tester, find.text('Imperial (lb, in)'));
      await tester.tap(find.text('Imperial (lb, in)'));
      await tester.pumpAndSettle();
      expect(
        find.text("Couldn't save that change. Try again."),
        findsOneWidget,
      );
    });

    testWidgets('NFR-06 fits at 200 % text; rows are 48 dp', (tester) async {
      await pumpProfile(tester, textScale: 2);
      expect(tester.takeException(), isNull);
      await scrollTo(tester, find.byKey(ProfileScreen.reminderKey));
      expect(
        tester.getSize(find.byKey(ProfileScreen.reminderKey)).height,
        greaterThanOrEqualTo(48),
      );
    });
  });
}
