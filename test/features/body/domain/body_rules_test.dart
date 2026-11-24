import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/body.dart';
import 'package:repforge/core/metrics/energy.dart';
import 'package:repforge/core/metrics/estimate.dart';
import 'package:repforge/features/body/domain/body_rules.dart';
import 'package:repforge/features/body/domain/body_snapshot.dart';

const man = BodyProfile(sex: Sex.male, birthYear: 1996, heightCm: 180);
final today = DateTime.utc(2026, 11, 24);

double? v(BodyResults r, BodyMetric m) => r[m]!.valueOrNull;

void main() {
  group('BOD-01 computeBodyResults', () {
    test('AC3 weight only: BMI, BMR, TDEE, targets, protein; no body fat', () {
      final r = computeBodyResults(
        const BodyInput(weightKg: 81, activity: ActivityLevel.moderate),
        man,
        today,
      );
      expect(v(r, BodyMetric.bmi), closeTo(25.0, 0.01));
      // Mifflin: 10·81 + 6.25·180 − 5·30 + 5 = 1790.
      expect(v(r, BodyMetric.bmr), closeTo(1790, 0.01));
      expect(v(r, BodyMetric.tdee), closeTo(1790 * 1.55, 0.01));
      expect(v(r, BodyMetric.cut), closeTo(1790 * 1.55 * 0.8, 0.01));
      expect(v(r, BodyMetric.gain), closeTo(1790 * 1.55 * 1.1, 0.01));
      expect(v(r, BodyMetric.proteinMin), closeTo(81 * 1.6, 0.01));
      expect(
        r[BodyMetric.bodyFat],
        const NotEstimable<double>(EstimateReason.missing, Measure.waistCm),
      );
      expect(r[BodyMetric.leanMass], isA<NotEstimable<double>>());
      expect(r.keys, BodyMetric.values.toSet());
    });

    test('AC4 tape gives body fat; LBM, FFMI and Katch BMR follow', () {
      final r = computeBodyResults(
        const BodyInput(
          weightKg: 81,
          activity: ActivityLevel.moderate,
          waistCm: 85,
          neckCm: 38,
        ),
        man,
        today,
      );
      final fat = v(r, BodyMetric.bodyFat)!;
      expect(fat, inInclusiveRange(10, 25));
      final lbm = 81 * (1 - fat / 100);
      expect(v(r, BodyMetric.leanMass), closeTo(lbm, 0.001));
      expect(v(r, BodyMetric.ffmi), closeTo(lbm / (1.8 * 1.8), 0.001));
      expect(v(r, BodyMetric.bmr), closeTo(370 + 21.6 * lbm, 0.001));
    });

    test('AC4 a scale value wins over the tape', () {
      final r = computeBodyResults(
        const BodyInput(
          weightKg: 81,
          activity: ActivityLevel.moderate,
          waistCm: 85,
          neckCm: 38,
          scaleBodyFatPct: 18,
        ),
        man,
        today,
      );
      expect(r[BodyMetric.bodyFat], const Estimated<double>(18));
    });

    test('AC4 women need hip too', () {
      final r = computeBodyResults(
        const BodyInput(
          weightKg: 62,
          activity: ActivityLevel.light,
          waistCm: 72,
          neckCm: 32,
        ),
        const BodyProfile(sex: Sex.female, birthYear: 1994, heightCm: 165),
        today,
      );
      expect(
        r[BodyMetric.bodyFat],
        const NotEstimable<double>(EstimateReason.missing, Measure.hipCm),
      );
    });

    test('AC5 missing height or birth year say so', () {
      final noHeight = computeBodyResults(
        const BodyInput(weightKg: 81, activity: ActivityLevel.moderate),
        const BodyProfile(sex: Sex.male, birthYear: 1996),
        today,
      );
      expect(
        noHeight[BodyMetric.bmi],
        const NotEstimable<double>(EstimateReason.missing, Measure.heightCm),
      );
      expect(
        noHeight[BodyMetric.bmr],
        const NotEstimable<double>(EstimateReason.missing, Measure.heightCm),
      );
      final noAge = computeBodyResults(
        const BodyInput(weightKg: 81, activity: ActivityLevel.moderate),
        const BodyProfile(sex: Sex.male, heightCm: 180),
        today,
      );
      expect(
        noAge[BodyMetric.tdee],
        const NotEstimable<double>(EstimateReason.missing, Measure.age),
      );
      expect(v(noAge, BodyMetric.bmi), isNotNull);
    });

    test('edge impossible tape (neck ≥ waist): body fat not estimable', () {
      final r = computeBodyResults(
        const BodyInput(
          weightKg: 81,
          activity: ActivityLevel.moderate,
          waistCm: 40,
          neckCm: 45,
        ),
        man,
        today,
      );
      expect(r[BodyMetric.bodyFat], isA<NotEstimable<double>>());
      expect(v(r, BodyMetric.bmr), isNotNull, reason: 'falls back to Mifflin');
    });

    test('edge weight range', () {
      expect(weightAccepted(82.5), isTrue);
      expect(weightAccepted(5), isFalse);
      expect(weightAccepted(500), isFalse);
    });
  });
}
