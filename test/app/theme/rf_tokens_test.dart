import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/theme/rf_tokens.dart';

/// Rows of the markdown table that follows [heading] in docs/design.md.
List<List<String>> tableAfter(String doc, String heading) {
  final start = doc.indexOf(heading);
  if (start < 0) throw StateError('heading "$heading" not in design.md');
  final rows = <List<String>>[];
  var inTable = false;
  for (final line in doc.substring(start).split(RegExp(r'\r?\n')).skip(1)) {
    if (line.startsWith('|')) {
      inTable = true;
      final cells = line.split('|').map((c) => c.trim()).toList().sublist(1);
      cells.removeLast();
      if (cells.every((c) => RegExp(r'^-+$').hasMatch(c))) continue;
      rows.add(cells);
    } else if (inTable) {
      break;
    }
  }
  return rows.skip(1).toList(); // drop the header row
}

Color hex(String s) {
  final m = RegExp(r'#([0-9A-Fa-f]{6})').firstMatch(s);
  if (m == null) throw StateError('no hex in "$s"');
  return Color(int.parse('FF${m.group(1)}', radix: 16));
}

/// "action on-tint" → "actionOnTint", "success border (done row)" → "successBorder".
String tokenName(String label) {
  final words = label
      .split('(')
      .first
      .trim()
      .split(RegExp(r'[\s-]+'))
      .where((w) => w.isNotEmpty)
      .toList();
  return words.first +
      words.skip(1).map((w) => w[0].toUpperCase() + w.substring(1)).join();
}

void main() {
  final doc = File('docs/design.md').readAsStringSync();
  final base = tableAfter(doc, '## Colour tokens (dark)');
  final semantic = tableAfter(doc, 'Semantic (solid / tint / on-tint):');
  final both = tableAfter(doc, '## Colour tokens (light)');

  final expectedDark = <String, Color>{};
  final expectedLight = <String, Color>{};
  for (final row in both) {
    final light = hex(row[2]);
    final dark = hex(row[1]);
    expectedDark[tokenName(row[0])] = dark;
    expectedLight[tokenName(row[0])] = light;
  }
  for (final row in base) {
    expectedDark.putIfAbsent(row[0].split(' ').first, () => hex(row[1]));
  }

  group('FND-02 colour tokens', () {
    test('AC1 dark matches design.md', () {
      expect(RfColors.dark.toMap(), expectedDark);
    });

    test(
      'AC1 dark base and semantic tables agree with the two-column table',
      () {
        for (final row in base) {
          expect(
            RfColors.dark.toMap()[row[0].split(' ').first],
            hex(row[1]),
            reason: row[0],
          );
        }
        const roles = ['action', 'success', 'rest', 'missed'];
        for (final (i, row) in semantic.indexed) {
          final role = roles[i];
          final map = RfColors.dark.toMap();
          expect(map['${role}Fill'], hex(row[1]), reason: '$role fill');
          expect(map['${role}Tint'], hex(row[2]), reason: '$role tint');
          expect(map['${role}OnTint'], hex(row[3]), reason: '$role on-tint');
        }
      },
    );

    test('AC2 light matches design.md', () {
      expect(RfColors.light.toMap(), expectedLight);
    });

    test('AC2 both themes expose the same token names', () {
      expect(
        RfColors.light.toMap().keys.toSet(),
        RfColors.dark.toMap().keys.toSet(),
      );
      expect(RfColors.dark.toMap(), hasLength(26));
    });

    test('role lookups return the matching tokens', () {
      const c = RfColors.light;
      expect(c.fill(RfRole.action), c.actionFill);
      expect(c.ink(RfRole.success), c.successInk);
      expect(c.tint(RfRole.rest), c.restTint);
      expect(c.onTint(RfRole.missed), c.missedOnTint);
    });

    test('lerp and copyWith', () {
      expect(
        RfColors.dark.lerp(RfColors.light, 0).toMap(),
        RfColors.dark.toMap(),
      );
      expect(
        RfColors.dark.lerp(RfColors.light, 1).toMap(),
        RfColors.light.toMap(),
      );
      expect(RfColors.dark.lerp(null, 0.5), same(RfColors.dark));
      final c = RfColors.dark.copyWith(bg: const Color(0xFF000000));
      expect(c.bg, const Color(0xFF000000));
      expect(c.surface, RfColors.dark.surface);
    });
  });
}
