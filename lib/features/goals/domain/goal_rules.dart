import '../../../core/metrics/projection.dart';
import '../../../core/metrics/strength.dart' as metrics;
import '../../body/domain/body_snapshot.dart';
import '../../logger/domain/session_repository.dart';
import 'goal.dart';

// Edge: one point per finished workout, its best estimated 1RM; sets that
// give none (> 12 reps, no weight) are left out. Oldest first.
List<Measurement> strengthHistory(List<ExerciseLogEntry> log) => [
  for (final e in [...log]..sort((a, b) => a.date.compareTo(b.date)))
    if (metrics.bestE1rm([
          for (final x in e.sets)
            if (x.reps case final r?) metrics.LoggedSet(kg: x.kg, reps: r),
        ])
        case final v?)
      Measurement(e.date, v),
];

// AC2: every snapshot with a weight (the onboarding one too), oldest first.
List<Measurement> weightHistory(List<BodySnapshot> snapshots) => [
  for (final x in [...snapshots]..sort((a, b) => a.date.compareTo(b.date)))
    if (x.weightKg case final w?) Measurement(x.date, w),
];

enum TargetProblem { invalid, already, mustBeAbove, mustBeBelow }

// AC2, edges. [rising] is an edited goal's direction (AC8): its target must
// stay on that side of the current value, so an edit neither flips the goal
// nor lands where it is already reached. Compare values at display precision.
TargetProblem? validateTarget(
  GoalType type,
  double current,
  double target, {
  bool? rising,
}) {
  if (!target.isFinite || target <= 0) return TargetProblem.invalid;
  if (target == current) return TargetProblem.already;
  final up = rising ?? (type == GoalType.strength ? true : null);
  if (up == true && target < current) return TargetProblem.mustBeAbove;
  if (up == false && target > current) return TargetProblem.mustBeBelow;
  return null;
}

enum Pace { onPace, behind, deadlinePassed }

class GoalStatus {
  const GoalStatus({
    required this.current,
    required this.percent,
    required this.projection,
    required this.pace,
  });

  // Null with no data yet.
  final double? current;
  // 0–100 from the start value to the target (AC4).
  final double percent;
  final Projection projection;
  // Null without a deadline, once achieved, or with too little data (AC5).
  final Pace? pace;
}

// [history] oldest first.
GoalStatus goalStatus(Goal g, List<Measurement> history, DateTime today) {
  final current = history.lastOrNull?.value;
  final span = g.target - g.startValue;
  final percent = current == null || span == 0
      ? 0.0
      : ((current - g.startValue) / span * 100).clamp(0.0, 100.0);
  final projection = projectGoal(
    history: history,
    target: g.target,
    today: today,
  );
  final deadline = g.deadline;
  final Pace? pace;
  if (deadline == null || !g.isActive) {
    pace = null;
  } else if (today.isAfter(deadline)) {
    pace = Pace.deadlinePassed;
  } else {
    pace = switch (projection) {
      OnTrack(:final date) =>
        date.isAfter(deadline) ? Pace.behind : Pace.onPace,
      NotOnTrack() => Pace.behind,
      NotEnoughData() => null,
    };
  }
  return GoalStatus(
    current: current,
    percent: percent,
    projection: projection,
    pace: pace,
  );
}

// AC6: the date of the first point, from the day the goal was made, that
// reaches the target in its direction.
DateTime? reachedOn(Goal g, List<Measurement> history) {
  final c = g.createdAt;
  final from = DateTime.utc(c.year, c.month, c.day);
  for (final m in history) {
    if (m.date.isBefore(from)) continue;
    if (g.rising ? m.value >= g.target : m.value <= g.target) return m.date;
  }
  return null;
}

// AC10: the pinned active goal, else the newest active one.
Goal? homeGoal(List<Goal> goals) {
  final active = [
    for (final g in goals)
      if (g.isActive) g,
  ];
  return active.where((g) => g.pinned).firstOrNull ??
      active.fold<Goal?>(
        null,
        (best, g) =>
            best == null || g.createdAt.isAfter(best.createdAt) ? g : best,
      );
}
