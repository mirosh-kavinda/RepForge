import '../../../core/metrics/adherence.dart' as m;
import '../../../core/metrics/estimate.dart';
import '../../schedule/domain/cycle.dart';
import '../../schedule/domain/day_record.dart';
import 'progress_rules.dart';

// One date's status for the metrics; [workoutId] is the planned workout.
typedef DatedStatus = ({DateTime date, m.DayStatus status, String? workoutId});

// Today's row of the active cycle, when there is one.
typedef TodayRow = ({bool isRest, String? workoutId});

m.DayStatus _map(DayStatus s) => switch (s) {
  DayStatus.done => m.DayStatus.done,
  DayStatus.missed => m.DayStatus.missed,
  DayStatus.rest => m.DayStatus.rest,
  DayStatus.skipped => m.DayStatus.skipped,
  DayStatus.moved => m.DayStatus.moved,
  DayStatus.unplannedRest => m.DayStatus.unplannedRest,
  DayStatus.planned => m.DayStatus.pending,
};

// [records] from every cycle, by date then last update. One status per date
// up to today, oldest first; dates with no record are absent, so they neither
// count nor break a streak (edges). On a date with two cycles' records the
// active one wins, else the latest, as on the SCH-05 calendar.
List<DatedStatus> dayHistory({
  required List<DayRecord> records,
  required String? activeCycleId,
  required Map<String, Cycle> cycles,
  required DateTime today,
  required TodayRow? todayRow,
}) {
  final byDate = <DateTime, DayRecord>{};
  for (final r in records) {
    if (r.date.isAfter(today)) continue;
    final had = byDate[r.date];
    if (had == null ||
        r.cycleId == activeCycleId ||
        had.cycleId != activeCycleId) {
      byDate[r.date] = r;
    }
  }
  String? rowWorkout(DayRecord r) => cycles[r.cycleId]?.days
      .where((d) => d.id == r.dayId)
      .firstOrNull
      ?.workoutId;

  final dates = byDate.keys.toList()..sort();
  return [
    for (final date in dates)
      (
        date: date,
        status: _map(byDate[date]!.status),
        workoutId: byDate[date]!.workoutId ?? rowWorkout(byDate[date]!),
      ),
    if (!byDate.containsKey(today) && todayRow != null)
      (
        date: today,
        status: todayRow.isRest ? m.DayStatus.rest : m.DayStatus.pending,
        workoutId: todayRow.workoutId,
      ),
  ];
}

class WeekAdherence {
  const WeekAdherence(this.week, this.percent);

  final DateTime week;
  // Null: no training planned that week (AC5).
  final double? percent;
}

typedef MissedDay = ({DateTime date, bool skipped, String? workoutId});

class AdherenceSummary {
  const AdherenceSummary({
    required this.percent,
    required this.done,
    required this.planned,
    required this.streak,
    required this.bestStreak,
    required this.weeks,
    required this.missed,
  });

  final Estimate<double> percent;
  final int done;
  final int planned;
  final int streak;
  final int bestStreak;
  final List<WeekAdherence> weeks;
  // Newest first.
  final List<MissedDay> missed;
}

// [history] oldest first, as [dayHistory] gives it; [from] null is all time.
AdherenceSummary adherenceSummary(
  List<DatedStatus> history, {
  required DateTime? from,
  required DateTime today,
}) {
  final all = [for (final x in history) x.status];
  final inRange = [
    for (final x in history)
      if (from == null || !x.date.isBefore(from)) x,
  ];
  final statuses = [for (final x in inRange) x.status];
  final counts = m.trainingDays(statuses);

  final weeks = <WeekAdherence>[];
  // Edge: no weeks before the first cycle's first day.
  final first = inRange.firstOrNull?.date;
  final start = from == null || (first != null && first.isAfter(from))
      ? first
      : from;
  if (counts.planned > 0 && start != null) {
    final byWeek = <DateTime, List<m.DayStatus>>{};
    for (final x in inRange) {
      (byWeek[weekStart(x.date)] ??= []).add(x.status);
    }
    for (
      var w = weekStart(start);
      !w.isAfter(today);
      w = DateTime.utc(w.year, w.month, w.day + 7)
    ) {
      weeks.add(
        WeekAdherence(w, m.adherence(byWeek[w] ?? const []).valueOrNull),
      );
    }
  }

  return AdherenceSummary(
    percent: m.adherence(statuses),
    done: counts.done,
    planned: counts.planned,
    streak: m.cycleStreak(all),
    bestStreak: m.bestCycleStreak(all),
    weeks: weeks,
    missed: [
      for (final x in inRange.reversed)
        if (x.status == m.DayStatus.missed || x.status == m.DayStatus.skipped)
          (
            date: x.date,
            skipped: x.status == m.DayStatus.skipped,
            workoutId: x.workoutId,
          ),
    ],
  );
}
