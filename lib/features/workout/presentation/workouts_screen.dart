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
import '../data/providers.dart';
import '../domain/template_rules.dart';
import '../domain/workout_template.dart';

enum _Action { duplicate, delete }

// My workouts (AC1, AC10, AC11). No canvas screen; built from 13's cards.
class WorkoutsScreen extends ConsumerWidget {
  const WorkoutsScreen({super.key});

  static const newKey = ValueKey('workouts.new');

  String _summary(AppLocalizations l10n, WorkoutTemplate t) => [
    l10n.workoutsExerciseCount(t.exercises.length),
    l10n.workoutsSetCount(totalSets(t.exercises)),
    l10n.workoutsMinutes(estimateMinutes(t.exercises)),
  ].join(' · ');

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    WorkoutTemplate t,
  ) async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(templateRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    await repo.delete(t.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.workoutsDeleted(t.name)),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => repo.restore(t.id),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final templates = ref.watch(templatesProvider);

    final newButton = RfButton(
      key: newKey,
      label: l10n.workoutsNew,
      onPressed: () => context.push(Routes.workoutNew),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.scheduleMyWorkouts)),
      body: SafeArea(
        child: switch (templates) {
          AsyncValue(:final value?) when value.isEmpty => Center(
            child: Padding(
              padding: const EdgeInsets.all(RfSpace.s24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.workoutsEmptyTitle,
                      textAlign: TextAlign.center,
                      style: t.heading,
                    ),
                  ),
                  const SizedBox(height: RfSpace.s8),
                  Text(
                    l10n.workoutsEmptyBody,
                    textAlign: TextAlign.center,
                    style: t.body.copyWith(color: c.textSecondary),
                  ),
                  const SizedBox(height: RfSpace.s20),
                  newButton,
                ],
              ),
            ),
          ),
          AsyncValue(:final value?) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    RfSpace.s20,
                    RfSpace.s8,
                    RfSpace.s20,
                    RfSpace.s8,
                  ),
                  itemCount: value.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: RfSpace.s8),
                  itemBuilder: (context, i) {
                    final w = value[i];
                    final summary = _summary(l10n, w);
                    void open() => context.push(Routes.workoutEdit(w.id));
                    return Container(
                      key: ValueKey(w.id),
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(RfRadius.lg),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Semantics(
                              container: true,
                              button: true,
                              label: '${w.name}, $summary',
                              onTap: open,
                              excludeSemantics: true,
                              child: RfTappable(
                                radius: RfRadius.lg,
                                onTap: open,
                                child: Padding(
                                  padding: const EdgeInsets.all(RfSpace.s16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(w.name, style: t.heading),
                                      const SizedBox(height: RfSpace.s4),
                                      Text(
                                        summary,
                                        style: t.label.copyWith(
                                          color: c.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          PopupMenuButton<_Action>(
                            tooltip: l10n.workoutsActions(w.name),
                            icon: const Icon(Icons.more_vert),
                            onSelected: (a) => switch (a) {
                              _Action.duplicate => context.push(
                                Routes.workoutCopy(w.id),
                              ),
                              _Action.delete => _delete(context, ref, w),
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: _Action.duplicate,
                                child: Text(l10n.workoutsDuplicate),
                              ),
                              PopupMenuItem(
                                value: _Action.delete,
                                child: Text(l10n.workoutsDelete),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  RfSpace.s20,
                  RfSpace.s8,
                  RfSpace.s20,
                  RfSpace.s16,
                ),
                child: newButton,
              ),
            ],
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}
