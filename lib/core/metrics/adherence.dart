import 'estimate.dart';

// One schedule day. `pending` is a training day not finished yet (today);
// `unplannedRest` is a training day turned into rest (SCH-04).
enum DayStatus { pending, done, rest, missed, skipped, moved, unplannedRest }

// Done and planned training days. Skipping a workout counts as planned; rest,
// unplanned rest, moved and pending days do not count.
({int done, int planned}) trainingDays(Iterable<DayStatus> days) {
  var done = 0;
  var planned = 0;
  for (final day in days) {
    switch (day) {
      case DayStatus.done:
        done++;
        planned++;
      case DayStatus.missed || DayStatus.skipped:
        planned++;
      case DayStatus.rest ||
          DayStatus.moved ||
          DayStatus.pending ||
          DayStatus.unplannedRest:
        break;
    }
  }
  return (done: done, planned: planned);
}

// Done ÷ planned training days, as a percentage (AC8).
Estimate<double> adherence(Iterable<DayStatus> days) {
  final t = trainingDays(days);
  if (t.planned == 0) return const NotEstimable(EstimateReason.notEnoughData);
  return Estimated(t.done * 100 / t.planned);
}

// Days oldest first, ending today. Done and rest extend the streak; skipped,
// unplanned rest and moved are neutral; a missed training day ends it; today
// pending is neutral too, so an unfinished today never breaks it (AC8).
int cycleStreak(List<DayStatus> daysOldestFirst) {
  var streak = 0;
  for (final day in daysOldestFirst.reversed) {
    switch (day) {
      case DayStatus.done || DayStatus.rest:
        streak++;
      case DayStatus.missed:
        return streak;
      case DayStatus.skipped ||
          DayStatus.moved ||
          DayStatus.pending ||
          DayStatus.unplannedRest:
        break;
    }
  }
  return streak;
}

// PRG-02 AC4: the longest run anywhere in [daysOldestFirst], by the rules of
// [cycleStreak].
int bestCycleStreak(List<DayStatus> daysOldestFirst) {
  var best = 0;
  var run = 0;
  for (final day in daysOldestFirst) {
    switch (day) {
      case DayStatus.done || DayStatus.rest:
        run++;
        if (run > best) best = run;
      case DayStatus.missed:
        run = 0;
      case DayStatus.skipped ||
          DayStatus.moved ||
          DayStatus.pending ||
          DayStatus.unplannedRest:
        break;
    }
  }
  return best;
}
