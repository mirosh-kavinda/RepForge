import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/ids.dart';
import 'cycle.dart';
import 'cycle_rules.dart';
import 'day_record.dart';

part 'rolling.freezed.dart';

@freezed
abstract class CycleToday with _$CycleToday {
  const factory CycleToday({
    required int index,
    required bool doneToday,
    // Passed dates the current training day has waited (AC8).
    required int missedDays,
    required int next,
    // Mark done / Undo are not offered: the clock is behind a day already
    // seen, or today is already recorded missed / rest (edge: clock back).
    @Default(false) bool readOnly,
  }) = _CycleToday;
}

typedef _Walk = ({
  int index,
  int missedDays,
  Map<DateTime, DayRecord> byDate,
  List<({DateTime date, int index})> passed,
});

// From the anchor to yesterday: a date moves the cycle on if its row is Rest or
// was marked done on that row; otherwise the cycle waits (AC4–AC7).
_Walk _walk(Cycle c, Iterable<DayRecord> records, DateTime today) {
  final n = c.days.length;
  final byDate = {
    for (final r in records)
      if (r.cycleId == c.id && !r.date.isBefore(c.startDate)) r.date: r,
  };
  var index = c.startDayIndex % n;
  var missed = 0;
  final passed = <({DateTime date, int index})>[];
  for (
    var date = c.startDate;
    date.isBefore(today);
    date = date.add(const Duration(days: 1))
  ) {
    passed.add((date: date, index: index));
    final row = c.days[index];
    final r = byDate[date];
    if (row.isRest || (r?.status == DayStatus.done && r?.dayId == row.id)) {
      index = (index + 1) % n;
      missed = 0;
    } else {
      missed++;
    }
  }
  return (index: index, missedDays: missed, byDate: byDate, passed: passed);
}

CycleToday rollForward(
  Cycle c,
  Iterable<DayRecord> records,
  DateTime now, {
  DateTime? latestSeen,
}) {
  final today = calendarDay(now);
  final w = _walk(c, records, today);
  final r = w.byDate[today];
  final behind = latestSeen != null && today.isBefore(calendarDay(latestSeen));
  return CycleToday(
    index: w.index,
    doneToday: r?.status == DayStatus.done && r?.dayId == c.days[w.index].id,
    missedDays: w.missedDays,
    next: (w.index + 1) % c.days.length,
    readOnly: behind || (r != null && r.status != DayStatus.done),
  );
}

// Passed dates with no record get missed or rest for the row the walk was on,
// so history exists for later slices (AC6, AC7). Only missing dates are
// returned, so re-running is harmless.
List<DayRecord> toSettle(
  Cycle c,
  Iterable<DayRecord> records,
  DateTime now, {
  String Function() id = newId,
}) {
  final w = _walk(c, records, calendarDay(now));
  return [
    for (final p in w.passed)
      if (!w.byDate.containsKey(p.date))
        DayRecord(
          id: id(),
          cycleId: c.id,
          date: p.date,
          dayId: c.days[p.index].id,
          dayIndex: p.index,
          status: c.days[p.index].isRest ? DayStatus.rest : DayStatus.missed,
        ),
  ];
}
