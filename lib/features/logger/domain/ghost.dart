import 'dart:math' as math;

import '../../../core/metrics/strength.dart' as m;
import '../../../core/metrics/units.dart';
import '../../workout/domain/workout_template.dart';
import 'logger_rules.dart';
import 'workout_session.dart';

const _secondsStep = 5;

double _plusStep(double kg, UnitSystem units) => switch (units) {
  UnitSystem.metric => kg + weightStep(units),
  // Rounded to the stepper's 5 lb step (edge).
  UnitSystem.imperial => lbToKg(
    ((kgToLb(kg) + weightStep(units)) / weightStep(units)).round() *
        weightStep(units),
  ),
};

// LOG-02 AC2–AC4: the suggested target per set number that [last] (last
// session's sets of this row, by set number) had. Today's range is used.
Map<int, SetValues> targets(
  SessionExercise row,
  Map<int, LoggedSet> last,
  UnitSystem units,
) {
  if (last.isEmpty) return const {};
  if (row.kind == TargetKind.time) {
    return {
      for (final MapEntry(key: n, value: s) in last.entries)
        n: () {
          final secs = s.seconds ?? row.seconds;
          return (
            kg: s.kg,
            reps: null,
            seconds: secs >= row.seconds ? secs + _secondsStep : secs,
          );
        }(),
    };
  }
  final allTop = last.values.every((s) => (s.reps ?? 0) >= row.repMax);
  return {
    for (final MapEntry(key: n, value: s) in last.entries)
      n: switch (s) {
        _ when row.bodyweight && s.kg == 0 => (
          kg: 0.0,
          reps: (s.reps ?? 0) + 1,
          seconds: null,
        ),
        _ when allTop => (
          kg: _plusStep(s.kg, units),
          reps: row.repMin,
          seconds: null,
        ),
        _ => (
          kg: s.kg,
          reps: math.min((s.reps ?? 0) + 1, row.repMax),
          seconds: null,
        ),
      },
  };
}

double? _e1rm(LoggedSet s) =>
    s.reps == null ? null : m.e1rm(m.LoggedSet(kg: s.kg, reps: s.reps!));

// More reps (or seconds) than ever at this weight or heavier.
bool _countPr(LoggedSet s, List<LoggedSet> before) {
  final timed = s.seconds != null;
  final mine = (timed ? s.seconds : s.reps) ?? 0;
  var best = 0;
  for (final b in before) {
    if (b.kg < s.kg) continue;
    final v = (timed ? b.seconds : b.reps) ?? 0;
    if (v > best) best = v;
  }
  return mine > best;
}

// LOG-02 AC6, AC7: ids of the PR sets among [sets] (this workout's sets of one
// exercise, in logged order) against [history] (its finished sets). The first
// time an exercise is done has nothing to beat.
Set<String> prSets(List<LoggedSet> sets, List<LoggedSet> history) {
  if (history.isEmpty) return const {};
  final seen = [...history];
  final out = <String>{};
  for (final s in sets) {
    final mine = _e1rm(s);
    final best = m.bestE1rm([
      for (final b in seen)
        if (b.reps != null) m.LoggedSet(kg: b.kg, reps: b.reps!),
    ]);
    final pr = mine != null && best != null ? mine > best : _countPr(s, seen);
    if (pr) out.add(s.id);
    seen.add(s);
  }
  return out;
}
