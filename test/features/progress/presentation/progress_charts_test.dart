import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:repforge/app/l10n/generated/app_localizations.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/features/progress/presentation/progress_charts.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));
  final date = DateTime.utc(2026, 11, 17);

  setUpAll(() => initializeDateFormatting('en'));

  group('PRG-01 chart tooltips', () {
    test('AC7 AC6 date and value, in kg or lb', () {
      expect(
        tooltipText(
          'en',
          date,
          100,
          (v) => massText(l10n, v, UnitSystem.metric),
        ),
        'Nov 17\n100 kg',
      );
      expect(
        tooltipText(
          'en',
          date,
          100,
          (v) => massText(l10n, v, UnitSystem.imperial),
        ),
        'Nov 17\n220 lb',
      );
    });
  });

  group('PRG-02 chart tooltips', () {
    test('AC5 AC8 a week with nothing planned says so', () {
      expect(
        tooltipText(
          'en',
          date,
          0,
          (v) => '$v %',
          noData: 'No training planned',
        ),
        'Nov 17\nNo training planned',
      );
    });
  });
}
