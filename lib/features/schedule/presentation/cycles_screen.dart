import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../app/widgets/rf_chip.dart';
import '../../../app/widgets/rf_stepper.dart';
import '../../../app/widgets/rf_tappable.dart';
import '../../../core/clock.dart';
import '../data/providers.dart';
import '../domain/cycle.dart';
import '../domain/cycle_repository.dart';
import '../domain/cycle_rules.dart';

enum _Action { activate, duplicate, delete }

// My cycles (AC9). No canvas screen; built like My workouts.
class CyclesScreen extends ConsumerWidget {
  const CyclesScreen({super.key});

  static const startKey = ValueKey('cycles.start');

  // A failed write keeps the list as it was and says so.
  Future<void> _guard(
    BuildContext context,
    Future<void> Function() write,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      await write();
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.editorSaveFailed)));
    }
  }

  Future<void> _activate(BuildContext context, WidgetRef ref, Cycle c) async {
    final l10n = AppLocalizations.of(context);
    var day = 1;
    final start = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => SafeArea(
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
                Text(
                  l10n.cyclesStartTitle(c.name),
                  style: RfTextStyles.of(context).heading,
                ),
                const SizedBox(height: RfSpace.s12),
                if (c.days.length > 1) ...[
                  Text(
                    l10n.cycleTodayIs,
                    style: RfTextStyles.of(context).labelStrong,
                  ),
                  RfStepper(
                    label: l10n.cycleTodayIs,
                    value: day.toDouble(),
                    step: 1,
                    min: 1,
                    max: c.days.length.toDouble(),
                    onChanged: (v) => setState(() => day = v.round()),
                  ),
                  const SizedBox(height: RfSpace.s12),
                ],
                RfButton(
                  key: startKey,
                  label: l10n.cyclesStartToday,
                  onPressed: () => Navigator.of(context).pop(day),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (start == null || !context.mounted) return;
    final today = ref.read(todayProvider);
    await _guard(
      context,
      () => ref
          .read(cycleRepositoryProvider)
          .save(
            c.copyWith(
              isActive: true,
              startDate: today,
              startDayIndex: start - 1,
            ),
          ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Cycle c) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    final repo = ref.read(cycleRepositoryProvider);
    try {
      await repo.delete(c.id);
    } on ActiveCycleDeleteError {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.cyclesActiveNoDelete)),
      );
      return;
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.editorSaveFailed)));
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.cyclesDeleted(c.name)),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () => repo
              .restore(c.id)
              .catchError(
                (Object _) => messenger.showSnackBar(
                  SnackBar(content: Text(l10n.editorSaveFailed)),
                ),
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final cycles = ref.watch(cyclesProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.scheduleMyCycles)),
      body: SafeArea(
        child: cycles == null
            ? const Center(child: CircularProgressIndicator())
            : cycles.isEmpty
            ? Center(
                child: Text(
                  l10n.cyclesEmpty,
                  style: t.body.copyWith(color: c.textSecondary),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(RfSpace.s20),
                itemCount: cycles.length,
                separatorBuilder: (_, _) => const SizedBox(height: RfSpace.s8),
                itemBuilder: (context, i) {
                  final cy = cycles[i];
                  final n = dayCounts(cy.days);
                  final summary = l10n.cycleCounts(
                    cy.days.length,
                    n.train,
                    n.rest,
                  );
                  void open() => context.push(Routes.cycleEdit(cy.id));
                  return Container(
                    key: ValueKey(cy.id),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(RfRadius.lg),
                      border: Border.all(
                        color: cy.isActive ? c.actionInk : c.surface,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            container: true,
                            button: true,
                            label: [
                              cy.name,
                              if (cy.isActive) l10n.cyclesActive,
                              summary,
                            ].join(', '),
                            onTap: open,
                            excludeSemantics: true,
                            child: RfTappable(
                              radius: RfRadius.lg,
                              onTap: open,
                              child: Padding(
                                padding: const EdgeInsets.all(RfSpace.s16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: RfSpace.s8,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text(cy.name, style: t.heading),
                                        if (cy.isActive)
                                          RfChip.status(
                                            label: l10n.cyclesActive,
                                            role: RfRole.success,
                                          ),
                                      ],
                                    ),
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
                          tooltip: l10n.cyclesActions(cy.name),
                          icon: const Icon(Icons.more_vert),
                          onSelected: (a) => switch (a) {
                            _Action.activate => _activate(context, ref, cy),
                            _Action.duplicate => context.push(
                              Routes.cycleCopy(cy.id),
                            ),
                            _Action.delete => _delete(context, ref, cy),
                          },
                          itemBuilder: (_) => [
                            if (!cy.isActive)
                              PopupMenuItem(
                                value: _Action.activate,
                                child: Text(l10n.cyclesMakeActive),
                              ),
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
    );
  }
}
