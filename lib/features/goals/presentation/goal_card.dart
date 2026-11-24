import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_tappable.dart';
import '../../../core/metrics/units.dart';
import '../../onboarding/data/providers.dart';
import '../data/providers.dart';
import 'goal_text.dart';

// AC10: the pinned (else newest) active goal on Home, or a "Set a goal" link.
// Hidden while loading and on an error, so it never blocks Home.
class GoalCard extends ConsumerWidget {
  const GoalCard({super.key});

  static const cardKey = ValueKey('home.goal');
  static const setKey = ValueKey('home.setGoal');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeGoalOfProvider);
    if (!home.hasValue) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    const pad = EdgeInsets.fromLTRB(RfSpace.s20, RfSpace.s12, RfSpace.s20, 0);
    final goal = home.value;

    if (goal == null) {
      return Padding(
        padding: pad,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            key: setKey,
            style: TextButton.styleFrom(
              minimumSize: const Size(RfSize.minTarget, RfSize.minTarget),
            ),
            onPressed: () => context.go(Routes.goalNew),
            child: Text(l10n.goalSetOne),
          ),
        ),
      );
    }

    final locale = Localizations.localeOf(context).toString();
    final units = ref.watch(unitSystemProvider).value ?? UnitSystem.metric;
    final lift = goal.exerciseId == null
        ? null
        : ref.watch(goalLiftNameProvider(goal.exerciseId!)).value ??
              l10n.goalLift;
    final statusAsync = ref.watch(goalStatusOfProvider(goal));
    final status = statusAsync.value;
    final name = goalName(l10n, goal, lift);
    final path = goalPath(l10n, goal, status?.current, units);
    final percent = percentText(l10n, status?.percent ?? 0);
    final projection = status != null
        ? projectionText(l10n, locale, status.projection)
        : statusAsync.hasError
        ? l10n.goalNotEnoughData
        : '';
    void open() => context.go(Routes.goals);

    return Padding(
      padding: pad,
      child: Semantics(
        button: true,
        excludeSemantics: true,
        label: l10n.goalHomeSummary(name, path, percent, projection),
        hint: l10n.goalCardHint,
        onTap: open,
        child: RfTappable(
          key: cardKey,
          radius: RfRadius.lg,
          onTap: open,
          child: Container(
            constraints: const BoxConstraints(minHeight: RfSize.minTarget),
            padding: const EdgeInsets.all(RfSpace.s16),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(RfRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: t.labelStrong.copyWith(color: c.textPrimary)),
                const SizedBox(height: RfSpace.s4),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (status?.percent ?? 0) / 100,
                        color: c.actionFill,
                        backgroundColor: c.divider,
                        borderRadius: BorderRadius.circular(RfRadius.pill),
                      ),
                    ),
                    const SizedBox(width: RfSpace.s8),
                    Text(
                      percent,
                      style: t.labelStrong.copyWith(color: c.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: RfSpace.s4),
                Text(path, style: t.label.copyWith(color: c.textSecondary)),
                if (projection.isNotEmpty)
                  Text(
                    projection,
                    style: t.label.copyWith(color: c.textSecondary),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
