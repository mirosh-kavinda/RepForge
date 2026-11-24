import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/features/logger/domain/rest_timer.dart';
import 'package:repforge/features/logger/domain/workout_session.dart';

const squat = SessionExercise(
  id: 'r1',
  exerciseId: 'squat',
  name: 'Squat',
  plannedSets: 2,
  restSec: 180,
);
const curl = SessionExercise(
  id: 'r2',
  exerciseId: 'curl',
  name: 'Curl',
  plannedSets: 2,
  restSec: 60,
  superset: 'A',
);
const pushdown = SessionExercise(
  id: 'r3',
  exerciseId: 'pushdown',
  name: 'Pushdown',
  plannedSets: 2,
  restSec: 90,
  superset: 'A',
);
const stretch = SessionExercise(
  id: 'r4',
  exerciseId: 'stretch',
  name: 'Stretch',
  plannedSets: 1,
  restSec: 0,
);

LoggedSet done(String row, int n) => LoggedSet(
  id: '$row$n',
  rowId: row,
  exerciseId: row,
  setNo: n,
  kg: 10,
  reps: 8,
);

WorkoutSession session(List<LoggedSet> sets) => WorkoutSession(
  id: 's',
  name: 'Mixed',
  date: DateTime.utc(2026, 11, 23),
  startedAt: DateTime.utc(2026, 11, 23, 9),
  exercises: const [squat, curl, pushdown, stretch],
  sets: sets,
);

final t0 = DateTime.utc(2026, 11, 23, 10);

void main() {
  group('LOG-03 when a rest starts', () {
    test('AC1 a plain exercise rests for its own time', () {
      expect(restAfterLog(session([]).exercises, 'r1'), 180);
    });

    test('AC3 a superset member that is not last starts no rest', () {
      expect(restAfterLog(session([]).exercises, 'r2'), isNull);
      expect(restAfterLog(session([]).exercises, 'r3'), 90);
    });

    test('edge a rest time of 0 starts no rest', () {
      expect(restAfterLog(session([]).exercises, 'r4'), isNull);
    });
  });

  group('LOG-03 what comes next', () {
    test('AC1 the next set of the same exercise', () {
      expect(nextUp(session([done('r1', 1)]), 'r1'), (rowId: 'r1', setNo: 2));
    });

    test('AC1 after the last set, the next exercise', () {
      expect(nextUp(session([done('r1', 1), done('r1', 2)]), 'r1'), (
        rowId: 'r2',
        setNo: 1,
      ));
    });

    test('AC3 within a superset: the next member, then back to the first', () {
      expect(nextUp(session([done('r2', 1)]), 'r2'), (rowId: 'r3', setNo: 1));
      expect(nextUp(session([done('r2', 1), done('r3', 1)]), 'r3'), (
        rowId: 'r2',
        setNo: 2,
      ));
    });

    test('AC1 nothing left: null', () {
      expect(
        nextUp(
          session([
            for (final r in ['r1', 'r2', 'r3']) ...[done(r, 1), done(r, 2)],
            done('r4', 1),
          ]),
          'r4',
        ),
        isNull,
      );
    });
  });

  group('LOG-03 the countdown', () {
    final r = startRest(t0, 120, (rowId: 'r1', setNo: 2));

    test('AC1 AC6 time left comes from the end time', () {
      expect(r.endsAt, t0.add(const Duration(seconds: 120)));
      expect(left(r, t0.add(const Duration(seconds: 30))).inSeconds, 90);
      expect(left(r, t0.add(const Duration(minutes: 5))), Duration.zero);
      expect(isOver(r, t0.add(const Duration(seconds: 119))), isFalse);
      expect(isOver(r, t0.add(const Duration(seconds: 120))), isTrue);
    });

    test('AC4 ±15 s changes this rest; never below zero', () {
      expect(left(adjustRest(r, 15, t0), t0).inSeconds, 135);
      expect(left(adjustRest(r, -15, t0), t0).inSeconds, 105);
      final past = adjustRest(startRest(t0, 10, null), -15, t0);
      expect(isOver(past, t0), isTrue, reason: 'edge: ends at once');
    });

    test('AC4 pause holds the time left; resume continues', () {
      final p = pauseRest(r, t0.add(const Duration(seconds: 20)));
      expect(p.endsAt, isNull);
      expect(left(p, t0.add(const Duration(hours: 1))).inSeconds, 100);
      expect(isOver(p, t0.add(const Duration(hours: 1))), isFalse);
      expect(left(adjustRest(p, 15, t0), t0).inSeconds, 115);
      final later = t0.add(const Duration(minutes: 10));
      final back = resumeRest(p, later);
      expect(back.endsAt, later.add(const Duration(seconds: 100)));
    });
  });
}
