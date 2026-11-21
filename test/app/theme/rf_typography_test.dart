import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/theme/rf_typography.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final t = RfTextStyles.standard;
  final scale = {
    'statXl': (t.statXl, RfFonts.display, 700, 30.0),
    'title': (t.title, RfFonts.display, 700, 26.0),
    'heading': (t.heading, RfFonts.display, 700, 20.0),
    'button': (t.button, RfFonts.text, 600, 16.0),
    'body': (t.body, RfFonts.text, 400, 15.0),
    'label': (t.label, RfFonts.text, 400, 13.0),
    'labelStrong': (t.labelStrong, RfFonts.text, 500, 13.0),
    'overline': (t.overline, RfFonts.text, 600, 12.0),
  };

  group('FND-02 typography', () {
    test('AC5 scale matches design.md', () {
      for (final MapEntry(key: name, value: (style, family, weight, size))
          in scale.entries) {
        expect(style.fontFamily, family, reason: name);
        expect(style.fontSize, size, reason: name);
        expect(
          style.fontWeight,
          FontWeight.values[weight ~/ 100 - 1],
          reason: name,
        );
        expect(
          style.fontVariations,
          contains(FontVariation('wght', weight.toDouble())),
          reason: '$name must set the variable-font weight axis',
        );
      }
    });

    test('AC5 every style uses tabular figures', () {
      for (final MapEntry(key: name, value: (style, _, _, _))
          in scale.entries) {
        expect(
          style.fontFeatures,
          contains(const FontFeature.tabularFigures()),
          reason: name,
        );
      }
    });

    test(
      'AC6 fonts are bundled and declared, so no network is needed',
      () async {
        final pubspec = File('pubspec.yaml').readAsStringSync();
        for (final (family, asset) in [
          (RfFonts.display, 'assets/fonts/SpaceGrotesk-Variable.ttf'),
          (RfFonts.text, 'assets/fonts/Inter-Variable.ttf'),
        ]) {
          expect(pubspec, contains('family: $family'));
          expect(pubspec, contains('asset: $asset'));
          final bytes = await rootBundle.load(asset);
          expect(bytes.lengthInBytes, greaterThan(100000), reason: asset);
          final loader = FontLoader('${family}Check')
            ..addFont(Future.value(bytes));
          await loader.load();
        }
      },
    );
  });
}
