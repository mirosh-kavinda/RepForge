import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../workout/data/providers.dart';
import '../../workout/domain/template_rules.dart';
import '../../workout/domain/workout_template.dart';
import '../domain/exercise.dart';

// EXL-02 AC8: pick one of my workouts; the exercise goes at its end.
Future<void> showAddToWorkout(
  BuildContext context,
  WidgetRef ref,
  Exercise exercise,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  final l10n = AppLocalizations.of(context);
  final picked = await showModalBottomSheet<Object>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => const _Sheet(),
  );
  if (picked == _newWorkout) {
    await router.push(Routes.workoutNew);
    return;
  }
  if (picked is! WorkoutTemplate) return;
  final r = addToTemplate(picked, exercise.id);
  String message;
  switch (r.result) {
    case AddResult.already:
      message = l10n.exerciseAlready(picked.name);
    case AddResult.full:
      message = l10n.exerciseFull(picked.name, TemplateLimits.maxExercises);
    case AddResult.added:
      try {
        await ref.read(templateRepositoryProvider).save(r.template);
        message = l10n.exerciseAdded(picked.name);
      } on Object {
        message = l10n.exerciseAddFailed;
      }
  }
  messenger.showSnackBar(SnackBar(content: Text(message)));
}

const _newWorkout = 'new';

class _Sheet extends ConsumerWidget {
  const _Sheet();

  static const newKey = ValueKey('addToWorkout.new');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final async = ref.watch(templatesProvider);
    // A failed read reads as no workouts, never an endless spinner.
    final all = async.hasError ? const <WorkoutTemplate>[] : async.value;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          RfSpace.s20,
          0,
          RfSpace.s20,
          RfSpace.s16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(l10n.exerciseAddTitle, style: t.heading),
            ),
            const SizedBox(height: RfSpace.s8),
            if (all == null)
              const Center(child: CircularProgressIndicator())
            else if (all.isEmpty) ...[
              Text(
                l10n.exerciseNoWorkouts,
                style: t.body.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: RfSpace.s12),
              RfButton(
                key: newKey,
                label: l10n.exerciseNewWorkout,
                onPressed: () => Navigator.of(context).pop(_newWorkout),
              ),
            ] else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final w in all)
                      ListTile(
                        minTileHeight: RfSize.minTarget,
                        title: Text(w.name, style: t.body),
                        onTap: () => Navigator.of(context).pop(w),
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
