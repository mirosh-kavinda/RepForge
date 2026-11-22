import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/l10n/generated/app_localizations.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/features/logger/domain/summary.dart';
import 'package:repforge/features/logger/presentation/summary_format.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('LOG-05 summary formats', () {
    test('AC2 duration: m:ss under an hour, else h:mm', () {
      expect(
        durationText(l10n, const Duration(minutes: 42, seconds: 7)),
        '42:07 min',
      );
      expect(
        durationText(l10n, const Duration(hours: 1, minutes: 2)),
        '1:02 h',
      );
      expect(durationText(l10n, Duration.zero), '0:00 min');
    });

    test('edge over 24 h shows all the hours', () {
      expect(
        durationText(l10n, const Duration(hours: 26, minutes: 5)),
        '26:05 h',
      );
    });

    test('AC2 volume in whole kg, grouped; lb for imperial', () {
      expect(volumeText(l10n, 1250.4, UnitSystem.metric), '1,250 kg');
      expect(volumeText(l10n, 1000, UnitSystem.imperial), '2,205 lb');
    });

    test('AC5 signed changes with a spoken form', () {
      expect(weightChange(l10n, 1250, UnitSystem.metric), (
        text: '+1,250 kg',
        label: 'up 1,250 kg',
      ));
      expect(minutesChange(l10n, const Duration(minutes: -3)), (
        text: '−3 min',
        label: 'down 3 min',
      ));
      expect(setsChange(l10n, 0), (text: 'same', label: 'same'));
      expect(setsChange(l10n, 1).text, '+1 set');
      expect(setsChange(l10n, -2), (text: '−2 sets', label: 'down 2 sets'));
      expect(noCompare(l10n), (text: '—', label: 'not comparable'));
      expect(minutesChange(l10n, const Duration(seconds: 20)).text, 'same');
    });

    test('AC3 totals and changes by measure', () {
      expect(amountText(l10n, Measure.reps, 18, UnitSystem.metric), '18 reps');
      expect(
        amountText(l10n, Measure.time, 105, UnitSystem.metric),
        '1:45 min',
      );
      expect(
        amountChange(l10n, Measure.reps, -2, UnitSystem.metric).text,
        '−2 reps',
      );
      expect(
        amountChange(l10n, Measure.volume, 45.36, UnitSystem.imperial).text,
        '+100 lb',
      );
    });
  });
}
