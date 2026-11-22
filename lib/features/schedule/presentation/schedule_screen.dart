import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../app/widgets/rf_tappable.dart';
import '../../../core/clock.dart';
import '../../workout/data/providers.dart';
import '../../workout/domain/workout_template.dart';
import '../data/providers.dart';
import '../domain/cycle.dart';
import '../domain/cycle_rules.dart';
import '../domain/starter_plans.dart';
import 'cycle_day_tile.dart';
import 'starter_plan_cards.dart';

// Screen 03: the active cycle (AC6). Calendar and weekday mode come later.
class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  static const workoutsKey = ValueKey('schedule.workouts');
  static const cyclesKey = ValueKey('schedule.cycles');
  static const newCycleKey = ValueKey('schedule.newCycle');

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  // A second tap during the save would save a second cycle.
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = ref.watch(activeCycleProvider);
    final templates = ref.watch(templatesProvider);
    final workouts = templates.value ?? const <WorkoutTemplate>[];
    final today = ref.watch(clockProvider)();

    Future<void> usePlan(StarterPlan p) async {
      if (_saving) return;
      final c = buildPlan(p, workouts, today);
      if (c == null) return;
      final messenger = ScaffoldMessenger.of(context);
      _saving = true;
      try {
        await ref.read(cycleRepositoryProvider).save(c);
      } on Object {
        messenger.showSnackBar(SnackBar(content: Text(l10n.editorSaveFailed)));
      } finally {
        _saving = false;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabSchedule)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(RfSpace.s20),
          children: [
            // In the body, not the app bar, so it wraps at 200 % text.
            Align(
              alignment: Alignment.centerRight,
              child: RfButton(
                key: ScheduleScreen.newCycleKey,
                label: l10n.scheduleNewCycle,
                size: RfButtonSize.md,
                onPressed: () => context.push(Routes.cycleNew),
              ),
            ),
            const SizedBox(height: RfSpace.s12),
            switch (active) {
              _ when templates.isLoading && !templates.hasValue =>
                const Center(child: CircularProgressIndicator()),
              AsyncValue(:final value?) => _ActiveCycleCard(
                cycle: value,
                today: today,
              ),
              AsyncValue(hasValue: true) => _EmptyCycle(
                plans: availablePlans(workouts, today),
                onPlan: usePlan,
              ),
              AsyncValue(hasError: true) => Text(l10n.scheduleLoadFailed),
              _ => const Center(child: CircularProgressIndicator()),
            },
            const SizedBox(height: RfSpace.s16),
            _LinkCard(
              key: ScheduleScreen.cyclesKey,
              title: l10n.scheduleMyCycles,
              onTap: () => context.push(Routes.cycles),
            ),
            const SizedBox(height: RfSpace.s8),
            _LinkCard(
              key: ScheduleScreen.workoutsKey,
              title: l10n.scheduleMyWorkouts,
              hint: l10n.scheduleMyWorkoutsHint,
              onTap: () => context.push(Routes.workouts),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveCycleCard extends ConsumerWidget {
  const _ActiveCycleCard({required this.cycle, required this.today});

  final Cycle cycle;
  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final workouts = {
      for (final w
          in ref.watch(templatesProvider).value ?? const <WorkoutTemplate>[])
        w.id: w,
    };
    final todayIndex = dayIndexOn(cycle, today);
    return Container(
      padding: const EdgeInsets.all(RfSpace.s16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(RfRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: RfSpace.s8,
            children: [
              Semantics(
                header: true,
                child: Text(cycle.name, style: t.heading),
              ),
              Text(
                l10n.scheduleCycleLength(cycle.days.length),
                style: t.label.copyWith(color: c.textMuted),
              ),
            ],
          ),
          const SizedBox(height: RfSpace.s4),
          Text(
            l10n.scheduleShiftHint,
            style: t.label.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: RfSpace.s12),
          for (final (i, day) in cycle.days.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: RfSpace.s8),
              child: CycleDayTile(
                number: i + 1,
                day: day,
                workouts: workouts,
                isToday: i == todayIndex,
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyCycle extends StatelessWidget {
  const _EmptyCycle({required this.plans, required this.onPlan});

  final List<StarterPlan> plans;
  final ValueChanged<StarterPlan> onPlan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(l10n.scheduleEmptyTitle, style: t.heading),
        ),
        const SizedBox(height: RfSpace.s4),
        Text(
          l10n.scheduleEmptyBody,
          style: t.body.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: RfSpace.s12),
        StarterPlanCards(plans: plans, onTap: onPlan),
      ],
    );
  }
}

class _LinkCard extends StatelessWidget {
  const _LinkCard({
    required this.title,
    required this.onTap,
    this.hint,
    super.key,
  });

  final String title;
  final String? hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    return Semantics(
      container: true,
      button: true,
      label: [title, ?hint].join(', '),
      onTap: onTap,
      excludeSemantics: true,
      child: RfTappable(
        radius: RfRadius.lg,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: RfSize.minTarget),
          padding: const EdgeInsets.all(RfSpace.s16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(RfRadius.lg),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: t.button),
                    if (hint != null) ...[
                      const SizedBox(height: RfSpace.s4),
                      Text(hint!, style: t.label.copyWith(color: c.textMuted)),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: c.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
