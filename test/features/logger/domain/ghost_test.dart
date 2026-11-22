import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/features/logger/domain/ghost.dart';
import 'package:repforge/features/logger/domain/logger_rules.dart';
import 'package:repforge/features/logger/domain/workout_session.dart';
import 'package:repforge/features/workout/domain/workout_template.dart';

const bench = SessionExercise(
  id: 'r1',
  exerciseId: 'bench',
  name: 'Bench',
  plannedSets: 3,
  repMin: 6,
  repMax: 10,
);
const plank = SessionExercise(
  id: 'r2',
  exerciseId: 'plank',
  name: 'Plank',
  kind: TargetKind.time,
  seconds: 40,
);
const dips = SessionExercise(
  id: 'r3',
  exerciseId: 'dips',
  name: 'Dips',
  repMin: 8,
  repMax: 12,
  bodyweight: true,
);

var _n = 0;
LoggedSet s(
  int setNo,
  double kg, {
  int? reps,
  int? seconds,
  String ex = 'bench',
}) => LoggedSet(
  id: 'x${_n++}',
  rowId: 'r',
  exerciseId: ex,
  setNo: setNo,
  kg: kg,
  reps: reps,
  seconds: seconds,
);

Map<int, LoggedSet> last(List<LoggedSet> sets) => {
  for (final x in sets) x.setNo: x,
};

void main() {
  group('LOG-02 targets', () {
    test('AC2 every set at the top: + 2.5 kg at the bottom of the range', () {
      final t = targets(
        bench,
        last([s(1, 60, reps: 10), s(2, 60, reps: 11), s(3, 57.5, reps: 10)]),
        UnitSystem.metric,
      );
      expect(t, {
        1: (kg: 62.5, reps: 6, seconds: null),
        2: (kg: 62.5, reps: 6, seconds: null),
        3: (kg: 60.0, reps: 6, seconds: null),
      });
    });

    test('AC2 otherwise same weight, one more rep, up to the top', () {
      final t = targets(
        bench,
        last([s(1, 60, reps: 10), s(2, 60, reps: 8)]),
        UnitSystem.metric,
      );
      expect(t, {
        1: (kg: 60.0, reps: 10, seconds: null),
        2: (kg: 60.0, reps: 9, seconds: null),
      });
    });

    test('AC2 imperial adds 5 lb, rounded to the 5 lb step', () {
      final t = targets(
        bench,
        last([s(1, lbToKg(133), reps: 10)]),
        UnitSystem.imperial,
      );
      expect(displayWeight(t[1]!.kg, UnitSystem.imperial), 140);
    });

    test('AC3 timed: + 5 s once the target time is reached', () {
      expect(
        targets(
          plank,
          last([s(1, 0, seconds: 40, ex: 'plank')]),
          UnitSystem.metric,
        ),
        {1: (kg: 0.0, reps: null, seconds: 45)},
      );
      expect(
        targets(
          plank,
          last([s(1, 0, seconds: 30, ex: 'plank')]),
          UnitSystem.metric,
        )[1]!.seconds,
        30,
      );
    });

    test('AC4 bodyweight at 0 kg adds a rep, no cap, never weight', () {
      final t = targets(
        dips,
        last([s(1, 0, reps: 12, ex: 'dips'), s(2, 0, reps: 14, ex: 'dips')]),
        UnitSystem.metric,
      );
      expect(t, {
        1: (kg: 0.0, reps: 13, seconds: null),
        2: (kg: 0.0, reps: 15, seconds: null),
      });
    });

    test('edge today\'s range is used when it changed', () {
      final t = targets(
        bench.copyWith(repMax: 8),
        last([s(1, 60, reps: 9)]),
        UnitSystem.metric,
      );
      expect(t[1], (kg: 62.5, reps: 6, seconds: null));
    });

    test('AC5 no history, no targets', () {
      expect(targets(bench, const {}, UnitSystem.metric), isEmpty);
    });
  });

  group('LOG-02 PR', () {
    final history = [s(1, 100, reps: 5), s(2, 90, reps: 8)];

    test('AC6 a better estimated 1RM than ever is a PR', () {
      // History best: 100 × 5 → 116.7; 90 × 8 → 114.
      final a = s(1, 100, reps: 6); // 120
      final b = s(2, 95, reps: 5); // 110.8
      expect(prSets([a, b], history), {a.id});
    });

    test('AC6 earlier sets in this workout count too', () {
      final a = s(1, 105, reps: 5); // 122.5, PR
      final b = s(2, 102.5, reps: 6); // 123, PR over a
      final c = s(3, 100, reps: 6); // 120, not
      expect(prSets([a, b, c], history), {a.id, b.id});
    });

    test('AC6 the first time an exercise is done gives no PR', () {
      expect(prSets([s(1, 100, reps: 5)], const []), isEmpty);
    });

    test(
      'AC6 bodyweight, timed and high reps: more than ever at that weight',
      () {
        final bw = [s(1, 0, reps: 12, ex: 'dips')];
        final more = s(1, 0, reps: 13, ex: 'dips');
        final same = s(2, 0, reps: 12, ex: 'dips');
        expect(prSets([more, same], bw), {more.id});

        final hold = [s(1, 0, seconds: 40, ex: 'plank')];
        final longer = s(1, 0, seconds: 45, ex: 'plank');
        expect(prSets([longer], hold), {longer.id});

        final high = [s(1, 40, reps: 15)];
        expect(prSets([s(1, 40, reps: 16)], high), hasLength(1));
        expect(
          prSets([s(1, 35, reps: 15)], high),
          isEmpty,
          reason: 'not more reps',
        );
      },
    );

    test('AC7 without the PR set, the next best becomes the PR', () {
      final a = s(1, 105, reps: 5);
      final b = s(2, 102.5, reps: 5); // 119.6 > 116.7 but < a
      expect(prSets([a, b], history), {a.id});
      expect(prSets([b], history), {b.id});
    });
  });
}
