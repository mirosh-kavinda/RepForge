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
    // SCH-04: today's record when it is on today's row (a swap, skip, rest,
    // move or done), for the card to show and undo.
    DayRecord? record,
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
// SCH-04: skipped (and moved) move on too; unplanned rest waits without
// counting as missed.
// SCH-03 Weekdays never waits: every date is its weekday's row.
_Walk _walk(Cycle c, Iterable<DayRecord> records, DateTime today) {
  final n = c.days.length;
  final byDate = {
    for (final r in records)
      if (r.cycleId == c.id && !r.date.isBefore(c.startDate)) r.date: r,
  };
  if (c.mode == CycleMode.weekdays) {
    return (
      index: weekdayRow(today),
      missedDays: 0,
      byDate: byDate,
      passed: [
        for (
          var date = c.startDate;
          date.isBefore(today);
          date = date.add(const Duration(days: 1))
        )
          (date: date, index: weekdayRow(date)),
      ],
    );
  }
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
    final status = r?.dayId == row.id ? r?.status : null;
    if (row.isRest ||
        status == DayStatus.done ||
        status == DayStatus.skipped ||
        status == DayStatus.moved) {
      index = (index + 1) % n;
      missed = 0;
    } else if (status != DayStatus.unplannedRest) {
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
  final onRow = r?.dayId == c.days[w.index].id ? r : null;
  final behind = latestSeen != null && today.isBefore(calendarDay(latestSeen));
  return CycleToday(
    index: w.index,
    doneToday: onRow?.status == DayStatus.done,
    missedDays: w.missedDays,
    next: (w.index + 1) % c.days.length,
    readOnly:
        behind || r?.status == DayStatus.missed || r?.status == DayStatus.rest,
    record: onRow,
  );
}

// Passed dates with no record get missed or rest for the row the walk was on,
// so history exists for later slices (AC6, AC7). A passed planned record
// (SCH-04) is replaced: missed, or rest for an unused Train today. Nothing
// else is returned, so re-running is harmless.
List<DayRecord> toSettle(
  Cycle c,
  Iterable<DayRecord> records,
  DateTime now, {
  String Function() id = newId,
}) {
  final w = _walk(c, records, calendarDay(now));
  return [
    for (final p in w.passed)
      if (w.byDate[p.date] case final r?)
        if (r.status == DayStatus.planned)
          r.copyWith(
            status: r.linkedDate == null && c.days[p.index].isRest
                ? DayStatus.rest
                : DayStatus.missed,
          )
        else
          ...[]
      else
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
