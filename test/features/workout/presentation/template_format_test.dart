import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/l10n/generated/app_localizations.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/features/workout/domain/template_rules.dart';
import 'package:repforge/features/workout/domain/workout_template.dart';
import 'package:repforge/features/workout/presentation/template_format.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  TemplateExercise e({
    int sets = 3,
    int min = 8,
    int max = 12,
    double? kg,
    int rest = 120,
    TargetKind kind = TargetKind.reps,
    int seconds = 45,
    String? superset,
  }) => TemplateExercise(
    id: '$sets$min$max$kg$superset',
    exerciseId: 'x',
    sets: sets,
    repMin: min,
    repMax: max,
    targetKg: kg,
    restSec: rest,
    kind: kind,
    seconds: seconds,
    superset: superset,
  );

  group('WKT-01 row format', () {
    test('AC4 reps range, weight and rest', () {
      expect(
        rowLine(
          l10n,
          [e(sets: 4, min: 5, max: 8, kg: 102.5, rest: 180)],
          0,
          MassUnit.kg,
        ),
        '4 × 5–8 · 102.5 kg · rest 3:00',
      );
    });

    test('AC4 timed and fixed reps, no weight', () {
      expect(
        rowLine(l10n, [e(kind: TargetKind.time, rest: 90)], 0, MassUnit.kg),
        '3 × 45 s · rest 1:30',
      );
      expect(
        rowLine(l10n, [e(min: 12, max: 12, rest: 60)], 0, MassUnit.kg),
        '3 × 12 · rest 1:00',
      );
    });

    test('edge weight shows in lb rounded to whole lb', () {
      expect(weightText(l10n, 102.06, MassUnit.lb), '225 lb');
      expect(weightText(l10n, 61.3, MassUnit.kg), '61.5 kg');
    });

    test('edge a max-first range shows low to high', () {
      expect(targetText(l10n, e(min: 12, max: 8)), '8–12');
    });

    test('AC7 inner superset members show no rest', () {
      final list = link([e(superset: null), e(min: 10)], {0, 1});
      expect(
        rowLine(l10n, list, 0, MassUnit.kg),
        endsWith('no rest (superset)'),
      );
      expect(rowLine(l10n, list, 1, MassUnit.kg), endsWith('rest 2:00'));
    });

    test('rest is m:ss', () {
      expect(restText(0), '0:00');
      expect(restText(75), '1:15');
      expect(restText(600), '10:00');
    });
  });
}
