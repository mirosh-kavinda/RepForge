import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../app/widgets/rf_chip.dart';
import '../../../app/widgets/rf_tappable.dart';
import '../data/providers.dart';
import '../domain/exercise.dart';
import 'custom_exercise_form.dart';
import 'exercise_filters.dart';
import 'exercise_search.dart';
import 'muscle_groups.dart';

// Screen 04 in pick mode (WKT-01 AC3). Pops with the picked ids, in pick order.
class ExercisePickerScreen extends ConsumerStatefulWidget {
  const ExercisePickerScreen({
    required this.alreadyAdded,
    required this.capacity,
    super.key,
  });

  static const searchKey = ValueKey('picker.search');
  static const addKey = ValueKey('picker.add');
  static const createKey = ValueKey('picker.create');

  final Set<String> alreadyAdded;
  final int capacity;

  @override
  ConsumerState<ExercisePickerScreen> createState() =>
      _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends ConsumerState<ExercisePickerScreen> {
  var _text = '';
  MuscleGroup? _group;
  Equipment? _equipment;
  List<Exercise>? _results;
  final _picked = <String>[];
  var _generation = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_results == null) _search();
  }

  Future<void> _search() async {
    final generation = ++_generation;
    final repo = await ref.read(exerciseCatalogProvider.future);
    if (!mounted) return;
    final results = await runSearch(
      repo,
      AppLocalizations.of(context),
      text: _text,
      group: _group,
      equipment: _equipment,
    );
    // A slower earlier search must not overwrite a newer one.
    if (mounted && generation == _generation) {
      setState(() => _results = results);
    }
  }

  bool get _full => _picked.length >= widget.capacity;

  Future<void> _create() async {
    final id = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => CustomExerciseForm(initialName: _text.trim()),
      ),
    );
    if (id != null) await _search();
  }

  void _toggle(String id) => setState(() {
    if (!_picked.remove(id) && !_full) _picked.add(id);
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final results = _results;
    // EXL-03: my exercises changed.
    ref.listen(customExercisesProvider, (_, _) => _search());

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pickerTitle)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                RfSpace.s20,
                RfSpace.s8,
                RfSpace.s20,
                0,
              ),
              child: TextField(
                key: ExercisePickerScreen.searchKey,
                decoration: InputDecoration(
                  labelText: l10n.pickerSearch,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (v) {
                  _text = v;
                  _search();
                },
              ),
            ),
            ExerciseFilters(
              group: _group,
              equipment: _equipment,
              onGroup: (g) {
                setState(() => _group = g);
                _search();
              },
              onEquipment: (e) {
                setState(() => _equipment = e);
                _search();
              },
            ),
            if (results != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  RfSpace.s20,
                  RfSpace.s8,
                  RfSpace.s20,
                  RfSpace.s4,
                ),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.pickerResults(results.length).toUpperCase(),
                    style: t.overline.copyWith(color: c.textMuted),
                  ),
                ),
              ),
            Expanded(
              child: switch (results) {
                null => const Center(child: CircularProgressIndicator()),
                [] => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(RfSpace.s24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.pickerNoResults,
                          textAlign: TextAlign.center,
                          style: t.body.copyWith(color: c.textSecondary),
                        ),
                        const SizedBox(height: RfSpace.s12),
                        // EXL-03 AC4: make it, named as searched.
                        RfButton(
                          key: ExercisePickerScreen.createKey,
                          label: _text.trim().isEmpty
                              ? l10n.customNew
                              : l10n.customCreateNamed(_text.trim()),
                          variant: RfButtonVariant.secondary,
                          size: RfButtonSize.md,
                          onPressed: _create,
                        ),
                      ],
                    ),
                  ),
                ),
                _ => ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RfSpace.s20,
                    vertical: RfSpace.s8,
                  ),
                  itemCount: results.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: RfSpace.s8),
                  itemBuilder: (context, i) {
                    final e = results[i];
                    final order = _picked.indexOf(e.id);
                    return _PickRow(
                      exercise: e,
                      order: order < 0 ? null : order + 1,
                      added: widget.alreadyAdded.contains(e.id),
                      onTap: order < 0 && _full ? null : () => _toggle(e.id),
                    );
                  },
                ),
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                RfSpace.s20,
                RfSpace.s8,
                RfSpace.s20,
                RfSpace.s16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_full)
                    Padding(
                      padding: const EdgeInsets.only(bottom: RfSpace.s8),
                      child: Text(
                        l10n.pickerFull,
                        textAlign: TextAlign.center,
                        style: t.label.copyWith(color: c.textSecondary),
                      ),
                    ),
                  RfButton(
                    key: ExercisePickerScreen.addKey,
                    label: l10n.pickerAdd(_picked.length),
                    onPressed: _picked.isEmpty
                        ? null
                        : () => Navigator.of(context).pop(List.of(_picked)),
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

class _PickRow extends StatelessWidget {
  const _PickRow({
    required this.exercise,
    required this.order,
    required this.added,
    required this.onTap,
  });

  final Exercise exercise;
  final int? order;
  final bool added;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final picked = order != null;
    final meta = exerciseMeta(l10n, exercise);

    return Semantics(
      button: true,
      selected: picked,
      enabled: onTap != null,
      label: [
        l10n.pickerToggle(exercise.name),
        meta,
        if (added) l10n.pickerAdded,
      ].join(', '),
      onTap: onTap,
      excludeSemantics: true,
      child: RfTappable(
        radius: RfRadius.lg,
        onTap: onTap,
        child: Opacity(
          opacity: onTap == null ? 0.4 : 1,
          child: Container(
            constraints: const BoxConstraints(minHeight: RfSize.minTarget),
            padding: const EdgeInsets.all(RfSpace.s12),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(RfRadius.lg),
              border: Border.all(
                color: picked ? c.actionInk : c.surface,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exercise.name, style: t.labelStrong),
                      const SizedBox(height: RfSpace.s4),
                      Text(meta, style: t.label.copyWith(color: c.textMuted)),
                      if (added)
                        Padding(
                          padding: const EdgeInsets.only(top: RfSpace.s4),
                          child: RfChip.status(
                            label: l10n.pickerAdded,
                            role: RfRole.success,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: RfSpace.s12),
                SizedBox.square(
                  dimension: RfSize.buttonMd,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: picked ? c.actionFill : null,
                      border: Border.all(
                        color: picked ? c.actionFill : c.border,
                      ),
                      borderRadius: BorderRadius.circular(RfRadius.md),
                    ),
                    child: Center(
                      child: picked
                          ? Text(
                              '$order',
                              style: t.labelStrong.copyWith(color: c.onSolid),
                            )
                          : Icon(Icons.add, color: c.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
