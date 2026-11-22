import 'day_record.dart';

abstract interface class DayRecordRepository {
  // Live records of one cycle on or after [from], oldest first.
  Stream<List<DayRecord>> watchSince(String cycleId, DateTime from);

  // Upserts the date's done record; marking again after Undo restores it. A
  // missed or rest date is left as it is (edge: clock moved back).
  Future<void> markDone({
    required String cycleId,
    required DateTime date,
    required String dayId,
    required int dayIndex,
  });

  // Removes the date's done record, if any.
  Future<void> undo({required String cycleId, required DateTime date});

  // Writes records for dates that have no live one; others are skipped.
  Future<void> writeSettled(List<DayRecord> records);

  // The latest calendar day this phone has shown; only moves forward, so a
  // clock moved back can be told apart (edge).
  Stream<DateTime?> watchLatestDay();

  Future<void> seeDay(DateTime date);
}
