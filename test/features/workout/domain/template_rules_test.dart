import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/features/library/domain/exercise.dart';
import 'package:repforge/features/workout/domain/template_rules.dart';
import 'package:repforge/features/workout/domain/workout_template.dart';

TemplateExercise ex(
  String id, {
  String? superset,
  int sets = 3,
  int rest = 120,
  TargetKind kind = TargetKind.reps,
  int seconds = 45,
}) => TemplateExercise(
  id: id,
  exerciseId: 'x$id',
  superset: superset,
  sets: sets,
  restSec: rest,
  kind: kind,
  seconds: seconds,
);

List<String?> groups(List<TemplateExercise> l) =>
    l.map((e) => e.superset).toList();

void main() {
  group('WKT-01 name and save rules', () {
    test('AC2 name is trimmed, 1–40 characters', () {
      expect(cleanName('  Leg Day '), 'Leg Day');
      expect(cleanName('   '), isNull);
      expect(cleanName('a' * 40), 'a' * 40);
      expect(cleanName('a' * 41), isNull);
    });

    test('AC2 save needs a name and at least one exercise', () {
      expect(canSave('Leg Day', []), isFalse);
      expect(canSave(' ', [ex('1')]), isFalse);
      expect(canSave('Leg Day', [ex('1')]), isTrue);
    });

    test('AC3 new entries get the defaults and distinct row ids', () {
      final list = append([], ['a', 'a']);
      expect(list, hasLength(2));
      expect(list.first.id, isNot(list.last.id));
      final e = list.first;
      expect(
        (e.sets, e.kind, e.repMin, e.repMax, e.targetKg, e.restSec),
        (3, TargetKind.reps, 8, 12, null, 120),
      );
    });

    test('edge append stops at 30 exercises', () {
      final list = append([], List.filled(29, 'a'));
      expect(remainingSlots(list), 1);
      expect(append(list, ['b', 'c']), hasLength(30));
    });
  });

  group('WKT-01 supersets', () {
    test('AC6 linking adjacent rows takes the next free letter', () {
      var l = [ex('1'), ex('2'), ex('3'), ex('4'), ex('5')];
      l = link(l, {3, 4});
      expect(groups(l), [null, null, null, 'A', 'A']);
      l = link(l, {0, 1});
      expect(groups(l), ['B', 'B', null, 'A', 'A']);
    });

    test('AC6 non-adjacent or single selections do not link', () {
      final l = [ex('1'), ex('2'), ex('3')];
      expect(canLink(l, {0, 2}), isFalse);
      expect(canLink(l, {1}), isFalse);
      expect(link(l, {0, 2}), same(l));
    });

    test('AC6 relinking members reuses the letter they free up', () {
      var l = link([ex('1'), ex('2'), ex('3')], {0, 1});
      l = link(l, {0, 1, 2});
      expect(groups(l), ['A', 'A', 'A']);
    });

    test('AC6 unlink from any member ends the group', () {
      final l = unlink(link([ex('1'), ex('2'), ex('3')], {0, 1, 2}), 1);
      expect(groups(l), [null, null, null]);
    });

    test('edge reorder inside a superset keeps it linked', () {
      final l = move(link([ex('1'), ex('2'), ex('3')], {0, 1}), 0, 1);
      expect(l.map((e) => e.id), ['2', '1', '3']);
      expect(groups(l), ['A', 'A', null]);
    });

    test('AC6 moving a member out ends the link', () {
      final l = move(link([ex('1'), ex('2'), ex('3')], {0, 1}), 0, 2);
      expect(groups(l), [null, null, null]);
    });

    test('edge dragging a non-member between members ends it', () {
      final l = move(link([ex('1'), ex('2'), ex('3')], {0, 1}), 2, 1);
      expect(groups(l), [null, null, null]);
    });

    test('AC6 removing a member so one is left ends the link', () {
      final pair = link([ex('1'), ex('2'), ex('3')], {0, 1});
      expect(groups(removeAt(pair, 0)), [null, null]);
      final trio = link([ex('1'), ex('2'), ex('3')], {0, 1, 2});
      expect(groups(removeAt(trio, 0)), ['A', 'A']);
    });

    test('AC7 rest only after the last member of each round', () {
      final l = link([ex('1', rest: 60), ex('2', rest: 90), ex('3')], {0, 1});
      expect(restsInsideSuperset(l, 0), isTrue);
      expect(effectiveRest(l, 0), 0);
      expect(effectiveRest(l, 1), 90);
      expect(effectiveRest(l, 2), 120);
      expect(effectiveRest(unlink(l, 0), 0), 60, reason: 'stored rest kept');
    });
  });

  group('WKT-01 estimate and summary', () {
    test('AC8 sets × (40 s or timed seconds + rest), nearest 5 min', () {
      // 4 × (40 + 180) = 880 s; 3 × (45 + 90) = 405 s → 1285 s ≈ 21.4 → 20.
      final l = [
        ex('1', sets: 4, rest: 180),
        ex('2', sets: 3, rest: 90, kind: TargetKind.time),
      ];
      expect(estimateMinutes(l), 20);
      expect(totalSets(l), 7);
    });

    test('AC8 superset inner rest is skipped; minimum 5', () {
      final l = link([ex('1', rest: 600), ex('2', rest: 0)], {0, 1});
      // 3 × 40 + 3 × 40 = 240 s = 4 min → 5.
      expect(estimateMinutes(l), 5);
      expect(estimateMinutes([ex('1', sets: 1, rest: 0)]), 5);
    });

    test('AC8 distinct primary muscles in order', () {
      Exercise e(String id, List<Muscle> m) => Exercise(
        id: id,
        name: id,
        primaryMuscles: m,
        secondaryMuscles: const [],
        equipment: Equipment.barbell,
        category: ExerciseCategory.strength,
        level: ExerciseLevel.beginner,
        instructions: const [],
        images: const [],
      );
      final catalog = {
        'x1': e('x1', [Muscle.quadriceps, Muscle.glutes]),
        'x2': e('x2', [Muscle.hamstrings, Muscle.glutes]),
      };
      expect(primaryMuscles([ex('1'), ex('2'), ex('3')], catalog), [
        Muscle.quadriceps,
        Muscle.glutes,
        Muscle.hamstrings,
      ]);
    });
  });

  group('WKT-01 copies, ranges, weights', () {
    test('AC10 copy name keeps the suffix within 40 characters', () {
      expect(copyName('Leg Day'), 'Leg Day (copy)');
      final long = copyName('a' * 40);
      expect(long.length, lessThanOrEqualTo(40));
      expect(long, endsWith(' (copy)'));
    });

    test('edge max-first range is swapped on save', () {
      final t = forSave(
        id: 't',
        name: ' Legs ',
        exercises: [ex('1').copyWith(repMin: 12, repMax: 8)],
      );
      expect(t.name, 'Legs');
      expect((t.exercises.single.repMin, t.exercises.single.repMax), (8, 12));
    });

    test('edge weight: blank is none, lb converts to 0.01 kg, 0–500 kg', () {
      expect(parseWeight('', MassUnit.kg), (kg: null, error: null));
      expect(parseWeight('102,5', MassUnit.kg).kg, 102.5);
      expect(parseWeight('225', MassUnit.lb).kg, 102.06);
      expect(parseWeight('abc', MassUnit.kg).error, WeightError.unreadable);
      expect(parseWeight('501', MassUnit.kg).error, WeightError.outOfRange);
      expect(parseWeight('1200', MassUnit.lb).error, WeightError.outOfRange);
    });
  });
}
