import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/features/library/domain/exercise.dart';
import 'package:repforge/features/logger/domain/logger_rules.dart';
import 'package:repforge/features/logger/domain/workout_session.dart';
import 'package:repforge/features/workout/domain/workout_template.dart';

const bench = SessionExercise(
  id: 'r1',
  exerciseId: 'bench',
  name: 'Bench Press',
  plannedSets: 3,
  repMin: 6,
  repMax: 10,
  targetKg: 60,
);
const plank = SessionExercise(
  id: 'r2',
  exerciseId: 'plank',
  name: 'Plank',
  kind: TargetKind.time,
  seconds: 40,
  bodyweight: true,
);

LoggedSet s(int n, double kg, int reps, {String row = 'r1'}) => LoggedSet(
  id: 'x$n',
  rowId: row,
  exerciseId: 'bench',
  setNo: n,
  kg: kg,
  reps: reps,
);

Exercise ex(String id, Equipment e) => Exercise(
  id: id,
  name: id.toUpperCase(),
  primaryMuscles: const [Muscle.chest],
  secondaryMuscles: const [],
  equipment: e,
  category: ExerciseCategory.values.first,
  level: ExerciseLevel.values.first,
  instructions: const [],
  images: const [],
);

void main() {
  group('LOG-01 prefill', () {
    test('LOG-02 AC5 the suggested target for the set comes first', () {
      final v = prefill(
        bench,
        2,
        loggedInRow: [s(1, 70, 8)],
        targets: {
          1: (kg: 65.0, reps: 9, seconds: null),
          2: (kg: 67.5, reps: 8, seconds: null),
        },
      );
      expect(v, (kg: 67.5, reps: 8, seconds: null));
    });

    test('AC4 with no history for the set, the last one logged now', () {
      final v = prefill(
        bench,
        4,
        loggedInRow: [s(1, 70, 8), s(3, 72.5, 6)],
        targets: {1: (kg: 65.0, reps: 9, seconds: null)},
      );
      expect(v, (kg: 72.5, reps: 6, seconds: null));
    });

    test('AC2 no history: template target and the bottom of the range', () {
      expect(prefill(bench, 1, loggedInRow: const [], targets: const {}), (
        kg: 60.0,
        reps: 6,
        seconds: null,
      ));
      expect(prefill(plank, 1, loggedInRow: const [], targets: const {}), (
        kg: 0.0,
        reps: null,
        seconds: 40,
      ));
      expect(
        prefill(
          bench.copyWith(targetKg: null),
          1,
          loggedInRow: const [],
          targets: const {},
        ).kg,
        0,
      );
    });

    test('AC6 rows shown: planned sets or the highest logged, if more', () {
      expect(setCount(bench, [s(1, 1, 1)]), 3);
      expect(setCount(bench, [s(5, 1, 1)]), 5);
    });
  });

  group('LOG-01 steps and units', () {
    test('AC3 weight steps 2.5 kg, or 5 lb for imperial', () {
      expect(weightStep(UnitSystem.metric), 2.5);
      expect(weightStep(UnitSystem.imperial), 5);
    });

    test('edge a lb value round-trips to the same lb shown', () {
      for (final lb in [45.0, 135.0, 137.5, 225.0, 2.5]) {
        expect(displayWeight(lbToKg(lb), UnitSystem.imperial), lb);
      }
      expect(displayWeight(62.5, UnitSystem.metric), 62.5);
    });

    test('AC3 reps and seconds step 1', () {
      expect(countStep, 1);
    });
  });

  group('LOG-01 changing the workout copy', () {
    test('AC6 + Set adds one planned set to the row', () {
      expect(addSet([bench, plank], 'r1').first.plannedSets, 4);
    });

    test('AC7 add puts the exercise at the end with defaults', () {
      final out = addExercise([bench], ex('dips', Equipment.bodyOnly), 'n1');
      expect(out.map((e) => e.id), ['r1', 'n1']);
      expect(
        (out.last.name, out.last.plannedSets, out.last.bodyweight),
        ('DIPS', 3, true),
      );
    });

    test('AC7 swap with nothing logged replaces the row', () {
      final out = swapExercise(
        [bench, plank],
        'r1',
        ex('incline', Equipment.barbell),
        logged: 0,
        newId: 'n1',
      );
      expect(out.map((e) => (e.id, e.exerciseId, e.plannedSets)), [
        ('r1', 'incline', 3),
        ('r2', 'plank', 3),
      ]);
      expect(out.first.targetKg, isNull, reason: 'targets were the old one');
    });

    test('AC7 swap keeps logged sets under the old exercise', () {
      final out = swapExercise(
        [bench, plank],
        'r1',
        ex('incline', Equipment.barbell),
        logged: 2,
        newId: 'n1',
      );
      expect(out.map((e) => (e.id, e.exerciseId, e.plannedSets)), [
        ('r1', 'bench', 2),
        ('n1', 'incline', 1),
        ('r2', 'plank', 3),
      ]);
    });
  });
}
