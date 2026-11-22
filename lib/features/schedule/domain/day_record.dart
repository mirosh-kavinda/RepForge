import 'package:freezed_annotation/freezed_annotation.dart';

part 'day_record.freezed.dart';

enum DayStatus { done, missed, rest }

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
  }) = _DayRecord;
}
