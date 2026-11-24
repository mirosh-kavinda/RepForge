import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../core/clock.dart';
import '../../../core/ids.dart';
import '../../library/data/providers.dart';
import '../../library/domain/exercise.dart';
import '../../logger/data/providers.dart';
import '../../logger/domain/logger_rules.dart';
import '../../schedule/data/providers.dart';
import '../../schedule/domain/cycle.dart';
import '../../schedule/domain/cycle_rules.dart' show weekdayRow;
import '../../schedule/domain/day_actions.dart';
import '../../schedule/domain/day_record.dart';
import '../../schedule/presentation/day_actions_sheet.dart';
import '../../schedule/presentation/weekday_labels.dart';
import '../../schedule/presentation/workout_pick_sheet.dart';
import '../../workout/data/providers.dart';
import '../../workout/domain/workout_template.dart';

// Home, screen 01 / 15: today in the active cycle with Mark done / Undo, the
// missed line, what is next, and the rest-day variant (SCH-02 AC1–AC3, AC8, AC9).
// Weekdays names today by its weekday (SCH-03 AC6, AC7). Day actions and
// their variants, each with Undo (SCH-04).
class TodayCard extends ConsumerStatefulWidget {
  const TodayCard({super.key});

  static const actionKey = ValueKey('today.action');
  static const dayActionsKey = ValueKey('today.dayActions');
  static const undoKey = ValueKey('today.undo');
  static const startKey = ValueKey('today.start');

  @override
  ConsumerState<TodayCard> createState() => _TodayCardState();
}

class _TodayCardState extends ConsumerState<TodayCard> {
  // A second tap during the write would mark or undo twice.
  bool _busy = false;

  Future<void> _write(Future<void> Function() action) async {
    if (_busy) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.editorSaveFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // WKT-02 AC1, AC8: open the workout in progress, or start today's from a
  // copy of its template.
  // A second tap while starting would start or push the logger twice.
  bool _starting = false;

  Future<void> _startWorkout(ActiveToday a, WorkoutTemplate? t) async {
    if (_starting) return;
    _starting = true;
    try {
      await _openWorkout(a, t);
    } finally {
      _starting = false;
    }
  }

  Future<void> _openWorkout(ActiveToday a, WorkoutTemplate? t) async {
    if (ref.read(activeSessionProvider).value == null && t != null) {
      final catalog = await ref.read(exerciseCatalogProvider.future);
      final exercises = <String, Exercise>{};
      for (final e in t.exercises) {
        if (await catalog.byId(e.exerciseId) case final x?) {
          exercises[x.id] = x;
        }
      }
      final i = a.today.index;
      var ok = true;
      await _write(() async {
        try {
          await ref
              .read(sessionRepositoryProvider)
              .start(
                sessionFromTemplate(
                  id: newId(),
                  template: t,
                  exercises: exercises,
                  date: a.date,
                  startedAt: ref.read(clockProvider)().toUtc(),
                  cycleId: a.cycle.id,
                  dayId: a.cycle.days[i].id,
                  dayIndex: i,
                ),
              );
        } on Object {
          ok = false;
          rethrow;
        }
      });
      if (!ok) return;
    }
    if (mounted) await context.push(Routes.workout);
  }

  Future<void> _act(
    DayAction action,
    ActiveToday a,
    List<WorkoutTemplate> workouts,
    List<DateTime> targets,
    String Function(String? id) name,
  ) async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(dayRecordRepositoryProvider);
    final cycle = a.cycle;
    final i = a.today.index;
    final day = cycle.days[i];
    final shown = todayWorkoutId(cycle, a.today);
    switch (action) {
      case DayAction.swap || DayAction.trainToday:
        final id = await pickWorkout(
          context,
          [
            for (final w in workouts)
              if (w.id != day.workoutId) w,
          ],
          current: a.today.record?.workoutId,
          emptyText: action == DayAction.swap ? l10n.swapNoOthers : null,
        );
        if (id == null) return;
        await _write(
          () => repo.plan(
            cycleId: cycle.id,
            date: a.date,
            dayId: day.id,
            dayIndex: i,
            workoutId: id,
          ),
        );
      case DayAction.skip:
        await _write(
          () => repo.skip(
            cycleId: cycle.id,
            date: a.date,
            dayId: day.id,
            dayIndex: i,
          ),
        );
      case DayAction.unplannedRest:
        await _write(
          () => repo.restToday(
            cycleId: cycle.id,
            date: a.date,
            dayId: day.id,
            dayIndex: i,
          ),
        );
      case DayAction.move:
        final to = await pickMoveTarget(context, name(shown), targets);
        if (to == null || shown == null) return;
        final row = weekdayRow(to);
        await _write(
          () => repo.move(
            cycleId: cycle.id,
            date: a.date,
            dayId: day.id,
            dayIndex: i,
            workoutId: shown,
            to: to,
            toDayId: cycle.days[row].id,
            toDayIndex: row,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final active = ref.watch(cycleTodayProvider);
    final templates = ref.watch(templatesProvider);
    // Until workouts load, every training day would look deleted.
    if (!active.hasValue || (templates.isLoading && !templates.hasValue)) {
      return const SizedBox.shrink();
    }
    final a = active.value;
    if (a == null) {
      return Padding(
        padding: const EdgeInsets.all(RfSpace.s20),
        child: Text(
          l10n.homeNoCycle,
          style: t.body.copyWith(color: c.textSecondary),
        ),
      );
    }

    final list = templates.value ?? const <WorkoutTemplate>[];
    final workouts = {for (final w in list) w.id: w};
    String name(String? id) => id == null
        ? l10n.cycleRest
        : workouts[id]?.name ?? l10n.cycleWorkoutDeleted;

    final cycle = a.cycle;
    final i = a.today.index;
    final day = cycle.days[i];
    final total = cycle.days.length;
    final week = WeekdayLabels.of(context);
    final weekdays = cycle.mode == CycleMode.weekdays;
    final weekday = weekdays ? week.full(i) : null;
    final r = a.today.record;
    final status = r?.status;
    final shown = todayWorkoutId(cycle, a.today);
    final targets = moveTargets(
      cycle,
      a.records,
      a.date,
      firstDay: week.firstDay,
    );
    final actions = availableActions(cycle, a.today, moveTargets: targets);
    final locked = a.today.readOnly;
    final repo = ref.read(dayRecordRepositoryProvider);
    final inProgress = ref.watch(activeSessionProvider).value;
    final template = workouts[shown];

    // Rolling unplanned rest: the same workout waits for tomorrow (AC5).
    final nextIndex = !weekdays && status == DayStatus.unplannedRest
        ? i
        : a.today.next;
    final next = Text(
      l10n.homeNext(name(cycle.days[nextIndex].workoutId)),
      style: t.body.copyWith(color: c.textSecondary),
    );

    void undo() => _write(() => repo.undo(cycleId: cycle.id, date: a.date));
    Widget button(
      Key key,
      String label,
      VoidCallback onPressed, {
      RfButtonVariant variant = RfButtonVariant.secondary,
    }) => Padding(
      padding: const EdgeInsets.only(top: RfSpace.s8),
      child: RfButton(
        key: key,
        label: label,
        variant: variant,
        loading: _busy && key == TodayCard.actionKey,
        onPressed: onPressed,
      ),
    );
    Widget? actionsButton() => actions.isEmpty
        ? null
        : button(
            TodayCard.dayActionsKey,
            listEquals(actions, const [DayAction.trainToday])
                ? l10n.dayActionTrainToday
                : l10n.homeDayActions,
            () async {
              final pick = actions.length == 1
                  ? actions.single
                  : await pickDayAction(context, actions, cycle.mode);
              if (pick != null && context.mounted) {
                await _act(pick, a, list, targets, name);
              }
            },
          );
    Widget line(String text, Color color) => Padding(
      padding: const EdgeInsets.only(top: RfSpace.s4),
      child: Text(text, style: t.label.copyWith(color: color)),
    );

    // AC8: a workout in progress can always be resumed from Home.
    final resume = inProgress == null
        ? null
        : button(
            TodayCard.startKey,
            l10n.homeResumeWorkout,
            () => _startWorkout(a, null),
            variant: RfButtonVariant.primary,
          );

    final List<Widget> children;
    if (shown == null ||
        status == DayStatus.unplannedRest ||
        status == DayStatus.moved) {
      children = [
        Semantics(
          header: true,
          child: Text(
            status == DayStatus.unplannedRest
                ? l10n.dayActionRest
                : l10n.homeRestDay,
            style: t.title,
          ),
        ),
        line(weekday ?? l10n.homeDayOf(i + 1, total), c.restInk),
        ?resume,
        if (status == DayStatus.moved && r?.linkedDate != null)
          line(
            l10n.homeMovedTo(week.full(r!.linkedDate!.weekday - 1)),
            c.textSecondary,
          ),
        if (!locked &&
            (status == DayStatus.unplannedRest || status == DayStatus.moved))
          button(TodayCard.undoKey, l10n.undo, undo),
        ?actionsButton(),
        const SizedBox(height: RfSpace.s12),
        next,
      ];
    } else {
      final done = a.today.doneToday;
      final skipped = status == DayStatus.skipped;
      final swappedLine = switch (r) {
        DayRecord(workoutId: _?, linkedDate: final from?) => l10n.homeMovedFrom(
          week.full(from.weekday - 1),
        ),
        DayRecord(workoutId: _?) when day.isRest => l10n.homeExtraSession,
        DayRecord(workoutId: _?) => l10n.homeSwappedFrom(name(day.workoutId)),
        _ => null,
      };
      children = [
        Semantics(
          header: true,
          child: Text(
            weekday == null
                ? l10n.homeToday(i + 1, total, name(shown))
                : l10n.homeWeekdayToday(weekday, name(shown)),
            style: t.heading,
          ),
        ),
        if (swappedLine != null) line(swappedLine, c.textSecondary),
        if (a.today.missedDays > 0)
          line(l10n.homeMissed(a.today.missedDays, name(shown)), c.missedInk),
        if (done || skipped) ...[
          const SizedBox(height: RfSpace.s8),
          Row(
            children: [
              Icon(
                done ? Icons.check_circle : Icons.redo,
                color: done ? c.successInk : c.textSecondary,
              ),
              const SizedBox(width: RfSpace.s8),
              Flexible(
                child: Text(
                  done ? l10n.homeDone : l10n.homeSkipped,
                  style: t.labelStrong,
                ),
              ),
            ],
          ),
        ],
        if (locked || done || skipped) ?resume,
        if (!locked) ...[
          const SizedBox(height: RfSpace.s4),
          if (done || skipped)
            button(TodayCard.actionKey, l10n.undo, undo)
          else ...[
            if (resume != null)
              resume
            else if (template != null)
              button(
                TodayCard.startKey,
                l10n.homeStartWorkout,
                () => _startWorkout(a, template),
                variant: RfButtonVariant.primary,
              ),
            button(
              TodayCard.actionKey,
              l10n.homeMarkDone,
              () => _write(
                () => repo.markDone(
                  cycleId: cycle.id,
                  date: a.date,
                  dayId: day.id,
                  dayIndex: i,
                ),
              ),
              variant: resume == null && template == null
                  ? RfButtonVariant.primary
                  : RfButtonVariant.secondary,
            ),
            ?actionsButton(),
            if (status == DayStatus.planned && r?.linkedDate == null)
              button(
                TodayCard.undoKey,
                l10n.undo,
                undo,
                variant: RfButtonVariant.ghost,
              ),
          ],
        ],
        const SizedBox(height: RfSpace.s12),
        next,
      ];
    }

    return Container(
      margin: const EdgeInsets.all(RfSpace.s20),
      padding: const EdgeInsets.all(RfSpace.s16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(RfRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
