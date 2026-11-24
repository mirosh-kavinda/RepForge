import 'package:flutter/material.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_chip.dart';
import '../../../app/widgets/rf_tappable.dart';
import '../../workout/domain/workout_template.dart';
import '../domain/starter_plans.dart';

String planTitle(AppLocalizations l10n, StarterPlan p) => switch (p) {
  StarterPlan.ppl => l10n.planPpl,
  StarterPlan.upperLower => l10n.planUpperLower,
  StarterPlan.fullBody => l10n.planFullBody,
};

String planDescription(AppLocalizations l10n, StarterPlan p) => switch (p) {
  StarterPlan.ppl => l10n.planPplDesc,
  StarterPlan.upperLower => l10n.planUpperLowerDesc,
  StarterPlan.fullBody => l10n.planFullBodyDesc,
};

// Plans whose starter workouts all still exist (AC10 edge).
List<StarterPlan> availablePlans(
  List<WorkoutTemplate> workouts,
  DateTime today,
) => [
  for (final p in StarterPlan.values)
    if (buildPlan(p, workouts, today) != null) p,
];

// Screen 12 cards; also the empty Schedule (AC6, AC10).
class StarterPlanCards extends StatelessWidget {
  const StarterPlanCards({
    required this.plans,
    required this.onTap,
    this.selected,
    super.key,
  });

  final List<StarterPlan> plans;
  final StarterPlan? selected;
  final ValueChanged<StarterPlan> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final p in plans)
          Padding(
            padding: const EdgeInsets.only(bottom: RfSpace.s8),
            child: Semantics(
              container: true,
              button: true,
              selected: selected == null ? null : selected == p,
              inMutuallyExclusiveGroup: selected != null,
              label: [
                planTitle(l10n, p),
                if (p == StarterPlan.ppl) l10n.planRecommended,
                planDescription(l10n, p),
                p.days.map((d) => d ?? l10n.cycleRest).join(', '),
              ].join(', '),
              onTap: () => onTap(p),
              excludeSemantics: true,
              child: RfTappable(
                radius: RfRadius.lg,
                onTap: () => onTap(p),
                child: Container(
                  padding: const EdgeInsets.all(RfSpace.s16),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(RfRadius.lg),
                    border: Border.all(
                      color: selected == p ? c.actionFill : c.border,
                      width: selected == p ? RfStroke.thick : RfStroke.thin,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: RfSpace.s8,
                        runSpacing: RfSpace.s4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(planTitle(l10n, p), style: t.button),
                          if (p == StarterPlan.ppl)
                            RfChip.status(
                              label: l10n.planRecommended,
                              role: RfRole.success,
                            ),
                          if (selected == p)
                            Icon(Icons.check_circle, color: c.actionInk),
                        ],
                      ),
                      const SizedBox(height: RfSpace.s4),
                      Text(
                        planDescription(l10n, p),
                        style: t.label.copyWith(color: c.textMuted),
                      ),
                      const SizedBox(height: RfSpace.s8),
                      Wrap(
                        spacing: RfSpace.s4,
                        runSpacing: RfSpace.s4,
                        children: [
                          for (final d in p.days)
                            RfChip.status(
                              label: d ?? l10n.cycleRest,
                              role: d == null ? RfRole.rest : RfRole.action,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
