import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'contrast.dart';

void main() {
  group('FND-02 contrast helper', () {
    test('black on white is 21:1 and symmetric', () {
      const black = Color(0xFF000000);
      const white = Color(0xFFFFFFFF);
      expect(contrastRatio(black, white), closeTo(21, 0.001));
      expect(contrastRatio(white, black), closeTo(21, 0.001));
    });

    test('same colour is 1:1', () {
      expect(
        contrastRatio(const Color(0xFF777777), const Color(0xFF777777)),
        1,
      );
    });

    test('matches known WCAG values', () {
      // #767676 on white is the classic 4.54:1 AA boundary grey.
      expect(
        contrastRatio(const Color(0xFF767676), const Color(0xFFFFFFFF)),
        closeTo(4.54, 0.01),
      );
      // Ember-ink on white, from docs/design.md.
      expect(
        contrastRatio(const Color(0xFFC2410C), const Color(0xFFFFFFFF)),
        closeTo(5.18, 0.01),
      );
    });

    test('alpha is composited over the background', () {
      final half = const Color(0xFF000000).withValues(alpha: 0.5);
      final ratio = contrastRatio(half, const Color(0xFFFFFFFF));
      expect(
        ratio,
        closeTo(
          contrastRatio(const Color(0xFF808080), const Color(0xFFFFFFFF)),
          0.1,
        ),
      );
    });
  });
}
