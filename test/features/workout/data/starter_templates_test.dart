import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/features/workout/data/starter_templates.dart';
import 'package:repforge/features/workout/domain/template_rules.dart';

void main() {
  test('WKT-01 AC12 every starter exercise is in the catalog seed', () {
    final seed = jsonDecode(
      File('assets/exercises/seed.json').readAsStringSync(),
    );
    final ids = {
      for (final e in (seed as Map)['exercises'] as List) (e as Map)['id'],
    };
    for (final t in starterTemplates) {
      expect(canSave(t.name, t.exercises), isTrue, reason: t.name);
      for (final e in t.exercises) {
        expect(
          ids,
          contains(e.exerciseId),
          reason: '${t.name}: ${e.exerciseId}',
        );
        expect(e.repMin, lessThanOrEqualTo(e.repMax));
      }
    }
  });
}
