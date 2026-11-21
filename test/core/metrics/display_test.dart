import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/display.dart';
import 'package:repforge/core/metrics/units.dart';

void main() {
  group('FND-04 display rounding', () {
    test('AC10 BMI, BF %, FFMI to 1 decimal', () {
      expect(displayOneDecimal(24.691), 24.7);
      expect(displayOneDecimal(16.1066), 16.1);
      expect(displayOneDecimal(20.25), 20.3);
    });

    test('AC10 LBM and e1RM to 0.5 kg or 1 lb', () {
      expect(displayMass(116.667, MassUnit.kg), 116.5);
      expect(displayMass(116.75, MassUnit.kg), 117.0);
      expect(displayMass(67.1147, MassUnit.kg), 67.0);
      expect(displayMass(100, MassUnit.lb), 220);
    });

    test('AC10 kcal to the nearest 10, protein and volume whole', () {
      expect(displayKcal(1819.68), 1820);
      expect(displayKcal(2447.5), 2450);
      expect(displayKcal(1614), 1610);
      expect(displayProteinGrams(127.6), 128);
      expect(displayVolume(2600.4, MassUnit.kg), 2600);
      expect(displayVolume(1000, MassUnit.lb), 2205);
    });
  });
}
