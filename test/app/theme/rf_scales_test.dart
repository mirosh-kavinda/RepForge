import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/theme/rf_scales.dart';

void main() {
  group('FND-02 scales', () {
    test('AC7 spacing is the 4-pt scale from design.md', () {
      expect(
        [
          RfSpace.s4,
          RfSpace.s8,
          RfSpace.s12,
          RfSpace.s16,
          RfSpace.s20,
          RfSpace.s24,
          RfSpace.s32,
        ],
        [4.0, 8.0, 12.0, 16.0, 20.0, 24.0, 32.0],
      );
    });

    test('AC7 radius scale from design.md', () {
      expect(
        [RfRadius.xs, RfRadius.sm, RfRadius.md, RfRadius.lg],
        [4.0, 8.0, 12.0, 16.0],
      );
      expect(RfRadius.pill, greaterThanOrEqualTo(999));
    });

    test('AC12 minimum target is 48 dp', () {
      expect(RfSize.minTarget, 48.0);
    });
  });
}
