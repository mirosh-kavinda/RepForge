import 'day_record.dart';

abstract interface class DayRecordRepository {
  // Live records of one cycle on or after [from], oldest first.
  Stream<List<DayRecord>> watchSince(String cycleId, DateTime from);

  // SCH-05: live records of every cycle from [from] to [to] inclusive, by
  // date and then last update.
  Stream<List<DayRecord>> watchRange(DateTime from, DateTime to);

  // Upserts the date's done record; marking again after Undo restores it. A
  // planned workout (SCH-04) is kept; any other record is left as it is
  // (edge: clock moved back). [fromWorkout]: a workout finished for this date
  // (LOG-01) also replaces a missed record, which the settler writes once the
  // date has passed mid-workout.
  Future<void> markDone({
    required String cycleId,
    required DateTime date,
    required String dayId,
    required int dayIndex,
    bool fromWorkout = false,
  });

  // One step back (SCH-04 AC9): done with a planned workout → planned; done,
  // a swap, skipped or unplanned rest → removed; moved → removed with its
  // target. A moved-in plan and missed / rest stay.
  Future<void> undo({required String cycleId, required DateTime date});

  // Writes records for dates that have no live one, or replaces a planned one;
  // others are skipped.
  Future<void> writeSettled(List<DayRecord> records);

  // SCH-04. Each writes only over no record or a swap (re-swap).

  // Swap, or Train today on a rest row (AC2, AC8).
  Future<void> plan({
    required String cycleId,
    required DateTime date,
    required String dayId,
    required int dayIndex,
    required String workoutId,
  });

  Future<void> skip({
    required String cycleId,
    required DateTime date,
    required String dayId,
    required int dayIndex,
  });

  Future<void> restToday({
    required String cycleId,
    required DateTime date,
    required String dayId,
    required int dayIndex,
  });

  // AC7: today becomes moved and [to] gets [workoutId] planned, together. A
  // [to] that already has a record is left alone and nothing is written.
  Future<void> move({
    required String cycleId,
    required DateTime date,
    required String dayId,
    required int dayIndex,
    required String workoutId,
    required DateTime to,
    required String toDayId,
    required int toDayIndex,
  });

  // The latest calendar day this phone has shown; only moves forward, so a
  // clock moved back can be told apart (edge).
  Stream<DateTime?> watchLatestDay();

  Future<void> seeDay(DateTime date);
}
