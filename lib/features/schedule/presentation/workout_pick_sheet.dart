import 'package:flutter/material.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../workout/domain/template_rules.dart';
import '../../workout/domain/workout_template.dart';

// Returns the picked workout id (AC1, AC3, AC11).
Future<String?> pickWorkout(
  BuildContext context,
  List<WorkoutTemplate> workouts, {
  String? current,
}) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      final c = RfColors.of(context);
      final t = RfTextStyles.of(context);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: RfSpace.s20),
              child: Semantics(
                header: true,
                child: Text(l10n.cyclePickTitle, style: t.heading),
              ),
            ),
            if (workouts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(RfSpace.s20),
                child: Text(
                  l10n.cycleNoWorkouts,
                  style: t.body.copyWith(color: c.textSecondary),
                ),
              )
            else
              Flexible(
                child: RadioGroup<String>(
                  groupValue: current,
                  onChanged: (v) => Navigator.of(context).pop(v),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final w in workouts)
                        RadioListTile<String>(
                          value: w.id,
                          title: Text(w.name),
                          subtitle: Text(
                            [
                              l10n.workoutsExerciseCount(w.exercises.length),
                              l10n.workoutsMinutes(
                                estimateMinutes(w.exercises),
                              ),
                            ].join(' · '),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}
