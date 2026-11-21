import '../../../core/ids.dart';
import '../../workout/domain/workout_template.dart';
import 'cycle.dart';
import 'cycle_rules.dart';

enum StarterPlan {
  ppl('PPL + Rest', ['Push', 'Pull', 'Legs', null]),
  upperLower('Upper / Lower', ['Upper', 'Lower', null, 'Upper', 'Lower', null]),
  fullBody('Full Body + Rest', ['Full Body', null]);

  const StarterPlan(this.title, this.days);
  final String title;
  // Starter workout names (WKT-01 AC12); null is a rest day.
  final List<String?> days;
}

// AC10: from the user's active workouts; null when a starter workout is gone
// (edge: that plan is not offered).
Cycle? buildPlan(
  StarterPlan plan,
  List<WorkoutTemplate> workouts,
  DateTime today,
) {
  final byName = <String, String>{};
  for (final w in workouts) {
    byName.putIfAbsent(w.name, () => w.id);
  }
  final days = <CycleDay>[];
  for (final name in plan.days) {
    if (name != null && !byName.containsKey(name)) return null;
    days.add(
      CycleDay(id: newId(), workoutId: name == null ? null : byName[name]),
    );
  }
  return Cycle(
    id: newId(),
    name: plan.title,
    days: days,
    isActive: true,
    startDate: calendarDay(today),
    startDayIndex: 0,
  );
}
