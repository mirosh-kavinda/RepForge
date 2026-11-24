import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/features/settings/domain/plates.dart';

const kg = [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25];
const lb = [45.0, 35.0, 25.0, 10.0, 5.0, 2.5];

void main() {
  group('SET-01 plate solver', () {
    test('AC6 exact load per side, heaviest first', () {
      final r = loadPlates(weight: 85, bar: 20, plates: kg) as Loaded;
      expect(r.perSide, [25, 5, 2.5]);
      expect(r.shortBy, 0);
    });

    test('AC6 pounds stay exact', () {
      final r = loadPlates(weight: 225, bar: 45, plates: lb) as Loaded;
      expect(r.perSide, [45, 45]);
      expect(r.shortBy, 0);
    });

    test('AC6 only plates I own; fewest plates on ties', () {
      final r =
          loadPlates(weight: 60, bar: 20, plates: const [10, 5, 2.5]) as Loaded;
      expect(r.perSide, [10, 10]);
    });

    test('AC7 closest lighter load and the shortfall', () {
      final r = loadPlates(weight: 63, bar: 20, plates: kg) as Loaded;
      expect(r.perSide, [20, 1.25]);
      expect(r.shortBy, closeTo(0.5, 1e-9));
      final coarse =
          loadPlates(weight: 70, bar: 20, plates: const [20]) as Loaded;
      expect(coarse.perSide, [20]);
      expect(coarse.shortBy, 10);
    });

    test('AC6 just the bar', () {
      final r = loadPlates(weight: 20, bar: 20, plates: kg) as Loaded;
      expect(r.perSide, isEmpty);
      expect(r.shortBy, 0);
    });

    test('AC7 lighter than the bar', () {
      expect(loadPlates(weight: 15, bar: 20, plates: kg), isA<BelowBar>());
    });

    test('a non-greedy set still finds the best load', () {
      // Greedy would take 15 + 1 + 1 + 1 for 18; 9 + 9 is fewer plates.
      final r =
          loadPlates(weight: 56, bar: 20, plates: const [15, 9, 1]) as Loaded;
      expect(r.perSide, [9, 9]);
    });
  });
}
