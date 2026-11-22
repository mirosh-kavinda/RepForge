import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../app/widgets/rf_stepper.dart';
import '../../../core/clock.dart';
import '../../workout/data/providers.dart';
import '../../workout/domain/workout_template.dart';
import '../domain/cycle.dart';
import '../domain/cycle_rules.dart' as rules;
import 'cycle_day_tile.dart';
import 'cycle_editor_controller.dart';
import 'workout_pick_sheet.dart';

enum _DayAction { change, toRest, toTraining, moveUp, moveDown, remove }

// Screen 18 (AC1–AC5, AC8, AC11, AC12).
class CycleEditorScreen extends ConsumerStatefulWidget {
  const CycleEditorScreen({this.id, this.copyOf, super.key});

  static const nameKey = ValueKey('cycle.name');
  static const saveKey = ValueKey('cycle.save');
  static const addTrainingKey = ValueKey('cycle.addTraining');
  static const addRestKey = ValueKey('cycle.addRest');
  static const startDayKey = ValueKey('cycle.startDay');

  final String? id;
  final String? copyOf;

  @override
  ConsumerState<CycleEditorScreen> createState() => _CycleEditorScreenState();
}

class _CycleEditorScreenState extends ConsumerState<CycleEditorScreen> {
  late final _provider = cycleEditorProvider(
    id: widget.id,
    copyOf: widget.copyOf,
  );
  TextEditingController? _name;
  var _leaving = false;
  var _saving = false;

  @override
  void dispose() {
    _name?.dispose();
    super.dispose();
  }

  CycleEditor get _editor => ref.read(_provider.notifier);

  void _leave() {
    setState(() => _leaving = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _confirmLeave(AppLocalizations l10n) async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editorDiscardTitle),
        content: Text(l10n.editorDiscardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.editorKeepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.editorDiscard),
          ),
        ],
      ),
    );
    if (discard ?? false) _leave();
  }

  Future<void> _save(AppLocalizations l10n) async {
    setState(() => _saving = true);
    try {
      await _editor.save();
      if (mounted) _leave();
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.editorSaveFailed)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addTraining(List<WorkoutTemplate> workouts) async {
    final id = await pickWorkout(context, workouts);
    if (id != null) _editor.addTraining(id);
  }

  Future<void> _onAction(
    _DayAction a,
    int i,
    CycleDay day,
    List<WorkoutTemplate> workouts,
  ) async {
    switch (a) {
      case _DayAction.change || _DayAction.toTraining:
        final id = await pickWorkout(context, workouts, current: day.workoutId);
        if (id != null) _editor.setWorkout(i, id);
      case _DayAction.toRest:
        _editor.setWorkout(i, null);
      case _DayAction.moveUp:
        _editor.move(i, i - 1);
      case _DayAction.moveDown:
        _editor.move(i, i + 1);
      case _DayAction.remove:
        _editor.remove(i);
    }
  }

  String? _problemText(AppLocalizations l10n, rules.SaveProblem? p) =>
      switch (p) {
        null => null,
        rules.SaveProblem.name => l10n.cycleNeedName,
        rules.SaveProblem.noDays => l10n.cycleNeedDays,
        rules.SaveProblem.noTraining => l10n.cycleNeedTraining,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final async = ref.watch(_provider);
    final templates = ref.watch(templatesProvider);
    final workouts = templates.value ?? const [];
    final byId = {for (final w in workouts) w.id: w};
    final today = ref.watch(clockProvider)();

    final d = async.value;
    // Until workouts load, every training day would look deleted (AC11).
    if (d == null || (templates.isLoading && !templates.hasValue)) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: async.hasError
              ? Text(l10n.editorNotFound)
              : const CircularProgressIndicator(),
        ),
      );
    }
    _name ??= TextEditingController(text: d.name);
    final counts = rules.dayCounts(d.days);
    final canAdd = rules.canAddDay(d.days);
    final problem = _problemText(l10n, d.problem);
    final last = d.days.length - 1;

    final header = Column(
      key: const ValueKey('cycle.header'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: CycleEditorScreen.nameKey,
          controller: _name,
          maxLength: rules.CycleLimits.nameMax,
          textCapitalization: TextCapitalization.sentences,
          onChanged: _editor.setName,
          decoration: InputDecoration(labelText: l10n.cycleNameLabel),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: RfSpace.s8),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: RfSpace.s8,
            children: [
              Semantics(
                header: true,
                child: Text(l10n.cycleDaysTitle, style: t.labelStrong),
              ),
              Semantics(
                liveRegion: true,
                child: Text(
                  l10n.cycleCounts(d.days.length, counts.train, counts.rest),
                  style: t.label.copyWith(color: c.textMuted),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final footer = Column(
      key: const ValueKey('cycle.footer'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: RfButton(
                key: CycleEditorScreen.addTrainingKey,
                label: l10n.cycleAddTraining,
                variant: RfButtonVariant.secondary,
                size: RfButtonSize.md,
                onPressed: canAdd ? () => _addTraining(workouts) : null,
              ),
            ),
            const SizedBox(width: RfSpace.s8),
            Expanded(
              child: RfButton(
                key: CycleEditorScreen.addRestKey,
                label: l10n.cycleAddRest,
                variant: RfButtonVariant.secondary,
                size: RfButtonSize.md,
                onPressed: canAdd ? _editor.addRest : null,
              ),
            ),
          ],
        ),
        for (final note in [if (!canAdd) l10n.cycleMaxDays, ?problem])
          Padding(
            padding: const EdgeInsets.only(top: RfSpace.s8),
            child: Text(
              note,
              textAlign: TextAlign.center,
              style: t.label.copyWith(color: c.textSecondary),
            ),
          ),
        if (d.days.isNotEmpty) ...[
          const SizedBox(height: RfSpace.s16),
          _Preview(draft: d, workouts: byId, today: today, editor: _editor),
        ],
      ],
    );

    return PopScope(
      canPop: _leaving || !d.dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave(l10n);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            d.origin == CycleOrigin.edit
                ? l10n.cycleEditTitle
                : l10n.cycleNewTitle,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: RfSpace.s12),
              child: RfButton(
                key: CycleEditorScreen.saveKey,
                label: l10n.editorSave,
                size: RfButtonSize.md,
                loading: _saving,
                onPressed: d.problem == null ? () => _save(l10n) : null,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: ReorderableListView.builder(
            buildDefaultDragHandles: false,
            padding: const EdgeInsets.fromLTRB(
              RfSpace.s20,
              RfSpace.s8,
              RfSpace.s20,
              RfSpace.s24,
            ),
            header: header,
            footer: footer,
            itemCount: d.days.length,
            onReorder: (from, to) =>
                _editor.move(from, to > from ? to - 1 : to),
            itemBuilder: (context, i) {
              final day = d.days[i];
              final missing = !day.isRest && !byId.containsKey(day.workoutId);
              return Padding(
                key: ValueKey(day.id),
                padding: const EdgeInsets.only(bottom: RfSpace.s8),
                child: CycleDayTile(
                  number: i + 1,
                  day: day,
                  workouts: byId,
                  onTap: missing
                      ? () => _onAction(_DayAction.change, i, day, workouts)
                      : null,
                  trailing: [
                    PopupMenuButton<_DayAction>(
                      tooltip: l10n.cycleDayActions(i + 1),
                      icon: const Icon(Icons.more_vert),
                      onSelected: (a) => _onAction(a, i, day, workouts),
                      itemBuilder: (_) => [
                        if (!day.isRest) ...[
                          PopupMenuItem(
                            value: _DayAction.change,
                            child: Text(
                              missing
                                  ? l10n.cyclePickWorkout
                                  : l10n.cycleChangeWorkout,
                            ),
                          ),
                          PopupMenuItem(
                            value: _DayAction.toRest,
                            child: Text(l10n.cycleMakeRest),
                          ),
                        ] else
                          PopupMenuItem(
                            value: _DayAction.toTraining,
                            child: Text(l10n.cycleMakeTraining),
                          ),
                        if (i > 0)
                          PopupMenuItem(
                            value: _DayAction.moveUp,
                            child: Text(l10n.editorMoveUp),
                          ),
                        if (i < last)
                          PopupMenuItem(
                            value: _DayAction.moveDown,
                            child: Text(l10n.editorMoveDown),
                          ),
                        PopupMenuItem(
                          value: _DayAction.remove,
                          child: Text(l10n.editorRemove),
                        ),
                      ],
                    ),
                    ReorderableDragStartListener(
                      index: i,
                      child: Semantics(
                        container: true,
                        label: l10n.cycleReorderDay(i + 1),
                        child: const SizedBox.square(
                          dimension: RfSize.minTarget,
                          child: Icon(Icons.drag_indicator),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.draft,
    required this.workouts,
    required this.today,
    required this.editor,
  });

  final CycleDraft draft;
  final Map<String, WorkoutTemplate> workouts;
  final DateTime today;
  final CycleEditor editor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final locale = Localizations.localeOf(context).toString();
    final days = draft.days;
    final todayIndex = draft.todayIndex(today);
    final items = rules.preview(days.length, todayIndex, today);

    String name(CycleDay d) => d.isRest
        ? l10n.cycleRest
        : workouts[d.workoutId]?.name ?? l10n.cycleWorkoutDeleted;

    return Container(
      padding: const EdgeInsets.all(RfSpace.s12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(RfRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            draft.origin == CycleOrigin.create
                ? l10n.cyclePreviewTitle
                : l10n.cyclePreview,
            style: t.label.copyWith(color: c.textMuted),
          ),
          if (draft.origin == CycleOrigin.create && days.length > 1) ...[
            const SizedBox(height: RfSpace.s8),
            Text(l10n.cycleTodayIs, style: t.labelStrong),
            RfStepper(
              key: CycleEditorScreen.startDayKey,
              label: l10n.cycleTodayIs,
              value: (draft.startDay + 1).toDouble(),
              step: 1,
              min: 1,
              max: days.length.toDouble(),
              onChanged: (v) => editor.setStartDay(v.round() - 1),
            ),
          ],
          const SizedBox(height: RfSpace.s8),
          for (final p in items)
            Semantics(
              container: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: RfSpace.s4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        DateFormat.MMMEd(locale).format(p.date),
                        style: t.label.copyWith(color: c.textSecondary),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        name(days[p.dayIndex]),
                        style: t.labelStrong.copyWith(
                          color: days[p.dayIndex].isRest
                              ? c.restInk
                              : c.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
