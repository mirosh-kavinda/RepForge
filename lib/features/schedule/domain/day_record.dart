import 'package:freezed_annotation/freezed_annotation.dart';

part 'day_record.freezed.dart';

// SCH-04 adds: planned (a swap, Train today or moved-in workout not done
// yet), skipped, unplannedRest, and moved (today's workout went to
// `linkedDate`).
enum DayStatus { done, missed, rest, planned, skipped, unplannedRest, moved }

// What happened on one calendar date of one cycle.
@freezed
abstract class DayRecord with _$DayRecord {
  const factory DayRecord({
    required String id,
    required String cycleId,
    // UTC midnight of the phone's calendar day, as Cycle.startDate.
    required DateTime date,
    // The cycle row the date was on; survives reorders (AC12).
    required String dayId,
    required int dayIndex,
    required DayStatus status,
    // The workout for this date when it is not the row's own.
    String? workoutId,
    // moved: where it went; a moved-in planned record: where it came from.
    DateTime? linkedDate,
  }) = _DayRecord;
}
