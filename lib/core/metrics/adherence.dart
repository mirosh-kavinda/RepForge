import 'estimate.dart';

// One schedule day. `pending` is a training day not finished yet (today).
enum DayStatus { pending, done, rest, missed, skipped, moved }

// Done ÷ planned training days, as a percentage (AC8). Skipping a workout
// counts against adherence; rest, moved and pending days do not count.
Estimate<double> adherence(Iterable<DayStatus> days) {
  var done = 0;
  var planned = 0;
  for (final day in days) {
    switch (day) {
      case DayStatus.done:
        done++;
        planned++;
      case DayStatus.missed || DayStatus.skipped:
        planned++;
      case DayStatus.rest || DayStatus.moved || DayStatus.pending:
        break;
    }
  }
  if (planned == 0) return const NotEstimable(EstimateReason.notEnoughData);
  return Estimated(done * 100 / planned);
}

// Days oldest first, ending today. Done and rest extend the streak, skipped
// and moved are neutral, a missed training day ends it; today pending is
// neutral too, so an unfinished today never breaks it (AC8).
int cycleStreak(List<DayStatus> daysOldestFirst) {
  var streak = 0;
  for (final day in daysOldestFirst.reversed) {
    switch (day) {
      case DayStatus.done || DayStatus.rest:
        streak++;
      case DayStatus.missed:
        return streak;
      case DayStatus.skipped || DayStatus.moved || DayStatus.pending:
        break;
    }
  }
  return streak;
}
