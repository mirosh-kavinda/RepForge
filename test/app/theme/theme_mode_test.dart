import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/app/theme/rf_theme.dart';
import 'package:repforge/app/theme/rf_tokens.dart';
import 'package:repforge/app/theme/theme_mode.dart';

import '../../helpers/app_overrides.dart';
import '../../helpers/static_today.dart';

RfColors colorsIn(WidgetTester tester) =>
    RfColors.of(tester.element(find.byType(Scaffold).first));

void main() {
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher
        .clearPlatformBrightnessTestValue();
  });

  group('FND-02 theme mode', () {
    test('AC4 default System', () {
      final container = ProviderContainer(
        overrides: [...signedInOverrides(), staticToday],
      );
      addTearDown(container.dispose);
      expect(container.read(appThemeModeProvider), ThemeMode.system);
    });

    testWidgets('AC4 follows OS without restart', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      await tester.pumpWidget(
        ProviderScope(
          overrides: signedInOverrides(),
          child: const RepForgeApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(colorsIn(tester).bg, RfColors.light.bg);

      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpAndSettle();
      expect(colorsIn(tester).bg, RfColors.dark.bg);
    });

    testWidgets('AC4 set light/dark applies immediately', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      final container = ProviderContainer(
        overrides: [...signedInOverrides(), staticToday],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const RepForgeApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(appThemeModeProvider.notifier).set(ThemeMode.light);
      await tester.pumpAndSettle();
      expect(colorsIn(tester).bg, RfColors.light.bg);

      container.read(appThemeModeProvider.notifier).set(ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(colorsIn(tester).bg, RfColors.dark.bg);
    });

    testWidgets('AC4 state kept on switch', (tester) async {
      final container = ProviderContainer(
        overrides: [...signedInOverrides(), staticToday],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) => MaterialApp(
              theme: rfTheme(Brightness.light),
              darkTheme: rfTheme(Brightness.dark),
              themeMode: ref.watch(appThemeModeProvider),
              home: const Scaffold(body: TextField()),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), '62.5');
      container.read(appThemeModeProvider.notifier).set(ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('62.5'), findsOneWidget);
      expect(colorsIn(tester).bg, RfColors.dark.bg);
    });

    test('theme carries tokens, text styles and brand colour scheme', () {
      for (final (b, c) in [
        (Brightness.dark, RfColors.dark),
        (Brightness.light, RfColors.light),
      ]) {
        final theme = rfTheme(b);
        expect(theme.brightness, b);
        expect(theme.extension<RfColors>(), same(c));
        expect(theme.colorScheme.primary, c.actionFill);
        expect(theme.colorScheme.onPrimary, c.onSolid);
        expect(theme.colorScheme.surface, c.surface);
        expect(theme.colorScheme.onSurface, c.textPrimary);
        expect(theme.scaffoldBackgroundColor, c.bg);
        expect(theme.materialTapTargetSize, MaterialTapTargetSize.padded);
        expect(theme.textTheme.bodyMedium?.fontFamily, 'Inter');
      }
    });
  });
}
