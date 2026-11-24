import '../../../core/metrics/strength.dart' as metrics;
import '../../body/domain/body_snapshot.dart';
import '../../logger/domain/session_repository.dart';
import '../../logger/domain/workout_session.dart';

// AC1: counted back from today; null days = everything.
enum ProgressRange {
  weeks4(28),
  months3(91),
  year1(365),
  all(null);

  const ProgressRange(this.days);
  final int? days;
}

// [today] is the phone's calendar day as UTC midnight, like stored dates.
DateTime? rangeStart(ProgressRange r, DateTime today) =>
    r.days == null ? null : today.subtract(Duration(days: r.days! - 1));

bool _inRange(DateTime d, DateTime? from) => from == null || !d.isBefore(from);

class ChartPoint {
  const ChartPoint(this.date, this.value);

  final DateTime date;
  final double value;

  @override
  bool operator ==(Object other) =>
      other is ChartPoint && other.date == date && other.value == value;

  @override
  int get hashCode => Object.hash(date, value);

  @override
  String toString() => 'ChartPoint($date, $value)';
}

// AC5: a line needs two points.
bool enoughForLine(List<ChartPoint> points) => points.length >= 2;

double? changeOf(List<ChartPoint> points) =>
    points.length < 2 ? null : points.last.value - points.first.value;

// Edges: e1RM when any set gives one; else best reps; else best seconds.
enum StrengthMeasure { e1rm, reps, seconds }

class StrengthSeries {
  const StrengthSeries({
    required this.measure,
    required this.points,
    this.bestSet,
  });

  final StrengthMeasure measure;
  // Oldest first, one per workout.
  final List<ChartPoint> points;
  final LoggedSet? bestSet;

  double? get best => points.isEmpty
      ? null
      : points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
  double? get change => changeOf(points);
}

double? _e1rm(Iterable<LoggedSet> sets) => metrics.bestE1rm([
  for (final s in sets)
    if (s.reps case final r?) metrics.LoggedSet(kg: s.kg, reps: r),
]);

// AC2: one point per finished workout in the range.
StrengthSeries strengthSeries(List<ExerciseLogEntry> entries, DateTime? from) {
  final inRange = [
    for (final e in entries)
      if (_inRange(e.date, from)) e,
  ]..sort((a, b) => a.date.compareTo(b.date));
  final all = [for (final e in inRange) ...e.sets];

  final measure = all.any((s) => _e1rm([s]) != null)
      ? StrengthMeasure.e1rm
      : all.any((s) => s.reps != null)
      ? StrengthMeasure.reps
      : StrengthMeasure.seconds;

  double? valueOf(List<LoggedSet> sets) => switch (measure) {
    StrengthMeasure.e1rm => _e1rm(sets),
    StrengthMeasure.reps =>
      sets
          .map((s) => (s.reps ?? 0).toDouble())
          .fold<double?>(null, (m, v) => m == null || v > m ? v : m),
    StrengthMeasure.seconds =>
      sets
          .map((s) => (s.seconds ?? 0).toDouble())
          .fold<double?>(null, (m, v) => m == null || v > m ? v : m),
  };

  LoggedSet? bestSet;
  for (final s in all) {
    final b = bestSet;
    final better = switch (measure) {
      StrengthMeasure.e1rm =>
        b == null ||
            s.kg > b.kg ||
            (s.kg == b.kg && (s.reps ?? 0) > (b.reps ?? 0)),
      StrengthMeasure.reps => b == null || (s.reps ?? 0) > (b.reps ?? 0),
      StrengthMeasure.seconds =>
        b == null || (s.seconds ?? 0) > (b.seconds ?? 0),
    };
    if (better) bestSet = s;
  }

  return StrengthSeries(
    measure: measure,
    points: [
      for (final e in inRange)
        if (valueOf(e.sets) case final v?) ChartPoint(e.date, v),
    ],
    bestSet: bestSet,
  );
}

// Monday of [d]'s week.
DateTime weekStart(DateTime d) =>
    DateTime.utc(d.year, d.month, d.day - (d.weekday - DateTime.monday));

typedef DatedSet = ({DateTime date, LoggedSet set});

// AC3, edge: every week in the range, empty ones as 0.
List<ChartPoint> weeklyVolume(
  List<DatedSet> sets,
  DateTime? from,
  DateTime today,
) {
  final kept = [
    for (final x in sets)
      if (_inRange(x.date, from)) x,
  ];
  final start =
      from ??
      kept
          .map((x) => x.date)
          .fold<DateTime?>(null, (m, d) => m == null || d.isBefore(m) ? d : m);
  if (start == null) return const [];
  final byWeek = <DateTime, List<metrics.LoggedSet>>{};
  for (final x in kept) {
    if (x.set.reps case final r?) {
      (byWeek[weekStart(x.date)] ??= []).add(
        metrics.LoggedSet(kg: x.set.kg, reps: r),
      );
    }
  }
  return [
    for (
      var w = weekStart(start);
      !w.isAfter(today);
      w = DateTime.utc(w.year, w.month, w.day + 7)
    )
      ChartPoint(w, metrics.volume(byWeek[w] ?? const [])),
  ];
}

class BodyTrends {
  const BodyTrends({required this.weight, required this.bodyFat});

  // Oldest first.
  final List<ChartPoint> weight;
  final List<ChartPoint> bodyFat;
}

// AC4: weight from every snapshot with one; body fat where it was estimable,
// else the scale reading (onboarding snapshots have no results).
BodyTrends bodyTrends(List<BodySnapshot> snapshots, DateTime? from) {
  final kept = [
    for (final s in snapshots)
      if (_inRange(s.date, from)) s,
  ]..sort((a, b) => a.date.compareTo(b.date));
  return BodyTrends(
    weight: [
      for (final s in kept)
        if (s.weightKg case final w?) ChartPoint(s.date, w),
    ],
    bodyFat: [
      for (final s in kept)
        if (s.results?[BodyMetric.bodyFat]?.valueOrNull ?? s.scaleBodyFatPct
            case final f?)
          ChartPoint(s.date, f),
    ],
  );
}
