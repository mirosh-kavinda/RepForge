import 'package:freezed_annotation/freezed_annotation.dart';

part 'cycle.freezed.dart';

@freezed
abstract class CycleDay with _$CycleDay {
  const CycleDay._();

  // `id` keeps a row's identity through reorders (AC8).
  const factory CycleDay({required String id, String? workoutId}) = _CycleDay;

  bool get isRest => workoutId == null;
}

enum CycleMode { rolling, weekdays }

@freezed
abstract class Cycle with _$Cycle {
  const factory Cycle({
    required String id,
    required String name,
    required List<CycleDay> days,
    required bool isActive,
    // UTC midnight of the phone's calendar day the anchor applies to.
    required DateTime startDate,
    required int startDayIndex,
    // Weekdays: exactly 7 days stored Monday first, so row i is ISO weekday i + 1.
    @Default(CycleMode.rolling) CycleMode mode,
  }) = _Cycle;
}
