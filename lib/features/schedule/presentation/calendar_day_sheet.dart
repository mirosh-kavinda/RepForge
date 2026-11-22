import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../workout/domain/workout_template.dart';
import '../domain/calendar.dart';
import '../domain/cycle.dart';
import '../domain/day_record.dart';
import 'calendar_view.dart';
import 'weekday_labels.dart';

// SCH-05 AC6: read-only details of one date.
Future<void> showCalendarDay(
  BuildContext context,
  CalendarDay day, {
  required Map<String, Cycle> cycles,
  required Cycle? active,
  required Map<String, WorkoutTemplate> workouts,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final week = WeekdayLabels.of(context);

    // Edge: a date recorded in more than one cycle lists each with its own
    // workout and status.
    String recordLine(DayRecord r) {
      final cy = cycles[r.cycleId];
      String? row;
      for (final d in cy?.days ?? const <CycleDay>[]) {
        if (d.id == r.dayId) row = d.workoutId;
      }
      final one = CalendarDay(
        date: day.date,
        inMonth: true,
        isToday: false,
        kind: CalendarKind.history,
        status: r.status,
        workoutId: r.workoutId ?? row,
        record: r,
      );
      return [
        if (cy != null) l10n.calendarCycle(cy.name),
        calendarWorkout(l10n, one, workouts),
        calendarStatus(l10n, one),
      ].join(' · ');
    }

    final note = calendarNote(l10n, day, workouts, week);
    final lines = <String>[
      if (day.kind == CalendarKind.empty)
        l10n.calendarNothing
      else
        {
          calendarWorkout(l10n, day, workouts),
          calendarStatus(l10n, day),
        }.join(' · '),
      ?note,
      if (day.records.length > 1)
        for (final r in day.records) recordLine(r)
      else if (day.record case final r? when cycles[r.cycleId] != null)
        l10n.calendarCycle(cycles[r.cycleId]!.name)
      else if (day.kind == CalendarKind.planned && active != null)
        l10n.calendarCycle(active.name),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          RfSpace.s20,
          0,
          RfSpace.s20,
          RfSpace.s20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                DateFormat.MMMMEEEEd(week.locale).format(day.date),
                style: t.heading,
              ),
            ),
            for (final l in lines)
              Padding(
                padding: const EdgeInsets.only(top: RfSpace.s8),
                child: Text(l, style: t.body.copyWith(color: c.textSecondary)),
              ),
          ],
        ),
      ),
    );
  },
);
