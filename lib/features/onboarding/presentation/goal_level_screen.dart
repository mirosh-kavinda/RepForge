import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../app/widgets/rf_segmented.dart';
import '../domain/onboarding_answers.dart';
import 'goal_card.dart';
import 'onboarding_controller.dart';
import 'step_header.dart';

// Screen 10 (AC3).
class GoalLevelScreen extends ConsumerWidget {
  const GoalLevelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final t = RfTextStyles.of(context);
    final draft = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final goals = {
      TrainingGoal.buildMuscle: (
        l10n.goalBuildMuscle,
        l10n.goalBuildMuscleHint,
      ),
      TrainingGoal.getStronger: (
        l10n.goalGetStronger,
        l10n.goalGetStrongerHint,
      ),
      TrainingGoal.loseFat: (l10n.goalLoseFat, l10n.goalLoseFatHint),
      TrainingGoal.stayConsistent: (
        l10n.goalStayConsistent,
        l10n.goalStayConsistentHint,
      ),
    };
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  RfSpace.s20,
                  RfSpace.s24,
                  RfSpace.s20,
                  RfSpace.s12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StepHeader(step: 1),
                    const SizedBox(height: RfSpace.s8),
                    Semantics(
                      header: true,
                      child: Text(l10n.onbGoalTitle, style: t.title),
                    ),
                    const SizedBox(height: RfSpace.s16),
                    for (final MapEntry(key: goal, value: (title, hint))
                        in goals.entries) ...[
                      GoalCard(
                        title: title,
                        hint: hint,
                        selected: draft.goal == goal,
                        onTap: () => controller.update(
                          (d) => d.copyWith(goal: d.goal == goal ? null : goal),
                        ),
                      ),
                      const SizedBox(height: RfSpace.s12),
                    ],
                    const SizedBox(height: RfSpace.s4),
                    Text(l10n.onbLevelLabel, style: t.labelStrong),
                    const SizedBox(height: RfSpace.s8),
                    RfSegmented<TrainingLevel>(
                      label: l10n.onbLevelLabel,
                      options: {
                        TrainingLevel.beginner: l10n.levelBeginner,
                        TrainingLevel.intermediate: l10n.levelIntermediate,
                        TrainingLevel.advanced: l10n.levelAdvanced,
                      },
                      selected: draft.level,
                      onChanged: (v) =>
                          controller.update((d) => d.copyWith(level: v)),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                RfSpace.s20,
                0,
                RfSpace.s20,
                RfSpace.s24,
              ),
              child: SizedBox(
                width: double.infinity,
                child: RfButton(
                  label: l10n.onbContinue,
                  onPressed: () => context.push(Routes.onboardingAbout),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
