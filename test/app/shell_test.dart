import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/app/l10n/generated/app_localizations.dart';
import 'package:repforge/features/home/presentation/home_screen.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/library/presentation/library_screen.dart';
import 'package:repforge/features/progress/presentation/progress_screen.dart';
import 'package:repforge/features/schedule/presentation/schedule_screen.dart';
import 'package:repforge/features/settings/presentation/profile_screen.dart';

import '../features/workout/fakes.dart';
import '../helpers/app_overrides.dart';

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...signedInOverrides(),
        // EXL-01: the Library tab searches the catalog.
        exerciseCatalogProvider.overrideWith((ref) async => FakeCatalog()),
      ],
      child: const RepForgeApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('FND-01', () {
    testWidgets('AC1 AC5: app starts and title comes from ARB (English)', (
      tester,
    ) async {
      await pumpApp(tester);

      final context = tester.element(find.byType(Scaffold).first);
      final l10n = AppLocalizations.of(context);
      expect(l10n.localeName, 'en');
      expect(l10n.appTitle, 'RepForge');
      expect(find.text(l10n.appTitle), findsOneWidget);

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.supportedLocales, [const Locale('en')]);
    });

    test('AC5: Sinhala and Tamil ARB files exist and are empty', () async {
      for (final code in ['si', 'ta']) {
        final file = File('lib/app/l10n/app_$code.arb');
        expect(file.existsSync(), isTrue, reason: 'app_$code.arb missing');
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
        expect(json.keys.where((k) => !k.startsWith('@@')), isEmpty);
      }
    });

    testWidgets('AC1 AC6: shell opens on Home with five labelled tabs', (
      tester,
    ) async {
      await pumpApp(tester);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(5));
      expect(find.byType(HomeScreen), findsOneWidget);
      for (final label in [
        'Home',
        'Schedule',
        'Library',
        'Progress',
        'Profile',
      ]) {
        expect(find.bySemanticsLabel(RegExp(label)), findsWidgets);
      }
    });

    testWidgets('AC6: each tab shows its screen and keeps its state', (
      tester,
    ) async {
      await pumpApp(tester);

      final tabs = <String, Type>{
        'Schedule': ScheduleScreen,
        'Library': LibraryScreen,
        'Progress': ProgressScreen,
        'Profile': ProfileScreen,
        'Home': HomeScreen,
      };
      final elements = <Type, Element>{};

      for (final MapEntry(key: label, value: screen) in tabs.entries) {
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(label),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(screen), findsOneWidget, reason: '$label tab');
        elements[screen] = tester.element(find.byType(screen));
      }

      // Visit every tab again: the same elements (and their state) are reused.
      for (final MapEntry(key: label, value: screen) in tabs.entries) {
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(label),
          ),
        );
        await tester.pumpAndSettle();
        final element = tester.element(find.byType(screen));
        expect(identical(element, elements[screen]), isTrue, reason: label);
        expect(element.mounted, isTrue);
      }
    });
  });
}
