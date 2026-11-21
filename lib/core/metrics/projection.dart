class Measurement {
  const Measurement(this.date, this.value);

  final DateTime date;
  final double value;
}

sealed class Projection {
  const Projection();
}

final class OnTrack extends Projection {
  const OnTrack(this.date);

  final DateTime date;

  @override
  bool operator ==(Object other) => other is OnTrack && other.date == date;

  @override
  int get hashCode => date.hashCode;

  @override
  String toString() => 'OnTrack($date)';
}

final class NotEnoughData extends Projection {
  const NotEnoughData();
}

final class NotOnTrack extends Projection {
  const NotOnTrack();
}

const projectionWindow = Duration(days: 56);
const projectionMinSpan = Duration(days: 14);
const projectionMinPoints = 3;
const projectionHorizon = Duration(days: 730);
const flatSlopePerDay = 1e-9;

// Least-squares line over the last 8 weeks; the date it meets the target
// (AC9). Works for goals that go up (lifts) or down (weight, waist).
Projection projectGoal({
  required List<Measurement> history,
  required double target,
  required DateTime today,
}) {
  final from = today.subtract(projectionWindow);
  final points =
      history
          .where((m) => !m.date.isBefore(from) && !m.date.isAfter(today))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
  if (points.length < projectionMinPoints ||
      points.last.date.difference(points.first.date) < projectionMinSpan) {
    return const NotEnoughData();
  }

  final rising = target >= points.first.value;
  final latest = points.last.value;
  if (rising ? latest >= target : latest <= target) return OnTrack(today);

  final origin = points.first.date;
  double x(DateTime d) => d.difference(origin).inHours / 24;
  final n = points.length;
  final meanX = points.fold(0.0, (s, p) => s + x(p.date)) / n;
  final meanY = points.fold(0.0, (s, p) => s + p.value) / n;
  var sxy = 0.0;
  var sxx = 0.0;
  for (final p in points) {
    final dx = x(p.date) - meanX;
    sxy += dx * (p.value - meanY);
    sxx += dx * dx;
  }
  final slope = sxy / sxx;
  // Floating-point leftovers make a flat series look minutely sloped; treat
  // that as flat, and check the horizon in days before building a Duration
  // (a near-zero slope would otherwise overflow it).
  if (slope.abs() < flatSlopePerDay || (slope > 0) != rising) {
    return const NotOnTrack();
  }
  final daysFromToday = meanX + (target - meanY) / slope - x(today);
  if (!daysFromToday.isFinite || daysFromToday > projectionHorizon.inDays) {
    return const NotOnTrack();
  }
  if (daysFromToday <= 0) return OnTrack(today);
  return OnTrack(today.add(Duration(hours: (daysFromToday * 24).round())));
}
