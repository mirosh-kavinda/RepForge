import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal.freezed.dart';

enum GoalType { strength, bodyWeight }

// What the user set (GOL-01). Values in kg: a lift's estimated 1RM, or body
// weight. Current value, progress and projection are worked out on read.
@freezed
abstract class Goal with _$Goal {
  const Goal._();

  const factory Goal({
    required String id,
    required GoalType type,
    // Strength only.
    String? exerciseId,
    required double startValue,
    required double target,
    // UTC midnight of the phone's calendar day.
    DateTime? deadline,
    @Default(false) bool pinned,
    required DateTime createdAt,
    // The date the target was reached, or marked achieved.
    DateTime? achievedAt,
  }) = _Goal;

  bool get isActive => achievedAt == null;

  // Fixed at creation: weight goals can go either way (edge).
  bool get rising => target >= startValue;
}
