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
import '../domain/exercise_query.dart';
import 'muscle_groups.dart';
import 'search_terms.dart';

// Screen 04 in pick mode (WKT-01 AC3). Pops with the picked ids, in pick order.
class ExercisePickerScreen extends ConsumerStatefulWidget {
  const ExercisePickerScreen({
    required this.alreadyAdded,
    required this.capacity,
    super.key,
  });

  static const searchKey = ValueKey('picker.search');
  static const addKey = ValueKey('picker.add');

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
    final terms = parseSearchTerms(_text, AppLocalizations.of(context));
    final muscles = narrow(_group?.muscles ?? const <Muscle>{}, terms.muscles);
    final equipment = narrow(<Equipment>{?_equipment}, terms.equipment);
    final results = muscles == null || equipment == null
        ? const <Exercise>[]
        : await repo.search(
            ExerciseQuery(
              text: terms.text,
              muscles: muscles,
              equipment: equipment,
            ),
          );
    // A slower earlier search must not overwrite a newer one.
    if (mounted && generation == _generation) {
      setState(() => _results = results);
    }
  }

  bool get _full => _picked.length >= widget.capacity;

  void _toggle(String id) => setState(() {
    if (!_picked.remove(id) && !_full) _picked.add(id);
  });

  Future<void> _pickEquipment(AppLocalizations l10n) async {
    const none = 'none';
    final picked = await showModalBottomSheet<Object>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: RadioGroup<Object>(
          groupValue: _equipment ?? none,
          onChanged: (v) => Navigator.of(context).pop(v),
          child: ListView(
            shrinkWrap: true,
            children: [
              RadioListTile<Object>(value: none, title: Text(l10n.pickerAll)),
              for (final e in Equipment.values)
                RadioListTile<Object>(
                  value: e,
                  title: Text(equipmentLabel(l10n, e)),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked == null) return;
    setState(() => _equipment = picked is Equipment ? picked : null);
    await _search();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final results = _results;

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: RfSpace.s16),
              child: Semantics(
                container: true,
                label: l10n.pickerMuscleGroup,
                child: Wrap(
                  spacing: RfSpace.s8,
                  children: [
                    for (final g in MuscleGroup.values)
                      RfChip.filter(
                        label: muscleGroupLabel(l10n, g),
                        selected: _group == g,
                        onSelected: (on) {
                          setState(() => _group = on ? g : null);
                          _search();
                        },
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: RfSpace.s20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: RfButton(
                  label: l10n.pickerEquipment(
                    _equipment == null
                        ? l10n.pickerAll
                        : equipmentLabel(l10n, _equipment!),
                  ),
                  variant: RfButtonVariant.secondary,
                  size: RfButtonSize.md,
                  onPressed: () => _pickEquipment(l10n),
                ),
              ),
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
                  child: Text(
                    l10n.pickerNoResults,
                    style: t.body.copyWith(color: c.textSecondary),
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
    final meta = [
      equipmentLabel(l10n, exercise.equipment),
      exercise.primaryMuscles.map((m) => muscleLabel(l10n, m)).join(', '),
    ].where((s) => s.isNotEmpty).join(' · ');

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
