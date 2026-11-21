import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/body.dart';
import 'package:repforge/core/metrics/energy.dart';
import 'package:repforge/core/metrics/estimate.dart';

Bmr bmrOf(Estimate<Bmr> e) => (e as Estimated<Bmr>).value;

void main() {
  group('FND-04 energy', () {
    test('AC2 Mifflin–St Jeor for male and female', () {
      expect(
        bmr(weightKg: 80, heightCm: 180, age: 30, sex: Sex.male),
        const Estimated(Bmr(1780, BmrFormula.mifflinStJeor)),
      );
      expect(
        bmrOf(bmr(weightKg: 80, heightCm: 180, age: 30, sex: Sex.female)).kcal,
        1614,
      );
    });

    test('AC4 unset sex uses the mean, marked approximate', () {
      final e = bmr(weightKg: 80, heightCm: 180, age: 30, sex: null);
      expect(
        e,
        const Estimated(Bmr(1697, BmrFormula.mifflinStJeor), approximate: true),
      );
    });

    test('AC2 a known body fat switches to Katch–McArdle', () {
      final e = bmr(
        weightKg: 80,
        heightCm: 180,
        age: 30,
        sex: Sex.male,
        bodyFat: const Estimated(16.1066),
      );
      expect(bmrOf(e).formula, BmrFormula.katchMcArdle);
      expect(bmrOf(e).kcal, closeTo(1819.7, 0.1));
      expect((e as Estimated).approximate, isFalse);
    });

    test('AC2 an approximate or unusable body fat', () {
      final approx = bmr(
        weightKg: 80,
        heightCm: 180,
        age: 30,
        sex: null,
        bodyFat: const Estimated(20.0, approximate: true),
      );
      expect((approx as Estimated).approximate, isTrue);
      final fallback = bmr(
        weightKg: 80,
        heightCm: 180,
        age: 30,
        sex: Sex.male,
        bodyFat: const NotEstimable(EstimateReason.inconsistent),
      );
      expect(bmrOf(fallback).formula, BmrFormula.mifflinStJeor);
      expect(
        bmr(
          weightKg: 80,
          heightCm: 180,
          age: 30,
          sex: Sex.male,
          bodyFat: const Estimated(80.0),
        ),
        const NotEstimable<Bmr>(EstimateReason.outOfRange, Measure.bodyFatPct),
      );
    });

    test('AC5 out-of-range weight, height and age', () {
      expect(
        bmr(weightKg: 1, heightCm: 180, age: 30, sex: Sex.male),
        const NotEstimable<Bmr>(EstimateReason.outOfRange, Measure.weightKg),
      );
      expect(
        bmr(weightKg: 80, heightCm: 300, age: 30, sex: Sex.male),
        const NotEstimable<Bmr>(EstimateReason.outOfRange, Measure.heightCm),
      );
      expect(
        bmr(weightKg: 80, heightCm: 180, age: 8, sex: Sex.male),
        const NotEstimable<Bmr>(EstimateReason.outOfRange, Measure.age),
      );
    });

    test('AC3 TDEE per activity level', () {
      const base = Estimated(Bmr(1780, BmrFormula.mifflinStJeor));
      final expected = {
        ActivityLevel.sedentary: 2136.0,
        ActivityLevel.light: 2447.5,
        ActivityLevel.moderate: 2759.0,
        ActivityLevel.active: 3070.5,
        ActivityLevel.veryActive: 3382.0,
      };
      for (final MapEntry(:key, :value) in expected.entries) {
        expect(tdee(base, key).valueOrNull, closeTo(value, 0.001));
      }
    });

    test('AC3 calorie targets and protein', () {
      final t = calorieTargets(const Estimated(2500.0)).valueOrNull!;
      expect(t.cut, 2000);
      expect(t.maintain, 2500);
      expect(t.leanBulk, closeTo(2750, 0.001));
      final p = proteinRange(weightKg: 80).valueOrNull!;
      expect(p.minGrams, closeTo(128, 0.001));
      expect(p.maxGrams, closeTo(176, 0.001));
      expect(
        proteinRange(weightKg: 0),
        const NotEstimable<ProteinRange>(
          EstimateReason.outOfRange,
          Measure.weightKg,
        ),
      );
    });

    test('AC5 BMR and TDEE sweep of range edges stays finite', () {
      for (final w in [Measure.weightKg.min, Measure.weightKg.max]) {
        for (final h in [Measure.heightCm.min, Measure.heightCm.max]) {
          for (final a in [Measure.age.min, Measure.age.max]) {
            for (final sex in [Sex.male, Sex.female, null]) {
              for (final Estimate<double>? bf in [
                null,
                Estimated(Measure.bodyFatPct.min),
                Estimated(Measure.bodyFatPct.max),
              ]) {
                final b = bmr(
                  weightKg: w,
                  heightCm: h,
                  age: a.toInt(),
                  sex: sex,
                  bodyFat: bf,
                );
                expect(bmrOf(b).kcal.isFinite, isTrue);
                for (final level in ActivityLevel.values) {
                  expect(tdee(b, level).valueOrNull!.isFinite, isTrue);
                }
              }
            }
          }
        }
      }
    });

    test('Bmr value semantics', () {
      const a = Bmr(1, BmrFormula.katchMcArdle);
      expect(a, const Bmr(1, BmrFormula.katchMcArdle));
      expect(a.hashCode, const Bmr(1, BmrFormula.katchMcArdle).hashCode);
      expect('$a', 'Bmr(1.0, katchMcArdle)');
    });
  });
}
