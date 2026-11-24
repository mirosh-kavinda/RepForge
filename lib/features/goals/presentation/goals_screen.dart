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
import '../../../core/metrics/units.dart';
import '../../onboarding/data/providers.dart';
import '../data/providers.dart';
import '../domain/goal.dart';
import 'goal_text.dart';

// Screen 07 (AC1): active goals, then achieved ones.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  static const newKey = ValueKey('goals.new');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    ref.listen(goalSettlerProvider, (_, _) {});
    final all = ref.watch(goalsProvider).value;
    final active = [...?all?.where((g) => g.isActive)];
    final achieved = [...?all?.where((g) => !g.isActive)]
      ..sort((a, b) => b.achievedAt!.compareTo(a.achievedAt!));

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: RfSpace.s16, bottom: RfSpace.s8),
      child: Semantics(
        header: true,
        child: Text(text, style: t.heading.copyWith(color: c.textPrimary)),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.goalsTitle),
        actions: [
          IconButton(
            key: newKey,
            tooltip: l10n.goalNew,
            icon: const Icon(Icons.add),
            onPressed: () => context.push(Routes.goalNew),
          ),
        ],
      ),
      body: SafeArea(
        child: switch (all) {
          null => const Center(child: CircularProgressIndicator()),
          [] => Center(
            child: Padding(
              padding: const EdgeInsets.all(RfSpace.s24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.goalsNone,
                    style: t.body.copyWith(color: c.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: RfSpace.s16),
                  RfButton(
                    label: l10n.goalNew,
                    onPressed: () => context.push(Routes.goalNew),
                  ),
                ],
              ),
            ),
          ),
          _ => ListView(
            padding: const EdgeInsets.all(RfSpace.s16),
            children: [
              if (active.isNotEmpty) heading(l10n.goalsActive),
              for (final g in active) GoalTile(goal: g),
              if (achieved.isNotEmpty) heading(l10n.goalsAchieved),
              for (final g in achieved) GoalTile(goal: g),
            ],
          ),
        },
      ),
    );
  }
}

enum _Action { pin, unpin, edit, achieve, delete }

// AC4, AC5, AC7, AC9, AC10.
class GoalTile extends ConsumerWidget {
  const GoalTile({required this.goal, super.key});

  final Goal goal;

  static ValueKey<String> menuKey(String id) => ValueKey('goal.menu.$id');

  Future<void> _run(BuildContext context, WidgetRef ref, _Action a) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(goalRepositoryProvider);
    if (a == _Action.edit) {
      await context.push(Routes.goalEdit(goal.id));
      return;
    }
    try {
      switch (a) {
        case _Action.pin:
          await repo.pin(goal.id);
        case _Action.unpin:
          await repo.unpin(goal.id);
        case _Action.achieve:
          await repo.achieve(goal.id, ref.read(todayProvider));
        case _Action.delete:
          await repo.delete(goal.id);
        case _Action.edit:
          break;
      }
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.goalActionFailed)));
      return;
    }
    if (a == _Action.delete) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.goalDeleted),
          action: SnackBarAction(
            label: l10n.goalUndo,
            onPressed: () async {
              try {
                await repo.restore(goal.id);
              } on Object {
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.goalActionFailed)),
                );
              }
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final locale = Localizations.localeOf(context).toString();
    final units = ref.watch(unitSystemProvider).value ?? UnitSystem.metric;
    final lift = goal.exerciseId == null
        ? null
        : ref.watch(goalLiftNameProvider(goal.exerciseId!)).value ??
              l10n.goalLift;
    final statusAsync = ref.watch(goalStatusOfProvider(goal));
    final status = statusAsync.value;
    final name = goalName(l10n, goal, lift);
    final percent = status?.percent ?? 0;
    final achievedAt = goal.achievedAt;

    final lines = [
      goalPath(l10n, goal, status?.current, units),
      if (achievedAt != null)
        l10n.goalAchievedOn(goalDate(locale, achievedAt))
      else ...[
        if (status != null)
          projectionText(l10n, locale, status.projection)
        else if (statusAsync.hasError)
          l10n.goalNotEnoughData,
        if (goal.deadline case final d?)
          [
            l10n.goalDeadlineOn(goalDate(locale, d)),
            if (status?.pace case final p?) paceText(l10n, p),
          ].join(' · '),
        if (goal.pinned) l10n.goalPinned,
      ],
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: RfSpace.s8),
      padding: const EdgeInsets.fromLTRB(
        RfSpace.s16,
        RfSpace.s12,
        RfSpace.s4,
        RfSpace.s12,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(RfRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: t.labelStrong.copyWith(color: c.textPrimary),
                  ),
                  const SizedBox(height: RfSpace.s4),
                  Row(
                    children: [
                      Expanded(
                        child: ExcludeSemantics(
                          child: LinearProgressIndicator(
                            value: percent / 100,
                            color: c.actionFill,
                            backgroundColor: c.divider,
                            borderRadius: BorderRadius.circular(RfRadius.pill),
                          ),
                        ),
                      ),
                      const SizedBox(width: RfSpace.s8),
                      Text(
                        percentText(l10n, percent),
                        style: t.labelStrong.copyWith(color: c.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: RfSpace.s4),
                  for (final line in lines)
                    Text(line, style: t.label.copyWith(color: c.textSecondary)),
                ],
              ),
            ),
          ),
          PopupMenuButton<_Action>(
            key: menuKey(goal.id),
            tooltip: l10n.goalActions,
            onSelected: (a) => _run(context, ref, a),
            itemBuilder: (context) => [
              if (goal.isActive) ...[
                if (goal.pinned)
                  PopupMenuItem(
                    value: _Action.unpin,
                    child: Text(l10n.goalUnpin),
                  )
                else
                  PopupMenuItem(value: _Action.pin, child: Text(l10n.goalPin)),
                PopupMenuItem(value: _Action.edit, child: Text(l10n.goalEdit)),
                PopupMenuItem(
                  value: _Action.achieve,
                  child: Text(l10n.goalMarkAchieved),
                ),
              ],
              PopupMenuItem(
                value: _Action.delete,
                child: Text(l10n.goalDelete),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
