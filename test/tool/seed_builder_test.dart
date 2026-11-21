import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/seed/seed_builder.dart';

Map<String, Object?> src({
  String id = 'Ex_1',
  String name = 'Barbell Bench Press',
  List<String> primary = const ['chest'],
  List<String> secondary = const ['triceps'],
  String? equipment = 'barbell',
  String category = 'strength',
  String level = 'beginner',
  String? mechanic = 'compound',
  String? force = 'push',
  List<String> instructions = const ['Lie down.'],
  List<String> images = const ['Ex_1/0.jpg'],
}) => {
  'id': id,
  'name': name,
  'primaryMuscles': primary,
  'secondaryMuscles': secondary,
  'equipment': equipment,
  'category': category,
  'level': level,
  'mechanic': mechanic,
  'force': force,
  'instructions': instructions,
  'images': images,
};

Map<String, Object?> only(List<Map<String, Object?>> source) =>
    (buildSeed(source, catalogVersion: 1, sourceCommit: 'x')['exercises']!
                as List)
            .single
        as Map<String, Object?>;

void main() {
  group('FND-03 seed builder', () {
    test('AC1 keeps the taxonomy fields and trims text', () {
      final e = only([
        src(
          name: '  Barbell   Bench Press ',
          instructions: [' Lie down. ', '', 'Press.'],
        ),
      ]);
      expect(e, {
        'id': 'Ex_1',
        'name': 'Barbell Bench Press',
        'primaryMuscles': ['chest'],
        'secondaryMuscles': ['triceps'],
        'equipment': 'barbell',
        'category': 'strength',
        'level': 'beginner',
        'mechanic': 'compound',
        'force': 'push',
        'instructions': ['Lie down.', 'Press.'],
        'images': ['Ex_1/0.jpg'],
        'hash': isA<String>(),
      });
    });

    test('AC1 equipment mapping', () {
      String equipmentOf(String? value, {String name = 'Thing'}) =>
          only([src(equipment: value, name: name)])['equipment']! as String;
      expect(equipmentOf('kettlebells'), 'kettlebell');
      expect(equipmentOf('e-z curl bar'), 'EZ bar');
      expect(equipmentOf('foam roll'), 'other');
      expect(equipmentOf('medicine ball'), 'other');
      expect(equipmentOf('exercise ball'), 'other');
      expect(equipmentOf(null), 'body only');
      expect(
        equipmentOf('machine', name: 'Smith Machine Squat'),
        'smith machine',
      );
      expect(
        equipmentOf('other', name: 'smith incline press'),
        'smith machine',
      );
    });

    test(
      'AC1 missing mechanic and force stay empty; no images is an empty list',
      () {
        final e = only([src(mechanic: null, force: null, images: [])]);
        expect(e['mechanic'], isNull);
        expect(e['force'], isNull);
        expect(e['images'], isEmpty);
      },
    );

    test('AC1 a muscle listed as primary is not repeated as secondary', () {
      final e = only([
        src(primary: ['chest'], secondary: ['chest', 'triceps']),
      ]);
      expect(e['secondaryMuscles'], ['triceps']);
    });

    test('AC1 same input gives identical output, sorted by id', () {
      final source = [src(id: 'B'), src(id: 'A')];
      final a = encodeSeed(
        buildSeed(source, catalogVersion: 3, sourceCommit: 'c'),
      );
      final b = encodeSeed(
        buildSeed(
          source.reversed.toList(),
          catalogVersion: 3,
          sourceCommit: 'c',
        ),
      );
      expect(a, b);
      final decoded = jsonDecode(a) as Map<String, Object?>;
      expect(decoded['catalogVersion'], 3);
      expect(decoded['source'], 'c');
      expect((decoded['exercises']! as List).map((e) => (e as Map)['id']), [
        'A',
        'B',
      ]);
    });

    test('AC1 the hash changes only when the content changes', () {
      String hashOf(Map<String, Object?> e) => only([e])['hash']! as String;
      expect(hashOf(src()), hashOf(src()));
      expect(hashOf(src()), isNot(hashOf(src(level: 'expert'))));
    });

    for (final (field, bad) in [
      ('primaryMuscles', src(primary: ['wings'])),
      ('secondaryMuscles', src(secondary: ['wings'])),
      ('equipment', src(equipment: 'spaceship')),
      ('category', src(category: 'yoga')),
      ('level', src(level: 'god')),
      ('mechanic', src(mechanic: 'hybrid')),
      ('force', src(force: 'twist')),
    ]) {
      test('AC2 unknown $field fails and names the exercise and value', () {
        expect(
          () => buildSeed([bad], catalogVersion: 1, sourceCommit: 'x'),
          throwsA(
            isA<SeedError>()
                .having((e) => e.exerciseId, 'exercise', 'Ex_1')
                .having((e) => e.field, 'field', field)
                .having((e) => e.toString(), 'message', contains('Ex_1')),
          ),
        );
      });
    }

    test('AC2 an exercise without primary muscles fails', () {
      expect(
        () =>
            buildSeed([src(primary: [])], catalogVersion: 1, sourceCommit: 'x'),
        throwsA(isA<SeedError>()),
      );
    });

    test('AC2 duplicate ids fail', () {
      expect(
        () => buildSeed([src(), src()], catalogVersion: 1, sourceCommit: 'x'),
        throwsA(isA<SeedError>()),
      );
    });

    test('AC1 the pinned source maps fully (876 exercises)', () {
      final source =
          (jsonDecode(
                    File('tool/seed/source/exercises.json').readAsStringSync(),
                  )
                  as List)
              .cast<Map<String, Object?>>();
      final seed = buildSeed(
        source,
        catalogVersion: seedCatalogVersion,
        sourceCommit: seedSourceCommit,
      );
      expect(seed['exercises'], hasLength(876));
    });

    test('AC1 committed seed equals a rebuild from the pinned source', () {
      final source =
          (jsonDecode(
                    File('tool/seed/source/exercises.json').readAsStringSync(),
                  )
                  as List)
              .cast<Map<String, Object?>>();
      final rebuilt = encodeSeed(
        buildSeed(
          source,
          catalogVersion: seedCatalogVersion,
          sourceCommit: seedSourceCommit,
        ),
      );
      final committed = File(
        'assets/exercises/seed.json',
      ).readAsStringSync().replaceAll('\r\n', '\n');
      expect(committed, rebuilt);
    });
  });
}
