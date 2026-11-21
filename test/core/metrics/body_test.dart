import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/body.dart';
import 'package:repforge/core/metrics/estimate.dart';

double value(Estimate<double> e) => (e as Estimated<double>).value;

void main() {
  group('FND-04 body metrics', () {
    test('AC1 BMI = kg / m²', () {
      expect(value(bmi(weightKg: 80, heightCm: 180)), closeTo(24.69, 0.01));
      expect(value(bmi(weightKg: 60, heightCm: 165)), closeTo(22.04, 0.01));
    });

    test('AC1 Navy body fat, male and female reference values', () {
      expect(
        value(
          bodyFatNavy(sex: Sex.male, heightCm: 180, waistCm: 85, neckCm: 38),
        ),
        closeTo(16.1, 0.1),
      );
      expect(
        value(
          bodyFatNavy(
            sex: Sex.female,
            heightCm: 165,
            waistCm: 75,
            neckCm: 33,
            hipCm: 98,
          ),
        ),
        closeTo(28.4, 0.1),
      );
    });

    test('AC1 a hip given for a male is ignored', () {
      final without = bodyFatNavy(
        sex: Sex.male,
        heightCm: 180,
        waistCm: 85,
        neckCm: 38,
      );
      final withHip = bodyFatNavy(
        sex: Sex.male,
        heightCm: 180,
        waistCm: 85,
        neckCm: 38,
        hipCm: 100,
      );
      expect(withHip, without);
    });

    test('AC4 unset sex returns the mean, marked approximate', () {
      final e = bodyFatNavy(
        sex: null,
        heightCm: 180,
        waistCm: 85,
        neckCm: 38,
        hipCm: 100,
      );
      expect(e, isA<Estimated<double>>());
      expect(value(e), closeTo(22.06, 0.05));
      expect((e as Estimated).approximate, isTrue);
    });

    test('edge: missing hip for female or unset sex cannot estimate', () {
      for (final sex in [Sex.female, null]) {
        expect(
          bodyFatNavy(sex: sex, heightCm: 170, waistCm: 80, neckCm: 34),
          const NotEstimable<double>(EstimateReason.missing, Measure.hipCm),
        );
      }
    });

    test('AC5 waist ≤ neck is inconsistent, not NaN', () {
      expect(
        bodyFatNavy(sex: Sex.male, heightCm: 180, waistCm: 40, neckCm: 40),
        const NotEstimable<double>(EstimateReason.inconsistent),
      );
      expect(
        bodyFatNavy(sex: Sex.male, heightCm: 180, waistCm: 41, neckCm: 40),
        const NotEstimable<double>(EstimateReason.inconsistent),
        reason: 'a result outside 3–60 % is not plausible',
      );
    });

    test('AC5 out-of-range inputs name the field', () {
      expect(
        bmi(weightKg: 900, heightCm: 180),
        const NotEstimable<double>(EstimateReason.outOfRange, Measure.weightKg),
      );
      expect(
        bmi(weightKg: 80, heightCm: 20),
        const NotEstimable<double>(EstimateReason.outOfRange, Measure.heightCm),
      );
      expect(
        bodyFatNavy(sex: Sex.male, heightCm: 180, waistCm: 300, neckCm: 38),
        const NotEstimable<double>(EstimateReason.outOfRange, Measure.waistCm),
      );
    });

    test('AC5 sweep of range edges never yields NaN or infinity', () {
      for (final h in [Measure.heightCm.min, Measure.heightCm.max]) {
        for (final w in [Measure.waistCm.min, Measure.waistCm.max]) {
          for (final n in [Measure.neckCm.min, Measure.neckCm.max]) {
            for (final hip in [Measure.hipCm.min, Measure.hipCm.max]) {
              for (final sex in [Sex.male, Sex.female, null]) {
                final e = bodyFatNavy(
                  sex: sex,
                  heightCm: h,
                  waistCm: w,
                  neckCm: n,
                  hipCm: hip,
                );
                if (e case Estimated(:final value)) {
                  expect(value.isFinite, isTrue);
                }
              }
            }
          }
        }
      }
    });

    test('AC1 LBM and FFMI follow body fat and carry approximation', () {
      const fat = Estimated(16.1066);
      expect(value(leanMass(weightKg: 80, bodyFat: fat)), closeTo(67.11, 0.01));
      expect(
        value(ffmi(weightKg: 80, heightCm: 180, bodyFat: fat)),
        closeTo(20.71, 0.01),
      );
      final approx = leanMass(
        weightKg: 80,
        bodyFat: const Estimated(20.0, approximate: true),
      );
      expect((approx as Estimated).approximate, isTrue);
      expect(
        leanMass(
          weightKg: 80,
          bodyFat: const NotEstimable(EstimateReason.inconsistent),
        ),
        const NotEstimable<double>(EstimateReason.inconsistent),
      );
      expect(
        leanMass(weightKg: 5, bodyFat: fat),
        const NotEstimable<double>(EstimateReason.outOfRange, Measure.weightKg),
      );
      expect(
        ffmi(weightKg: 80, heightCm: 20, bodyFat: fat),
        const NotEstimable<double>(EstimateReason.outOfRange, Measure.heightCm),
      );
    });

    test('AC5 LBM and FFMI reject an implausible body fat', () {
      expect(
        leanMass(weightKg: 80, bodyFat: const Estimated(120.0)),
        const NotEstimable<double>(
          EstimateReason.outOfRange,
          Measure.bodyFatPct,
        ),
      );
      expect(
        ffmi(weightKg: 80, heightCm: 180, bodyFat: const Estimated(1.0)),
        const NotEstimable<double>(
          EstimateReason.outOfRange,
          Measure.bodyFatPct,
        ),
      );
    });

    test('AC5 LBM and FFMI sweep stays finite', () {
      for (final w in [Measure.weightKg.min, Measure.weightKg.max]) {
        for (final h in [Measure.heightCm.min, Measure.heightCm.max]) {
          for (final bf in [Measure.bodyFatPct.min, Measure.bodyFatPct.max]) {
            final fat = Estimated(bf);
            expect(value(leanMass(weightKg: w, bodyFat: fat)).isFinite, isTrue);
            expect(
              value(ffmi(weightKg: w, heightCm: h, bodyFat: fat)).isFinite,
              isTrue,
            );
          }
        }
      }
    });

    test('edge: age is current year minus birth year', () {
      expect(ageFromBirthYear(1990, DateTime(2026, 1, 1)), 36);
      expect(ageFromBirthYear(1990, DateTime(2026, 12, 31)), 36);
    });
  });
}
