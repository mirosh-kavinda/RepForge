import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/estimate.dart';

void main() {
  group('FND-04 estimate', () {
    test('AC5 range check: missing, out of range, edges inclusive', () {
      expect(
        checkRange<double>(Measure.weightKg, null),
        const NotEstimable<double>(EstimateReason.missing, Measure.weightKg),
      );
      expect(
        checkRange<double>(Measure.weightKg, 900),
        const NotEstimable<double>(EstimateReason.outOfRange, Measure.weightKg),
      );
      expect(checkRange<double>(Measure.weightKg, 25), isNull);
      expect(checkRange<double>(Measure.weightKg, 350), isNull);
      expect(checkRange<double>(Measure.weightKg, 24.99), isNotNull);
    });

    test('AC5 NaN and infinity are never accepted', () {
      for (final m in Measure.values) {
        expect(m.accepts(double.nan), isFalse, reason: m.name);
        expect(m.accepts(double.infinity), isFalse, reason: m.name);
      }
    });

    test('map keeps approximation and passes failures through', () {
      expect(
        const Estimated(2.0, approximate: true).map((v) => v * 2),
        const Estimated(4.0, approximate: true),
      );
      expect(
        const NotEstimable<double>(
          EstimateReason.inconsistent,
        ).map((v) => '$v'),
        const NotEstimable<String>(EstimateReason.inconsistent),
      );
      expect(const Estimated(3).valueOrNull, 3);
      expect(
        const NotEstimable<int>(EstimateReason.missing).valueOrNull,
        isNull,
      );
    });

    test('equality, hash and description', () {
      expect(const Estimated(1).hashCode, const Estimated(1).hashCode);
      expect(const Estimated(1), isNot(const Estimated(1, approximate: true)));
      expect(
        const NotEstimable<int>(EstimateReason.missing).hashCode,
        const NotEstimable<int>(EstimateReason.missing).hashCode,
      );
      expect('${const Estimated(1, approximate: true)}', contains('approx'));
      expect('${const Estimated(1)}', 'Estimated(1)');
      expect(
        '${const NotEstimable<int>(EstimateReason.outOfRange, Measure.age)}',
        'NotEstimable(outOfRange, age)',
      );
    });
  });
}
