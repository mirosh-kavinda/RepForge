import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/l10n/app_locale.dart';
import 'package:repforge/app/l10n/generated/app_localizations.dart';
import 'package:repforge/features/schedule/presentation/weekday_labels.dart';

Future<WeekdayLabels> labelsFor(WidgetTester tester, Locale device) async {
  late WeekdayLabels labels;
  tester.platformDispatcher.localesTestValue = [device];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: appLocales,
      localeListResolutionCallback: resolveAppLocale,
      home: Builder(
        builder: (context) {
          labels = WeekdayLabels.of(context);
          return const SizedBox();
        },
      ),
    ),
  );
  return labels;
}

void main() {
  group('SCH-03 weekday labels', () {
    testWidgets('NFR-11 en_GB starts the week on Monday', (tester) async {
      final l = await labelsFor(tester, const Locale('en', 'GB'));
      expect(l.firstDay, 1);
      expect(
        [for (var i = 0; i < 7; i++) l.full(i)],
        [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ],
      );
      expect(l.short(6), 'Sun');
    });

    testWidgets('edge locale en_US starts the week on Sunday', (tester) async {
      final l = await labelsFor(tester, const Locale('en', 'US'));
      expect(l.firstDay, 0);
      expect(l.full(0), 'Monday', reason: 'stored rows stay Monday first');
    });

    test('NFR-11 the phone region is kept for supported languages', () {
      expect(
        resolveAppLocale(const [Locale('fr'), Locale('en', 'GB')], appLocales),
        const Locale('en', 'GB'),
      );
      expect(
        resolveAppLocale(const [Locale('fr')], appLocales),
        appLocales.first,
      );
      expect(resolveAppLocale(null, appLocales), appLocales.first);
    });
  });
}
