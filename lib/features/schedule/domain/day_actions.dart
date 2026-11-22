import 'cycle.dart';
import 'day_record.dart';
import 'rolling.dart';

// SCH-04 screen 17.
enum DayAction { swap, trainToday, skip, unplannedRest, move }

// What today's sheet offers (AC1, AC8). Nothing once something other than a
// swap happened today: the card offers Undo instead (edge).
List<DayAction> availableActions(
  Cycle c,
  CycleToday t, {
  required List<DateTime> moveTargets,
}) {
  final r = t.record;
  if (t.readOnly || t.doneToday) return const [];
  if (r != null && (r.status != DayStatus.planned || r.linkedDate != null)) {
    return const [];
  }
  if (c.days[t.index].isRest) return const [DayAction.trainToday];
  return [
    DayAction.swap,
    DayAction.skip,
    DayAction.unplannedRest,
    if (moveTargets.isNotEmpty) DayAction.move,
  ];
}

// AC7: Weekdays only; the dates after [today] up to the end of the locale's
// week ([firstDay] 0 = Sunday) that have no record yet.
List<DateTime> moveTargets(
  Cycle c,
  Iterable<DayRecord> records,
  DateTime today, {
  required int firstDay,
}) {
  if (c.mode != CycleMode.weekdays) return const [];
  final taken = {
    for (final r in records)
      if (r.cycleId == c.id) r.date,
  };
  final left = (firstDay + 6 - today.weekday % 7) % 7;
  return [
    for (var i = 1; i <= left; i++)
      if (!taken.contains(today.add(Duration(days: i))))
        today.add(Duration(days: i)),
  ];
}

// The workout today is about: a swap, Train today or moved-in workout, else the
// row's own (null on a plain rest day).
String? todayWorkoutId(Cycle c, CycleToday t) =>
    t.record?.workoutId ?? c.days[t.index].workoutId;
