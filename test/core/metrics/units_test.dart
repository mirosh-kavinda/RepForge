import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/units.dart';

void main() {
  group('FND-04 units', () {
    test('AC11 reference conversions', () {
      expect(kgToLb(100), closeTo(220.462, 0.001));
      expect(lbToKg(225), closeTo(102.058, 0.001));
      expect(cmToIn(180), closeTo(70.866, 0.001));
      expect(inToCm(12), closeTo(30.48, 1e-9));
      final fi = cmToFeetInches(180);
      expect(fi.feet, 5);
      expect(fi.inches, closeTo(10.866, 0.001));
      expect(feetInchesToCm(5, 10), closeTo(177.8, 1e-9));
    });

    test('edge: an exact foot boundary never shows 12 inches', () {
      final six = cmToFeetInches(182.88);
      expect(six.feet, 6);
      expect(six.inches, closeTo(0, 1e-9));
    });

    test('ONB-01 AC4 imperial only for US, Liberia and Myanmar', () {
      for (final c in ['US', 'us', 'LR', 'MM']) {
        expect(defaultUnitSystem(c), UnitSystem.imperial, reason: c);
      }
      for (final c in ['GB', 'LK', 'CA', 'IN', null]) {
        expect(defaultUnitSystem(c), UnitSystem.metric, reason: '$c');
      }
      expect(UnitSystem.metric.mass, MassUnit.kg);
      expect(UnitSystem.imperial.mass, MassUnit.lb);
    });

    test('AC11 round trips stay within 0.01', () {
      for (var v = 25.0; v <= 350; v += 0.37) {
        expect(lbToKg(kgToLb(v)), closeTo(v, 0.01));
      }
      for (var v = 100.0; v <= 250; v += 0.29) {
        expect(inToCm(cmToIn(v)), closeTo(v, 0.01));
        final fi = cmToFeetInches(v);
        expect(feetInchesToCm(fi.feet, fi.inches), closeTo(v, 0.01));
      }
    });
  });
}
