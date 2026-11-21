import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/theme/rf_tokens.dart';

import '../../helpers/contrast.dart';

void main() {
  for (final (name, c) in [
    ('dark', RfColors.dark),
    ('light', RfColors.light),
  ]) {
    group('FND-02 AC3 $name', () {
      final backgrounds = {
        'bg': c.bg,
        'surface': c.surface,
        'navBar': c.navBar,
      };

      test('AC3 text ≥ 4.5', () {
        final text = {
          'textPrimary': c.textPrimary,
          'textSecondary': c.textSecondary,
          'textMuted': c.textMuted,
          for (final r in RfRole.values) '${r.name}Ink': c.ink(r),
        };
        for (final MapEntry(key: fgName, value: fg) in text.entries) {
          for (final MapEntry(key: bgName, value: bg) in backgrounds.entries) {
            expect(
              contrastRatio(fg, bg),
              greaterThanOrEqualTo(4.5),
              reason: '$fgName on $bgName',
            );
          }
        }
        for (final r in RfRole.values) {
          expect(
            contrastRatio(c.onTint(r), c.tint(r)),
            greaterThanOrEqualTo(4.5),
            reason: '${r.name} on-tint on tint',
          );
          expect(
            contrastRatio(c.onSolid, c.fill(r)),
            greaterThanOrEqualTo(4.5),
            reason: 'onSolid on ${r.name} fill',
          );
        }
      });

      test('AC3 borders/icons ≥ 3', () {
        expect(
          contrastRatio(c.successBorder, c.surface),
          greaterThanOrEqualTo(3),
        );
        expect(
          contrastRatio(c.successBorder, c.successTint),
          greaterThanOrEqualTo(3),
        );
        expect(
          contrastRatio(c.actionInk, c.surface),
          greaterThanOrEqualTo(3),
          reason: 'today tile border (actionInk) on surface',
        );
      });
    });
  }
}
