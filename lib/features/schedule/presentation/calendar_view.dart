import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_tappable.dart';
import '../../../core/clock.dart';
import '../../workout/data/providers.dart';
import '../../workout/domain/workout_template.dart';
import '../data/providers.dart';
import '../domain/calendar.dart';
import '../domain/cycle.dart';
import '../domain/cycle_rules.dart' as rules;
import '../domain/day_record.dart';
import 'calendar_day_sheet.dart';
import 'weekday_labels.dart';

// SCH-05 screen 03 calendar: a month of history and plan (AC1–AC5).
class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  static const prevKey = ValueKey('calendar.prev');
  static const nextKey = ValueKey('calendar.next');
  static const thisMonthKey = ValueKey('calendar.thisMonth');
  static const todayKey = ValueKey('calendar.today');

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  // The month picked with prev / next; null follows today's month, so the
  // view moves at midnight but a chosen month stays put (edge).
  DateTime? _picked;

  void _go(DateTime month, int by) =>
      setState(() => _picked = DateTime.utc(month.year, month.month + by));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final locale = Localizations.localeOf(context).toString();
    final week = WeekdayLabels.of(context);
    final today = ref.watch(todayProvider);
    final thisMonth = DateTime.utc(today.year, today.month);
    final month = _picked ?? thisMonth;
    final dates = monthDates(month, week.firstDay);
    final records = ref.watch(rangeRecordsProvider(dates.first, dates.last));
    final active = ref.watch(activeCycleProvider).value;
    final rolled = ref.watch(cycleTodayProvider).value;
    final templates = ref.watch(templatesProvider);
    final cycles = {
      for (final cy in ref.watch(cyclesProvider).value ?? const <Cycle>[])
        cy.id: cy,
      ?active?.id: ?active,
    };
    final workouts = {
      for (final w in templates.value ?? const <WorkoutTemplate>[]) w.id: w,
    };

    final header = Row(
      children: [
        IconButton(
          key: CalendarView.prevKey,
          tooltip: l10n.calendarPrevMonth,
          icon: const Icon(Icons.chevron_left),
          onPressed: () => _go(month, -1),
        ),
        Expanded(
          child: Semantics(
            header: true,
            liveRegion: true,
            child: Text(
              DateFormat.yMMMM(locale).format(month),
              textAlign: TextAlign.center,
              style: t.heading,
            ),
          ),
        ),
        IconButton(
          key: CalendarView.nextKey,
          tooltip: l10n.calendarNextMonth,
          icon: const Icon(Icons.chevron_right),
          onPressed: () => _go(month, 1),
        ),
      ],
    );

    final Widget body;
    if (records.hasError) {
      body = Text(l10n.calendarLoadFailed);
    } else if (!records.hasValue ||
        (templates.isLoading && !templates.hasValue)) {
      // Until workouts load, every day would read "Workout deleted".
      body = const Center(child: CircularProgressIndicator());
    } else {
      final days = buildMonth(
        month: month,
        firstDay: week.firstDay,
        today: today,
        records: records.value!,
        active: active,
        rolled: rolled?.cycle.id == active?.id ? rolled?.today : null,
        cycles: cycles,
      );
      final todayCell = days.where((d) => d.isToday && d.inMonth);
      void open(CalendarDay d) => showCalendarDay(
        context,
        d,
        cycles: cycles,
        active: active,
        workouts: workouts,
      );
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // AC1: today named in visible text, not only by the cell border.
          if (todayCell.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: RfSpace.s8),
              child: Text(
                l10n.calendarToday(
                  calendarSummary(l10n, todayCell.first, workouts, week),
                ),
                key: CalendarView.todayKey,
                style: t.labelStrong,
              ),
            ),
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: ExcludeSemantics(
                    child: Text(
                      week.short(rules.storedIndex(i, week.firstDay)),
                      textAlign: TextAlign.center,
                      style: t.label.copyWith(color: c.textMuted),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: RfSpace.s4),
          for (var w = 0; w < days.length; w += 7)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final d in days.sublist(w, w + 7))
                  Expanded(
                    child: _Cell(
                      day: d,
                      label: [
                        DateFormat.MMMMEEEEd(locale).format(d.date),
                        if (d.isToday) l10n.cycleToday,
                        if (!d.inMonth) l10n.calendarOtherMonth,
                        if (d.kind != CalendarKind.empty)
                          calendarSummary(l10n, d, workouts, week, date: false),
                      ].join(', '),
                      onTap: () => open(d),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: RfSpace.s12),
          const _Legend(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        if (month != thisMonth)
          Align(
            child: TextButton(
              key: CalendarView.thisMonthKey,
              style: TextButton.styleFrom(
                minimumSize: const Size(RfSize.minTarget, RfSize.minTarget),
              ),
              onPressed: () => setState(() => _picked = null),
              child: Text(l10n.calendarThisMonth),
            ),
          ),
        if (active == null)
          Padding(
            padding: const EdgeInsets.only(bottom: RfSpace.s8),
            child: Text(
              l10n.calendarNoCycle,
              style: t.label.copyWith(color: c.textSecondary),
            ),
          ),
        body,
      ],
    );
  }
}

// Text for a day's status; planned days say so (AC3, AC4).
String calendarStatus(AppLocalizations l10n, CalendarDay d) =>
    switch ((d.kind, d.status)) {
      (CalendarKind.empty, _) => '',
      (CalendarKind.planned, _) => l10n.calendarPlanned,
      (_, DayStatus.done) => l10n.homeDone,
      (_, DayStatus.missed) => l10n.calendarMissed,
      (_, DayStatus.rest) => l10n.cycleRest,
      (_, DayStatus.skipped) => l10n.homeSkipped,
      (_, DayStatus.unplannedRest) => l10n.dayActionRest,
      (_, DayStatus.moved) => l10n.calendarMoved,
      (_, DayStatus.planned || null) => l10n.calendarPlanned,
    };

String calendarWorkout(
  AppLocalizations l10n,
  CalendarDay d,
  Map<String, WorkoutTemplate> workouts,
) {
  if (d.kind == CalendarKind.empty) return '';
  final id = d.workoutId;
  if (id == null) return l10n.cycleRest;
  return workouts[id]?.name ?? l10n.cycleWorkoutDeleted;
}

// AC5: a swap or move worded as on Home.
String? calendarNote(
  AppLocalizations l10n,
  CalendarDay d,
  Map<String, WorkoutTemplate> workouts,
  WeekdayLabels week,
) {
  final r = d.record;
  String name(String id) => workouts[id]?.name ?? l10n.cycleWorkoutDeleted;
  return switch (r) {
    DayRecord(status: DayStatus.moved, :final linkedDate?) => l10n.homeMovedTo(
      week.full(linkedDate.weekday - 1),
    ),
    DayRecord(workoutId: _?, :final linkedDate?) => l10n.homeMovedFrom(
      week.full(linkedDate.weekday - 1),
    ),
    DayRecord(workoutId: _?) when d.plannedWorkoutId != null =>
      l10n.homeSwappedFrom(name(d.plannedWorkoutId!)),
    DayRecord(workoutId: _?) => l10n.homeExtraSession,
    _ => null,
  };
}

String calendarSummary(
  AppLocalizations l10n,
  CalendarDay d,
  Map<String, WorkoutTemplate> workouts,
  WeekdayLabels week, {
  bool date = true,
}) => [
  if (date) DateFormat.MMMMEEEEd(week.locale).format(d.date),
  if (d.kind != CalendarKind.empty) ...{
    calendarWorkout(l10n, d, workouts),
    // A set: a rest day reads "Rest" once, not "Rest, Rest".
    calendarStatus(l10n, d),
    ?calendarNote(l10n, d, workouts, week),
  },
].join(', ');

// Each status has its own shape, so colour only repeats it (NFR-06).
(IconData?, Color) _icon(RfColors c, CalendarDay d) {
  final swapped =
      d.record?.workoutId != null && d.record?.status != DayStatus.moved;
  return switch ((d.kind, d.status)) {
    (CalendarKind.empty, _) => (null, c.textMuted),
    _ when swapped && d.status != DayStatus.done => (
      Icons.swap_horiz,
      c.textSecondary,
    ),
    (CalendarKind.planned, _) when d.workoutId == null => (
      Icons.bedtime_outlined,
      c.textMuted,
    ),
    (CalendarKind.planned, _) => (Icons.fitness_center, c.textMuted),
    (_, DayStatus.done) => (Icons.check_circle, c.successInk),
    (_, DayStatus.missed) => (Icons.cancel, c.missedInk),
    (_, DayStatus.rest) => (Icons.bedtime, c.restInk),
    (_, DayStatus.skipped) => (Icons.redo, c.textSecondary),
    (_, DayStatus.unplannedRest) => (Icons.weekend, c.restInk),
    (_, DayStatus.moved) => (Icons.arrow_forward, c.textSecondary),
    (_, DayStatus.planned || null) => (Icons.fitness_center, c.textMuted),
  };
}

class _Cell extends StatelessWidget {
  const _Cell({required this.day, required this.label, required this.onTap});

  final CalendarDay day;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final (icon, color) = _icon(c, day);
    final history = day.kind == CalendarKind.history;
    return Semantics(
      container: true,
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: RfTappable(
        radius: RfRadius.sm,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: RfSize.minTarget),
          padding: const EdgeInsets.symmetric(vertical: RfSpace.s4),
          decoration: BoxDecoration(
            color: day.isToday
                ? c.actionFill
                : history
                ? c.surface
                : null,
            borderRadius: BorderRadius.circular(RfRadius.sm),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${day.date.day}',
                style: (day.isToday ? t.labelStrong : t.label).copyWith(
                  color: day.isToday
                      ? c.onSolid
                      : day.inMonth
                      ? c.textPrimary
                      : c.textMuted,
                ),
              ),
              if (icon != null)
                Icon(
                  icon,
                  size: RfSize.iconSm,
                  color: day.isToday ? c.onSolid : color,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Visible key from each icon shape to its word (AC3, AC4).
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final items = [
      (Icons.check_circle, c.successInk, l10n.homeDone),
      (Icons.cancel, c.missedInk, l10n.calendarMissed),
      (Icons.bedtime, c.restInk, l10n.cycleRest),
      (Icons.redo, c.textSecondary, l10n.homeSkipped),
      (Icons.weekend, c.restInk, l10n.dayActionRest),
      (Icons.arrow_forward, c.textSecondary, l10n.calendarMoved),
      (Icons.swap_horiz, c.textSecondary, l10n.calendarSwapped),
      (Icons.fitness_center, c.textMuted, l10n.calendarWorkoutPlanned),
      (Icons.bedtime_outlined, c.textMuted, l10n.calendarPlannedRest),
    ];
    return ExcludeSemantics(
      child: Wrap(
        spacing: RfSpace.s12,
        runSpacing: RfSpace.s4,
        children: [
          for (final (icon, color, text) in items)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: RfSize.iconSm, color: color),
                const SizedBox(width: RfSpace.s4),
                Flexible(
                  child: Text(
                    text,
                    style: t.label.copyWith(color: c.textSecondary),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
