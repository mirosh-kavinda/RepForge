import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../app/widgets/rf_chip.dart';
import '../../../app/widgets/rf_tappable.dart';
import '../../../core/metrics/units.dart';
import '../../library/presentation/exercise_picker_screen.dart';
import '../../library/presentation/muscle_groups.dart';
import '../../onboarding/data/providers.dart';
import '../domain/template_rules.dart' as rules;
import 'exercise_targets_sheet.dart';
import 'template_editor_controller.dart';
import 'template_format.dart';

enum _RowAction { moveUp, moveDown, select, unlink, remove }

// Screen 13 (AC2, AC4–AC9).
class TemplateEditorScreen extends ConsumerStatefulWidget {
  const TemplateEditorScreen({this.id, this.copyOf, super.key});

  static const nameKey = ValueKey('editor.name');
  static const saveKey = ValueKey('editor.save');
  static const addKey = ValueKey('editor.add');
  static const linkKey = ValueKey('editor.link');

  final String? id;
  final String? copyOf;

  @override
  ConsumerState<TemplateEditorScreen> createState() =>
      _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends ConsumerState<TemplateEditorScreen> {
  late final _provider = templateEditorProvider(
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

  TemplateEditor get _editor => ref.read(_provider.notifier);

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

  Future<void> _addExercises(EditorState s) async {
    final ids = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => ExercisePickerScreen(
          alreadyAdded: {for (final e in s.exercises) e.exerciseId},
          capacity: rules.remainingSlots(s.exercises),
        ),
      ),
    );
    if (ids != null && ids.isNotEmpty) await _editor.add(ids);
  }

  Future<void> _openTargets(String rowId, String title, MassUnit unit) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => ExerciseTargetsSheet(
          editor: _provider,
          rowId: rowId,
          title: title,
          unit: unit,
        ),
      );

  void _onAction(_RowAction a, int i) => switch (a) {
    _RowAction.moveUp => _editor.move(i, i - 1),
    _RowAction.moveDown => _editor.move(i, i + 1),
    _RowAction.select => _editor.startSelecting(i),
    _RowAction.unlink => _editor.unlink(i),
    _RowAction.remove => _editor.remove(i),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(_provider);
    final unit =
        (ref.watch(unitSystemProvider).value ?? UnitSystem.metric).mass;

    final s = async.value;
    if (s == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: async.hasError
              ? Text(l10n.editorNotFound)
              : const CircularProgressIndicator(),
        ),
      );
    }
    _name ??= TextEditingController(text: s.name);

    return PopScope(
      canPop: _leaving || !s.dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave(l10n);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.isNew ? l10n.editorNewTitle : l10n.editorEditTitle),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: RfSpace.s12),
              child: RfButton(
                key: TemplateEditorScreen.saveKey,
                label: l10n.editorSave,
                size: RfButtonSize.md,
                loading: _saving,
                onPressed: s.canSave ? () => _save(l10n) : null,
              ),
            ),
          ],
        ),
        bottomNavigationBar: s.selecting
            ? _SelectionBar(state: s, editor: _editor)
            : null,
        body: SafeArea(
          child: ReorderableListView.builder(
            buildDefaultDragHandles: false,
            padding: const EdgeInsets.fromLTRB(
              RfSpace.s20,
              RfSpace.s8,
              RfSpace.s20,
              RfSpace.s24,
            ),
            header: _Header(state: s, name: _name!, onName: _editor.setName),
            footer: _Footer(state: s, onAdd: () => _addExercises(s)),
            itemCount: s.exercises.length,
            onReorder: (from, to) =>
                _editor.move(from, to > from ? to - 1 : to),
            itemBuilder: (context, i) {
              final e = s.exercises[i];
              final name =
                  s.catalog[e.exerciseId]?.name ?? l10n.editorUnknownExercise;
              return Padding(
                key: ValueKey(e.id),
                padding: const EdgeInsets.only(bottom: RfSpace.s8),
                child: _Row(
                  index: i,
                  state: s,
                  name: name,
                  line: rowLine(l10n, s.exercises, i, unit),
                  onTap: s.selecting
                      ? () => _editor.toggleSelected(i)
                      : () => _openTargets(e.id, name, unit),
                  onAction: (a) => _onAction(a, i),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RfSpace.s12,
        vertical: RfSpace.s4,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(RfRadius.pill),
      ),
      child: Text(text, style: t.label.copyWith(color: c.textSecondary)),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.state,
    required this.name,
    required this.onName,
  });

  final EditorState state;
  final TextEditingController name;
  final ValueChanged<String> onName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = state;
    final muscles = rules
        .primaryMuscles(s.exercises, s.catalog)
        .map((m) => muscleLabel(l10n, m))
        .join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: RfSpace.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: TemplateEditorScreen.nameKey,
            controller: name,
            maxLength: rules.TemplateLimits.nameMax,
            textCapitalization: TextCapitalization.sentences,
            onChanged: onName,
            decoration: InputDecoration(
              labelText: l10n.editorNameLabel,
              errorText: s.name.isNotEmpty && rules.cleanName(s.name) == null
                  ? l10n.editorNameError
                  : null,
            ),
          ),
          if (s.exercises.isNotEmpty)
            Semantics(
              liveRegion: true,
              child: Wrap(
                spacing: RfSpace.s8,
                runSpacing: RfSpace.s8,
                children: [
                  _Pill(l10n.workoutsExerciseCount(s.exercises.length)),
                  _Pill(l10n.workoutsSetCount(rules.totalSets(s.exercises))),
                  _Pill(
                    l10n.workoutsMinutes(rules.estimateMinutes(s.exercises)),
                  ),
                  if (muscles.isNotEmpty) _Pill(muscles),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.state, required this.onAdd});

  final EditorState state;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final full = rules.remainingSlots(state.exercises) <= 0;
    final note = full
        ? l10n.editorLimitReached
        : state.exercises.isEmpty
        ? l10n.editorNeedsExercise
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RfButton(
          key: TemplateEditorScreen.addKey,
          label: l10n.editorAddExercise,
          variant: RfButtonVariant.secondary,
          onPressed: full || state.selecting ? null : onAdd,
        ),
        if (note != null)
          Padding(
            padding: const EdgeInsets.only(top: RfSpace.s8),
            child: Text(
              note,
              textAlign: TextAlign.center,
              style: t.label.copyWith(color: c.textSecondary),
            ),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.index,
    required this.state,
    required this.name,
    required this.line,
    required this.onTap,
    required this.onAction,
  });

  final int index;
  final EditorState state;
  final String name;
  final String line;
  final VoidCallback onTap;
  final ValueChanged<_RowAction> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final e = state.exercises[index];
    final selected = state.selection.contains(index);
    final last = state.exercises.length - 1;

    final body = Semantics(
      container: true,
      button: true,
      selected: state.selecting ? selected : null,
      label: [
        state.selecting
            ? l10n.editorSelectRow(name)
            : l10n.editorEditTargets(name),
        line,
        if (e.superset case final s?) l10n.editorSupersetLabel(s),
      ].join(', '),
      onTap: onTap,
      excludeSemantics: true,
      child: RfTappable(
        radius: RfRadius.lg,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(RfSpace.s12),
          child: Row(
            children: [
              if (state.selecting) ...[
                Icon(
                  selected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: selected ? c.actionInk : c.textMuted,
                ),
                const SizedBox(width: RfSpace.s12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: t.labelStrong),
                    const SizedBox(height: RfSpace.s4),
                    Text(line, style: t.label.copyWith(color: c.textMuted)),
                    if (e.superset case final s?)
                      Padding(
                        padding: const EdgeInsets.only(top: RfSpace.s4),
                        child: RfChip.status(
                          label: l10n.editorSupersetLabel(s),
                          role: RfRole.action,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Container(
      constraints: const BoxConstraints(minHeight: RfSize.minTarget),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(RfRadius.lg),
        border: Border.all(color: selected ? c.actionInk : c.surface, width: 2),
      ),
      child: Row(
        children: [
          Expanded(child: body),
          if (!state.selecting) ...[
            PopupMenuButton<_RowAction>(
              tooltip: l10n.editorRowActions(name),
              icon: const Icon(Icons.more_vert),
              onSelected: onAction,
              itemBuilder: (_) => [
                if (index > 0)
                  PopupMenuItem(
                    value: _RowAction.moveUp,
                    child: Text(l10n.editorMoveUp),
                  ),
                if (index < last)
                  PopupMenuItem(
                    value: _RowAction.moveDown,
                    child: Text(l10n.editorMoveDown),
                  ),
                if (state.exercises.length > 1)
                  PopupMenuItem(
                    value: _RowAction.select,
                    child: Text(l10n.editorSelectSuperset),
                  ),
                if (e.superset != null)
                  PopupMenuItem(
                    value: _RowAction.unlink,
                    child: Text(l10n.editorUnlink),
                  ),
                PopupMenuItem(
                  value: _RowAction.remove,
                  child: Text(l10n.editorRemove),
                ),
              ],
            ),
            ReorderableDragStartListener(
              index: index,
              child: Semantics(
                container: true,
                label: l10n.editorReorder(name),
                child: const SizedBox.square(
                  dimension: RfSize.minTarget,
                  child: Icon(Icons.drag_indicator),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SelectionBar extends StatelessWidget {
  const _SelectionBar({required this.state, required this.editor});

  final EditorState state;
  final TemplateEditor editor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    return Material(
      color: c.navBar,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            RfSpace.s20,
            RfSpace.s12,
            RfSpace.s20,
            RfSpace.s12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.editorSelectHint,
                style: t.label.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: RfSpace.s8),
              Row(
                children: [
                  Expanded(
                    child: RfButton(
                      label: l10n.cancel,
                      variant: RfButtonVariant.ghost,
                      onPressed: editor.cancelSelecting,
                    ),
                  ),
                  const SizedBox(width: RfSpace.s12),
                  Expanded(
                    child: RfButton(
                      key: TemplateEditorScreen.linkKey,
                      label: l10n.editorSupersetAction,
                      onPressed: state.canLinkSelection
                          ? editor.linkSelection
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
