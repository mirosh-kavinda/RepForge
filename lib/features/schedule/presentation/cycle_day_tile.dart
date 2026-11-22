import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_tappable.dart';
import '../../library/presentation/muscle_groups.dart';
import '../../workout/data/providers.dart';
import '../../workout/domain/workout_template.dart';
import '../domain/cycle.dart';

// The title and subtitle a day shows (AC1, AC11). Rest is always spelled out,
// so it never depends on colour.
({String title, String subtitle, bool missing}) dayText(
  AppLocalizations l10n,
  CycleDay day,
  Map<String, WorkoutTemplate> workouts,
  String muscles,
) {
  if (day.isRest) {
    return (
      title: l10n.cycleRest,
      subtitle: l10n.cycleRestHint,
      missing: false,
    );
  }
  final w = workouts[day.workoutId];
  if (w == null) {
    return (
      title: l10n.cycleWorkoutDeleted,
      subtitle: l10n.cyclePickWorkout,
      missing: true,
    );
  }
  return (
    title: w.name,
    subtitle: [
      if (muscles.isNotEmpty) muscles,
      l10n.scheduleExercises(w.exercises.length),
    ].join(' · '),
    missing: false,
  );
}

class CycleDayTile extends ConsumerWidget {
  const CycleDayTile({
    required this.number,
    required this.day,
    required this.workouts,
    this.weekday,
    this.isToday = false,
    this.isDone = false,
    this.note,
    this.onTap,
    this.trailing = const [],
    super.key,
  });

  final int number;
  final CycleDay day;
  final Map<String, WorkoutTemplate> workouts;
  // SCH-03: in Weekdays the row is named by its weekday instead of a number.
  final ({String short, String full})? weekday;
  final bool isToday;
  // SCH-02 AC10: today was marked done.
  final bool isDone;
  // SCH-04 AC10: today's day action in words ("Skipped", "Swapped: Pull" …).
  final String? note;
  final VoidCallback? onTap;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final id = day.workoutId;
    final muscles = id == null || !workouts.containsKey(id)
        ? ''
        : (ref.watch(workoutMusclesProvider(id)).value ?? const [])
              .map((m) => muscleLabel(l10n, m))
              .join(' · ');
    final text = dayText(l10n, day, workouts, muscles);
    final role = day.isRest ? RfRole.rest : RfRole.action;

    // A minimum, not a fixed box, so "14" at 200 % text still fits.
    final badge = Container(
      constraints: const BoxConstraints(
        minWidth: RfSpace.s32,
        minHeight: RfSpace.s32,
      ),
      padding: const EdgeInsets.symmetric(horizontal: RfSpace.s4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isToday ? c.actionFill : c.tint(role),
        borderRadius: BorderRadius.circular(RfRadius.sm),
      ),
      child: Text(
        weekday?.short ?? '$number',
        style: t.labelStrong.copyWith(
          color: isToday ? c.onSolid : c.onTint(role),
        ),
      ),
    );

    final label = [
      weekday?.full ?? l10n.cycleDayLabel(number),
      text.title,
      if (isToday) l10n.cycleToday,
      if (isDone) l10n.homeDone,
      ?note,
      text.subtitle,
    ].join(', ');

    return Container(
      constraints: const BoxConstraints(minHeight: RfSize.minTarget),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(RfRadius.lg),
        border: Border.all(
          color: isToday ? c.actionInk : c.surface,
          width: RfStroke.medium,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              container: true,
              button: onTap != null,
              label: label,
              onTap: onTap,
              excludeSemantics: true,
              child: RfTappable(
                radius: RfRadius.lg,
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(RfSpace.s12),
                  child: Row(
                    children: [
                      badge,
                      const SizedBox(width: RfSpace.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: text.title,
                                    style: t.labelStrong.copyWith(
                                      color: text.missing
                                          ? c.missedInk
                                          : c.textPrimary,
                                    ),
                                  ),
                                  if (isToday)
                                    TextSpan(
                                      text: ' · ${l10n.cycleToday}',
                                      style: t.label.copyWith(
                                        color: c.actionInk,
                                      ),
                                    ),
                                  if (isDone)
                                    TextSpan(
                                      text: ' · ${l10n.homeDone}',
                                      style: t.label.copyWith(
                                        color: c.successInk,
                                      ),
                                    ),
                                  if (note != null)
                                    TextSpan(
                                      text: ' · $note',
                                      style: t.label.copyWith(
                                        color: c.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: RfSpace.s4),
                            Text(
                              text.subtitle,
                              style: t.label.copyWith(color: c.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ...trailing,
        ],
      ),
    );
  }
}
