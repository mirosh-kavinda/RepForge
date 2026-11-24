import '../../schedule/domain/calendar.dart';
import '../../schedule/domain/cycle.dart';
import '../../schedule/domain/day_record.dart';
import '../../schedule/domain/rolling.dart';

typedef ReminderDay = ({DateTime date, String workoutId});

const reminderWindow = 14;

// SET-01 AC8, edges: the coming [reminderWindow] dates (today first) whose
// plan is a workout, as the SCH-05 calendar plans them. Rest days, and today
// once done, skipped, moved or rested, are left out. No cycle, no days.
List<ReminderDay> reminderDays({
  required Cycle? active,
  required CycleToday? rolled,
  required List<DayRecord> records,
  required DateTime today,
}) {
  if (active == null || rolled == null) return const [];
  final last = today.add(const Duration(days: reminderWindow - 1));
  final months = {
    DateTime.utc(today.year, today.month),
    DateTime.utc(last.year, last.month),
  };
  final out = <ReminderDay>[];
  for (final month in months) {
    for (final day in buildMonth(
      month: month,
      firstDay: 1,
      today: today,
      records: records,
      active: active,
      rolled: rolled,
      cycles: {active.id: active},
    )) {
      if (!day.inMonth || day.date.isBefore(today) || day.date.isAfter(last)) {
        continue;
      }
      if (day.kind == CalendarKind.planned && day.workoutId != null) {
        out.add((date: day.date, workoutId: day.workoutId!));
      }
    }
  }
  return out;
}
