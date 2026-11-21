import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../core/clock.dart';
import '../../auth/presentation/auth_messages.dart';
import '../../schedule/data/providers.dart';
import '../../schedule/domain/starter_plans.dart';
import '../../schedule/presentation/starter_plan_cards.dart';
import '../../workout/data/providers.dart';
import '../../workout/domain/workout_template.dart';
import 'onboarding_controller.dart';
import 'step_header.dart';

// Screen 12, step 3 (SCH-01 AC10). The cycle is saved before onboarding is
// marked done, so a failure leaves the user here to retry.
class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  static const startKey = ValueKey('onb.start');

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  StarterPlan? _picked;
  var _touched = false;
  var _saving = false;
  var _failed = false;

  Future<void> _run(Future<void> Function() step) async {
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      await step();
    } on Object {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _finish() =>
      ref.read(onboardingControllerProvider.notifier).finish();

  Future<void> _start(List<WorkoutTemplate> workouts, StarterPlan? plan) =>
      _run(() async {
        if (plan != null) {
          final c = buildPlan(plan, workouts, ref.read(clockProvider)());
          if (c != null) await ref.read(cycleRepositoryProvider).save(c);
        }
        await _finish();
      });

  Future<void> _buildOwn() => _run(() async {
    await _finish();
    if (mounted) context.go(Routes.cycleNew);
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = RfTextStyles.of(context);
    final workouts =
        ref.watch(templatesProvider).value ?? const <WorkoutTemplate>[];
    final plans = availablePlans(workouts, ref.watch(clockProvider)());
    // PPL + Rest is preselected until the user picks (AC10).
    final picked = _touched
        ? _picked
        : (plans.contains(StarterPlan.ppl) ? StarterPlan.ppl : null);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  RfSpace.s20,
                  0,
                  RfSpace.s20,
                  RfSpace.s12,
                ),
                children: [
                  const StepHeader(step: 3),
                  const SizedBox(height: RfSpace.s8),
                  Semantics(
                    header: true,
                    child: Text(l10n.onbPlanTitle, style: t.title),
                  ),
                  const SizedBox(height: RfSpace.s12),
                  StarterPlanCards(
                    plans: plans,
                    selected: picked,
                    onTap: (p) => setState(() {
                      _touched = true;
                      _picked = p;
                    }),
                  ),
                  TextButton(
                    onPressed: _saving ? null : _buildOwn,
                    child: Text(l10n.onbPlanBuildOwn),
                  ),
                  if (_failed) AuthMessage(l10n.onbSaveFailed),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                RfSpace.s20,
                0,
                RfSpace.s20,
                RfSpace.s16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RfButton(
                    key: PlanScreen.startKey,
                    label: l10n.onbStartTraining,
                    loading: _saving,
                    onPressed: _saving || picked == null
                        ? null
                        : () => _start(workouts, picked),
                  ),
                  RfButton(
                    label: l10n.onbPlanSkip,
                    variant: RfButtonVariant.ghost,
                    onPressed: _saving ? null : () => _start(workouts, null),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
