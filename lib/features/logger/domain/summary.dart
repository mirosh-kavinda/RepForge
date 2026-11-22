import '../../../core/metrics/strength.dart' as metrics;
import '../../workout/domain/workout_template.dart';
import 'workout_session.dart';

// What an exercise is measured by on the summary (AC3).
enum Measure { volume, reps, time }

class ExerciseSummary {
  const ExerciseSummary({
    required this.row,
    required this.sets,
    required this.measure,
    required this.amount,
    this.change,
  });

  final SessionExercise row;
  final List<LoggedSet> sets;
  final Measure measure;
  // kg × reps, total reps or total seconds, by [measure].
  final num amount;
  // Against the last time this exercise was done; null when never (AC5).
  final num? change;
}

class PrLine {
  const PrLine(this.row, this.set);

  final SessionExercise row;
  final LoggedSet set;
}

class WorkoutSummary {
  const WorkoutSummary({
    required this.session,
    required this.duration,
    required this.setCount,
    required this.volumeKg,
    required this.exercises,
    required this.prs,
    required this.hasPrevious,
    this.durationChange,
    this.setChange,
    this.volumeChange,
  });

  final WorkoutSession session;
  final Duration duration;
  final int setCount;
  // Null when no weighted set was logged (edge).
  final double? volumeKg;
  final List<ExerciseSummary> exercises;
  final List<PrLine> prs;
  final bool hasPrevious;
  final Duration? durationChange;
  final int? setChange;
  final double? volumeChange;
}

Iterable<metrics.LoggedSet> _working(Iterable<LoggedSet> sets) => [
  for (final s in sets)
    if (s.reps case final r?) metrics.LoggedSet(kg: s.kg, reps: r),
];

double? _volume(Iterable<LoggedSet> sets) {
  final w = _working(sets);
  return w.any((s) => s.isWorking) ? metrics.volume(w) : null;
}

Measure _measure(SessionExercise row, List<LoggedSet> sets) {
  if (row.kind == TargetKind.time) return Measure.time;
  return _volume(sets) == null ? Measure.reps : Measure.volume;
}

num _amount(Measure m, Iterable<LoggedSet> sets) => switch (m) {
  Measure.volume => _volume(sets) ?? 0,
  Measure.reps => sets.fold<int>(0, (n, s) => n + (s.reps ?? 0)),
  Measure.time => sets.fold<int>(0, (n, s) => n + (s.seconds ?? 0)),
};

Duration _duration(WorkoutSession s) =>
    (s.endedAt ?? s.startedAt).difference(s.startedAt);

// AC2–AC5: [previous] is the last finished workout of the same template;
// [lastByExercise] each exercise's sets from the last time it was done.
WorkoutSummary buildSummary(
  WorkoutSession s, {
  WorkoutSession? previous,
  Map<String, List<LoggedSet>> lastByExercise = const {},
}) {
  final exercises = <ExerciseSummary>[];
  final prs = <PrLine>[];
  for (final row in s.exercises) {
    final sets = s.setsOf(row.id);
    if (sets.isEmpty) continue;
    final m = _measure(row, sets);
    final amount = _amount(m, sets);
    final last = lastByExercise[row.exerciseId];
    exercises.add(
      ExerciseSummary(
        row: row,
        sets: sets,
        measure: m,
        amount: amount,
        // N/A when last time was measured differently (all 0 kg, say).
        change: last == null || last.isEmpty || _measure(row, last) != m
            ? null
            : amount - _amount(m, last),
      ),
    );
    prs.addAll([
      for (final x in sets)
        if (x.isPr) PrLine(row, x),
    ]);
  }
  final volume = _volume(s.sets);
  final prevVolume = previous == null ? null : _volume(previous.sets);
  return WorkoutSummary(
    session: s,
    duration: _duration(s),
    setCount: s.sets.length,
    volumeKg: volume,
    exercises: exercises,
    prs: prs,
    hasPrevious: previous != null,
    durationChange: previous == null
        ? null
        : _duration(s) - _duration(previous),
    setChange: previous == null ? null : s.sets.length - previous.sets.length,
    volumeChange: volume == null || prevVolume == null
        ? null
        : volume - prevVolume,
  );
}
