import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/features/logger/domain/summary.dart';
import 'package:repforge/features/logger/domain/workout_session.dart';
import 'package:repforge/features/workout/domain/workout_template.dart';

const bench = SessionExercise(id: 'r1', exerciseId: 'bench', name: 'Bench');
const pullup = SessionExercise(
  id: 'r2',
  exerciseId: 'pullup',
  name: 'Pull-up',
  bodyweight: true,
);
const plank = SessionExercise(
  id: 'r3',
  exerciseId: 'plank',
  name: 'Plank',
  kind: TargetKind.time,
);
const curl = SessionExercise(id: 'r4', exerciseId: 'curl', name: 'Curl');

LoggedSet w(String row, int n, double kg, int reps, {bool pr = false}) =>
    LoggedSet(
      id: '$row-$n',
      rowId: row,
      exerciseId: {'r1': 'bench', 'r2': 'pullup', 'r4': 'curl'}[row]!,
      setNo: n,
      kg: kg,
      reps: reps,
      isPr: pr,
    );

LoggedSet t(int n, int seconds) => LoggedSet(
  id: 'r3-$n',
  rowId: 'r3',
  exerciseId: 'plank',
  setNo: n,
  kg: 0,
  seconds: seconds,
);

WorkoutSession session(List<LoggedSet> sets, {int minutes = 62}) =>
    WorkoutSession(
      id: 's',
      name: 'Push',
      templateId: 'push',
      exercises: const [bench, pullup, plank, curl],
      date: DateTime.utc(2026, 11, 23),
      startedAt: DateTime.utc(2026, 11, 23, 9),
      endedAt: DateTime.utc(2026, 11, 23, 9).add(Duration(minutes: minutes)),
      sets: sets,
    );

void main() {
  group('LOG-05 buildSummary', () {
    final today = session([
      w('r1', 1, 100, 5, pr: true),
      w('r1', 2, 100, 5),
      w('r2', 1, 0, 10),
      w('r2', 2, 0, 8),
      t(1, 45),
      t(2, 60),
    ]);

    test('AC2 duration, sets and weighted volume', () {
      final s = buildSummary(today);
      expect(s.duration, const Duration(minutes: 62));
      expect(s.setCount, 6);
      expect(s.volumeKg, 1000);
    });

    test('AC3 each exercise by its measure; unlogged rows left out', () {
      final s = buildSummary(today);
      expect([for (final e in s.exercises) e.row.id], ['r1', 'r2', 'r3']);
      expect(
        [for (final e in s.exercises) (e.measure, e.amount)],
        [(Measure.volume, 1000), (Measure.reps, 18), (Measure.time, 105)],
      );
    });

    test('AC4 PR lines from the stored flags', () {
      final s = buildSummary(today);
      expect(
        [for (final p in s.prs) (p.row.name, p.set.kg)],
        [('Bench', 100.0)],
      );
      expect(buildSummary(session([w('r1', 1, 100, 5)])).prs, isEmpty);
    });

    test('AC5 changes against the previous workout', () {
      final prev = session([w('r1', 1, 90, 5), w('r2', 1, 0, 10)], minutes: 65);
      final s = buildSummary(today, previous: prev);
      expect(s.hasPrevious, isTrue);
      expect(s.durationChange, const Duration(minutes: -3));
      expect(s.setChange, 4);
      expect(s.volumeChange, 550);
    });

    test('AC5 no previous: nothing to compare', () {
      final s = buildSummary(today);
      expect(s.hasPrevious, isFalse);
      expect(
        (s.durationChange, s.setChange, s.volumeChange),
        (null, null, null),
      );
    });

    test('AC5 each exercise against its last time; never done gives none', () {
      final s = buildSummary(
        today,
        lastByExercise: {
          'bench': [w('r1', 1, 95, 5)],
          'pullup': [w('r2', 1, 0, 12)],
        },
      );
      expect([for (final e in s.exercises) e.change], [525, 6, null]);
    });

    test('edge only bodyweight or timed sets: no total volume', () {
      final s = buildSummary(session([w('r2', 1, 0, 10), t(1, 30)]));
      expect(s.volumeKg, isNull);
      expect(s.setCount, 2);
      expect(
        buildSummary(
          session([w('r2', 1, 0, 10)]),
          previous: session([w('r1', 1, 50, 5)]),
        ).volumeChange,
        isNull,
      );
    });

    test('edge a workout over 24 h keeps its full duration', () {
      final s = buildSummary(
        session([w('r1', 1, 50, 5)], minutes: 26 * 60 + 5),
      );
      expect(s.duration, const Duration(hours: 26, minutes: 5));
    });

    test('AC5 no change when last time was measured differently', () {
      final s = buildSummary(
        session([w('r2', 1, 10, 5)]),
        lastByExercise: {
          'pullup': [w('r2', 1, 0, 12)],
        },
      );
      expect(s.exercises.single.change, isNull);
    });

    test('edge a template edited since: only shared exercises compare', () {
      final prev = WorkoutSession(
        id: 'p',
        name: 'Push',
        templateId: 'push',
        exercises: const [curl],
        date: DateTime.utc(2026, 11, 16),
        startedAt: DateTime.utc(2026, 11, 16, 9),
        endedAt: DateTime.utc(2026, 11, 16, 10),
        sets: [w('r4', 1, 20, 10)],
      );
      final s = buildSummary(today, previous: prev);
      expect(s.hasPrevious, isTrue);
      expect(s.volumeChange, 800);
      expect(s.exercises.every((e) => e.change == null), isTrue);
    });

    test('edge weighted pull-ups count as volume', () {
      final s = buildSummary(session([w('r2', 1, 10, 5)]));
      expect(s.exercises.single.measure, Measure.volume);
      expect(s.volumeKg, 50);
    });
  });
}
