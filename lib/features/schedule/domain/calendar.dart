import 'package:freezed_annotation/freezed_annotation.dart';

import 'cycle.dart';
import 'cycle_rules.dart';
import 'day_record.dart';
import 'rolling.dart';

part 'calendar.freezed.dart';

// SCH-05. history: what happened (past, or today's action); planned: what
// today or a coming date is meant to be.
enum CalendarKind { empty, history, planned }

@freezed
abstract class CalendarDay with _$CalendarDay {
  const factory CalendarDay({
    required DateTime date,
    required bool inMonth,
    required bool isToday,
    required CalendarKind kind,
    DayStatus? status,
    // The workout the date is about; null is rest (or unknown).
    String? workoutId,
    // The cycle row's own workout when [workoutId] differs (a swap).
    String? plannedWorkoutId,
    // The record shown, and every record on the date (edge: two cycles).
    DayRecord? record,
    @Default(<DayRecord>[]) List<DayRecord> records,
  }) = _CalendarDay;
}

// AC2: whole weeks starting on [firstDay] (0 = Sunday) around [month].
List<DateTime> monthDates(DateTime month, int firstDay) {
  final first = DateTime.utc(month.year, month.month);
  final last = DateTime.utc(month.year, month.month + 1, 0);
  final start = first.subtract(
    Duration(days: (first.weekday % 7 - firstDay + 7) % 7),
  );
  final end = last.add(Duration(days: (firstDay + 6 - last.weekday % 7) % 7));
  return [
    for (
      var d = start;
      !d.isAfter(end);
      d = DateTime.utc(d.year, d.month, d.day + 1)
    )
      d,
  ];
}

// [records] are every cycle's records over the grid, by date then last update.
List<CalendarDay> buildMonth({
  required DateTime month,
  required int firstDay,
  required DateTime today,
  required List<DayRecord> records,
  required Cycle? active,
  required CycleToday? rolled,
  required Map<String, Cycle> cycles,
}) {
  final byDate = <DateTime, List<DayRecord>>{};
  for (final r in records) {
    (byDate[r.date] ??= []).add(r);
  }
  String? rowWorkout(DayRecord r) {
    final rows = cycles[r.cycleId]?.days ?? const <CycleDay>[];
    for (final d in rows) {
      if (d.id == r.dayId) return d.workoutId;
    }
    return null;
  }

  CalendarDay history(CalendarDay base, DayRecord r) {
    final row = rowWorkout(r);
    return base.copyWith(
      kind: CalendarKind.history,
      status: r.status,
      workoutId: r.workoutId ?? row,
      plannedWorkoutId: r.workoutId != null && r.workoutId != row ? row : null,
      record: r,
    );
  }

  return [
    for (final date in monthDates(month, firstDay))
      () {
        final recs = byDate[date] ?? const <DayRecord>[];
        final mine = recs.where((r) => r.cycleId == active?.id);
        final shown = mine.isNotEmpty
            ? mine.last
            : (recs.isEmpty ? null : recs.last);
        final base = CalendarDay(
          date: date,
          inMonth: date.month == month.month,
          isToday: date == today,
          kind: CalendarKind.empty,
          records: recs,
        );
        if (date.isBefore(today) || active == null || rolled == null) {
          if (date.isAfter(today) && active == null) return base;
          return shown == null ? base : history(base, shown);
        }
        return _plan(base, date, today, active, rolled, mine, history);
      }(),
  ];
}

CalendarDay _plan(
  CalendarDay base,
  DateTime date,
  DateTime today,
  Cycle c,
  CycleToday rolled,
  Iterable<DayRecord> mine,
  CalendarDay Function(CalendarDay, DayRecord) history,
) {
  final n = c.days.length;
  DayRecord? r;
  int index;
  if (date == today) {
    r = rolled.record;
    index = rolled.index;
  } else {
    final moved = mine.where(
      (x) => x.status == DayStatus.planned && x.linkedDate != null,
    );
    r = moved.isEmpty ? null : moved.last;
    if (c.mode == CycleMode.weekdays) {
      index = weekdayRow(date);
    } else {
      var k = date.difference(today).inDays;
      // An unplanned rest today keeps the same workout for tomorrow (SCH-04).
      if (rolled.record?.status == DayStatus.unplannedRest) k--;
      index = (rolled.index + k) % n;
    }
  }
  final row = c.days[index].workoutId;
  if (r != null && r.status != DayStatus.planned) return history(base, r);
  return base.copyWith(
    kind: CalendarKind.planned,
    status: r?.status,
    workoutId: r?.workoutId ?? row,
    plannedWorkoutId: r?.workoutId != null && r!.workoutId != row ? row : null,
    record: r,
  );
}
