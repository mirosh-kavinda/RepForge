import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/projection.dart';
import 'package:repforge/features/body/domain/body_snapshot.dart';
import 'package:repforge/features/goals/domain/goal.dart';
import 'package:repforge/features/goals/domain/goal_rules.dart';
import 'package:repforge/features/logger/domain/workout_session.dart';

DateTime d(int day, [int month = 11]) => DateTime.utc(2026, month, day);

LoggedSet s(double kg, int? reps) => LoggedSet(
  id: 'x',
  rowId: 'r',
  exerciseId: 'Bench_Press',
  setNo: 1,
  kg: kg,
  reps: reps,
);

Goal g({
  GoalType type = GoalType.strength,
  double start = 90,
  double target = 100,
  DateTime? deadline,
  DateTime? created,
  bool pinned = false,
  DateTime? achievedAt,
  String id = 'g',
}) => Goal(
  id: id,
  type: type,
  exerciseId: type == GoalType.strength ? 'Bench_Press' : null,
  startValue: start,
  target: target,
  deadline: deadline,
  pinned: pinned,
  createdAt: created ?? DateTime(2026, 11, 1, 9),
  achievedAt: achievedAt,
);

void main() {
  final today = d(24);

  group('GOL-01 histories', () {
    test('edge strength: best e1RM per workout; no-e1RM sets ignored', () {
      final h = strengthHistory([
        (date: d(20), sets: [s(90, 5), s(80, 8)]),
        (date: d(10), sets: [s(60, 15)]),
        (date: d(3), sets: [s(84, 5)]),
      ]);
      expect(
        [for (final m in h) (m.date, m.value)],
        [(d(3), 98), (d(20), 105)],
      );
    });

    test('AC2 weight: every snapshot with a weight, oldest first', () {
      final h = weightHistory([
        BodySnapshot(id: 'b', date: d(20), weightKg: 81),
        BodySnapshot(id: 'n', date: d(15)),
        BodySnapshot(id: 'a', date: d(10), weightKg: 82),
      ]);
      expect([for (final m in h) m.value], [82, 81]);
    });
  });

  group('GOL-01 target rules', () {
    test('AC2 edge strength must go up; weight either way; not equal', () {
      expect(validateTarget(GoalType.strength, 100, 110), isNull);
      expect(
        validateTarget(GoalType.strength, 100, 95),
        TargetProblem.mustBeAbove,
      );
      expect(validateTarget(GoalType.bodyWeight, 80, 75), isNull);
      expect(validateTarget(GoalType.bodyWeight, 80, 85), isNull);
      expect(
        validateTarget(GoalType.bodyWeight, 80, 80),
        TargetProblem.already,
      );
      expect(validateTarget(GoalType.strength, 100, 0), TargetProblem.invalid);
    });
  });

  group('GOL-01 status', () {
    // Rising 1 kg a week over 6 weeks: 94 → 99.
    final rising = [
      for (var w = 0; w < 6; w++)
        Measurement(d(13, 10).add(Duration(days: 7 * w)), 94.0 + w),
    ];

    test('AC4 current, progress clamped 0–100, projection date', () {
      final st = goalStatus(g(start: 90, target: 100), rising, today);
      expect(st.current, 99);
      expect(st.percent, closeTo(90, 0.01));
      expect(st.projection, isA<OnTrack>());
      expect(goalStatus(g(start: 100, target: 110), rising, today).percent, 0);
      expect(goalStatus(g(start: 80, target: 90), rising, today).percent, 100);
    });

    test('AC4 weight going down counts progress downwards', () {
      final st = goalStatus(
        g(type: GoalType.bodyWeight, start: 90, target: 80),
        [Measurement(d(20), 85)],
        today,
      );
      expect(st.percent, 50);
      expect(st.projection, isA<NotEnoughData>());
    });

    test('AC4 no data yet: no current, 0 %', () {
      final st = goalStatus(g(), const [], today);
      expect(st.current, isNull);
      expect(st.percent, 0);
    });

    test('AC5 pace against the deadline, in words', () {
      expect(
        goalStatus(g(deadline: d(1, 12)), rising, today).pace,
        Pace.onPace,
      );
      expect(
        goalStatus(g(target: 110, deadline: d(25)), rising, today).pace,
        Pace.behind,
      );
      expect(
        goalStatus(g(deadline: d(20)), rising, today).pace,
        Pace.deadlinePassed,
      );
      expect(goalStatus(g(), rising, today).pace, isNull);
      final flat = [
        for (var w = 0; w < 4; w++)
          Measurement(d(1).add(Duration(days: 7 * w)), 95),
      ];
      expect(goalStatus(g(deadline: d(1, 12)), flat, today).pace, Pace.behind);
      expect(goalStatus(g(deadline: d(1, 12)), const [], today).pace, isNull);
      expect(
        goalStatus(g(deadline: d(20), achievedAt: d(15)), rising, today).pace,
        isNull,
      );
    });
  });

  group('GOL-01 reaching the target', () {
    test('AC6 the first point on or after creation that reaches it', () {
      final h = [
        Measurement(d(20, 10), 101),
        Measurement(d(5), 99),
        Measurement(d(12), 100),
        Measurement(d(19), 102),
      ]..sort((a, b) => a.date.compareTo(b.date));
      expect(reachedOn(g(), h), d(12));
      expect(reachedOn(g(target: 110), h), isNull);
    });

    test('AC6 a weight goal going down', () {
      final goal = g(type: GoalType.bodyWeight, start: 85, target: 80);
      expect(reachedOn(goal, [Measurement(d(10), 79.5)]), d(10));
      expect(reachedOn(goal, [Measurement(d(10), 80.5)]), isNull);
    });

    test('edge a point earlier on the day of creation counts', () {
      expect(
        reachedOn(g(created: DateTime(2026, 11, 12, 18)), [
          Measurement(d(12), 100),
        ]),
        d(12),
      );
    });
  });

  group('GOL-01 home goal', () {
    test('AC10 pinned active, else newest active, else none', () {
      final a = g(id: 'a', created: d(1));
      final b = g(id: 'b', created: d(5));
      final done = g(id: 'c', created: d(9), achievedAt: d(10));
      expect(homeGoal([b, a.copyWith(pinned: true), done])?.id, 'a');
      expect(homeGoal([a, b, done])?.id, 'b');
      expect(homeGoal([done]), isNull);
    });
  });

  group('GOL-01 review fixes', () {
    test('AC8 an edit keeps the direction and stays unreached', () {
      // Losing weight: start 84, now 82.
      expect(
        validateTarget(GoalType.bodyWeight, 82, 86, rising: false),
        TargetProblem.mustBeBelow,
      );
      expect(
        validateTarget(GoalType.bodyWeight, 82, 83, rising: false),
        TargetProblem.mustBeBelow,
      );
      expect(
        validateTarget(GoalType.bodyWeight, 82, 79, rising: false),
        isNull,
      );
      expect(
        validateTarget(GoalType.bodyWeight, 82, 80, rising: true),
        TargetProblem.mustBeAbove,
      );
    });
  });
}
