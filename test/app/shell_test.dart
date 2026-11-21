import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/app/l10n/generated/app_localizations.dart';

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: RepForgeApp()));
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
      expect(app.supportedLocales, contains(const Locale('en')));
    });

    test('AC5: Sinhala and Tamil ARB files exist and are empty', () async {
      for (final code in ['si', 'ta']) {
        final file = File('lib/app/l10n/app_$code.arb');
        expect(file.existsSync(), isTrue, reason: 'app_$code.arb missing');
        final json = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
        expect(json.keys.where((k) => !k.startsWith('@@')), isEmpty);
      }
    });
  });
}
