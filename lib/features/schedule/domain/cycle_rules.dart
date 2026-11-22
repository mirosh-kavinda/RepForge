import 'package:characters/characters.dart';

import '../../../core/ids.dart';
import 'cycle.dart';

abstract final class CycleLimits {
  static const maxDays = 14;
  static const nameMax = 40;
  static const previewDays = 8;
}

enum SaveProblem { name, noDays, noTraining }

SaveProblem? saveProblem(String name, List<CycleDay> days) {
  // Counted as the text field counts: user-visible characters.
  final n = name.trim().characters.length;
  if (n == 0 || n > CycleLimits.nameMax) return SaveProblem.name;
  if (days.isEmpty) return SaveProblem.noDays;
  if (days.every((d) => d.isRest)) return SaveProblem.noTraining;
  return null;
}

bool canAddDay(List<CycleDay> days) => days.length < CycleLimits.maxDays;

({int train, int rest}) dayCounts(List<CycleDay> days) {
  final rest = days.where((d) => d.isRest).length;
  return (train: days.length - rest, rest: rest);
}

List<CycleDay> addDay(List<CycleDay> days, {String? workoutId}) =>
    canAddDay(days)
    ? [...days, CycleDay(id: newId(), workoutId: workoutId)]
    : days;

List<CycleDay> setWorkout(List<CycleDay> days, int index, String? workoutId) =>
    [...days]..[index] = days[index].copyWith(workoutId: workoutId);

List<CycleDay> removeDay(List<CycleDay> days, int index) =>
    [...days]..removeAt(index);

// `to` is the row's final index.
List<CycleDay> moveDay(List<CycleDay> days, int from, int to) {
  if (from == to || to < 0 || to >= days.length) return days;
  final next = [...days];
  next.insert(to, next.removeAt(from));
  return next;
}

// Calendar days as UTC midnights: counting between them ignores DST and
// time-zone changes (edge).
DateTime calendarDay(DateTime local) =>
    DateTime.utc(local.year, local.month, local.day);

// SCH-01 AC8, SCH-02 AC12: after editing the active cycle, today stays on the
// same row if it survived, else on whatever row now holds that position.
// [todayIndex] is where the cycle has rolled to today.
({DateTime startDate, int startDayIndex}) reanchor(
  Cycle old,
  List<CycleDay> newDays,
  int todayIndex,
  DateTime today,
) {
  final rowId = old.days[todayIndex].id;
  final kept = newDays.indexWhere((d) => d.id == rowId);
  final index = kept >= 0
      ? kept
      : todayIndex.clamp(0, newDays.length - 1).toInt();
  return (startDate: calendarDay(today), startDayIndex: index);
}

// The next [count] dates from today with each date's day index (AC4).
List<({DateTime date, int dayIndex})> preview(
  int length,
  int todayIndex,
  DateTime today, {
  int count = CycleLimits.previewDays,
}) => [
  for (var i = 0; i < count; i++)
    (
      date: calendarDay(today).add(Duration(days: i)),
      dayIndex: (todayIndex + i) % length,
    ),
];
