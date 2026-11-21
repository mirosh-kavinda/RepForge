import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/features/schedule/domain/starter_plans.dart';
import 'package:repforge/features/workout/data/starter_templates.dart';
import 'package:repforge/features/workout/domain/workout_template.dart';

void main() {
  final today = DateTime(2026, 11, 21, 9);
  final workouts = [
    for (final (i, t) in starterTemplates.indexed) t.copyWith(id: 'w$i'),
  ];
  String id(String name) => workouts.firstWhere((w) => w.name == name).id;

  group('SCH-01 AC10 starter plans', () {
    test('PPL + Rest: Push, Pull, Legs, Rest; active from today at day 1', () {
      final c = buildPlan(StarterPlan.ppl, workouts, today)!;
      expect(c.name, 'PPL + Rest');
      expect(c.days.map((d) => d.workoutId), [
        id('Push'),
        id('Pull'),
        id('Legs'),
        null,
      ]);
      expect(c.isActive, isTrue);
      expect(c.startDate, DateTime.utc(2026, 11, 21));
      expect(c.startDayIndex, 0);
    });

    test('Upper / Lower is 6 days with 2 rests; Full Body + Rest is 2', () {
      final ul = buildPlan(StarterPlan.upperLower, workouts, today)!;
      expect(ul.days.map((d) => d.workoutId), [
        id('Upper'),
        id('Lower'),
        null,
        id('Upper'),
        id('Lower'),
        null,
      ]);
      final fb = buildPlan(StarterPlan.fullBody, workouts, today)!;
      expect(fb.days.map((d) => d.workoutId), [id('Full Body'), null]);
    });

    test('edge a plan whose starter workout was deleted is not offered', () {
      final noLegs = workouts.where((w) => w.name != 'Legs').toList();
      expect(buildPlan(StarterPlan.ppl, noLegs, today), isNull);
      expect(buildPlan(StarterPlan.fullBody, noLegs, today), isNotNull);
      expect(
        buildPlan(StarterPlan.ppl, const <WorkoutTemplate>[], today),
        isNull,
      );
    });
  });
}
