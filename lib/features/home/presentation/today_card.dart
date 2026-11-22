import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../schedule/data/providers.dart';
import '../../schedule/domain/cycle.dart';
import '../../workout/data/providers.dart';
import '../../workout/domain/workout_template.dart';

// Home, screen 01 / 15: today in the active cycle with Mark done / Undo, the
// missed line, what is next, and the rest-day variant (SCH-02 AC1–AC3, AC8, AC9).
class TodayCard extends ConsumerStatefulWidget {
  const TodayCard({super.key});

  static const actionKey = ValueKey('today.action');

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

    final workouts = {
      for (final w in templates.value ?? const <WorkoutTemplate>[]) w.id: w,
    };
    String name(CycleDay d) => d.isRest
        ? l10n.cycleRest
        : workouts[d.workoutId]?.name ?? l10n.cycleWorkoutDeleted;

    final cycle = a.cycle;
    final i = a.today.index;
    final day = cycle.days[i];
    final total = cycle.days.length;
    final next = Text(
      l10n.homeNext(name(cycle.days[a.today.next])),
      style: t.body.copyWith(color: c.textSecondary),
    );
    final repo = ref.read(dayRecordRepositoryProvider);

    final List<Widget> children;
    if (day.isRest) {
      children = [
        Semantics(header: true, child: Text(l10n.homeRestDay, style: t.title)),
        const SizedBox(height: RfSpace.s4),
        Text(
          l10n.homeDayOf(i + 1, total),
          style: t.label.copyWith(color: c.restInk),
        ),
        const SizedBox(height: RfSpace.s12),
        next,
      ];
    } else {
      final done = a.today.doneToday;
      children = [
        Semantics(
          header: true,
          child: Text(
            l10n.homeToday(i + 1, total, name(day)),
            style: t.heading,
          ),
        ),
        if (a.today.missedDays > 0) ...[
          const SizedBox(height: RfSpace.s4),
          Text(
            l10n.homeMissed(a.today.missedDays, name(day)),
            style: t.label.copyWith(color: c.missedInk),
          ),
        ],
        if (done) ...[
          const SizedBox(height: RfSpace.s8),
          Row(
            children: [
              Icon(Icons.check_circle, color: c.successInk),
              const SizedBox(width: RfSpace.s8),
              Flexible(child: Text(l10n.homeDone, style: t.labelStrong)),
            ],
          ),
        ],
        if (!a.today.readOnly) ...[
          const SizedBox(height: RfSpace.s12),
          RfButton(
            key: TodayCard.actionKey,
            label: done ? l10n.undo : l10n.homeMarkDone,
            variant: done ? RfButtonVariant.secondary : RfButtonVariant.primary,
            loading: _busy,
            onPressed: () => _write(
              () => done
                  ? repo.undo(cycleId: cycle.id, date: a.date)
                  : repo.markDone(
                      cycleId: cycle.id,
                      date: a.date,
                      dayId: day.id,
                      dayIndex: i,
                    ),
            ),
          ),
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
