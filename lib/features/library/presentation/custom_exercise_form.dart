import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../app/widgets/rf_chip.dart';
import '../../../core/ids.dart';
import '../data/providers.dart';
import '../domain/custom_exercise_repository.dart';
import '../domain/custom_rules.dart';
import '../domain/exercise.dart';
import 'muscle_groups.dart';

// EXL-03 AC1, AC2, AC6: create (no [id]) or edit a custom exercise. Pops
// with the saved id.
class CustomExerciseForm extends ConsumerStatefulWidget {
  const CustomExerciseForm({this.id, this.initialName = '', super.key});

  static const nameKey = ValueKey('custom.name');
  static const notesKey = ValueKey('custom.notes');
  static const equipmentKey = ValueKey('custom.equipment');
  static const saveKey = ValueKey('custom.save');

  final String? id;
  final String initialName;

  @override
  ConsumerState<CustomExerciseForm> createState() => _CustomExerciseFormState();
}

class _CustomExerciseFormState extends ConsumerState<CustomExerciseForm> {
  late final _name = TextEditingController(text: widget.initialName);
  final _notes = TextEditingController();
  var _equipment = Equipment.other;
  final _primary = <Muscle>{};
  final _secondary = <Muscle>{};
  String? _clash;
  bool _saving = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.id case final id?) {
      _load(id);
    } else {
      _loaded = true;
    }
  }

  Future<void> _load(String id) async {
    final e = await ref.read(customExerciseRepositoryProvider).byId(id);
    if (!mounted || e == null) return;
    setState(() {
      _name.text = e.name;
      _notes.text = e.notes ?? '';
      _equipment = e.equipment;
      _primary.addAll(e.primaryMuscles);
      _secondary.addAll(e.secondaryMuscles);
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(customExerciseRepositoryProvider);
    final name = cleanExerciseName(_name.text)!;
    setState(() => _saving = true);
    try {
      final clash = await repo.nameClash(name, exceptId: widget.id);
      if (clash != NameClash.none) {
        setState(() {
          _clash = clash == NameClash.custom
              ? l10n.customClashMine(name)
              : l10n.customClashCatalog(name);
          _saving = false;
        });
        return;
      }
      final id = widget.id ?? newId();
      await repo.save(
        Exercise(
          id: id,
          name: name,
          primaryMuscles: [
            for (final m in Muscle.values)
              if (_primary.contains(m)) m,
          ],
          secondaryMuscles: [
            for (final m in Muscle.values)
              if (_secondary.contains(m) && !_primary.contains(m)) m,
          ],
          equipment: _equipment,
          category: ExerciseCategory.strength,
          level: ExerciseLevel.beginner,
          instructions: const [],
          images: const [],
          custom: true,
          notes: _notes.text,
        ),
      );
      if (mounted) Navigator.of(context).pop(id);
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.customSaveFailed)));
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final ok = _loaded && canSaveCustom(_name.text, _primary);

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(top: RfSpace.s20, bottom: RfSpace.s8),
      child: Semantics(
        header: true,
        child: Text(text, style: t.labelStrong.copyWith(color: c.textPrimary)),
      ),
    );

    Widget chips(
      Set<Muscle> picked,
      String Function(String muscle) spoken, {
      Set<Muscle> hide = const {},
    }) => Wrap(
      spacing: RfSpace.s8,
      runSpacing: RfSpace.s4,
      children: [
        for (final m in Muscle.values)
          if (!hide.contains(m))
            Semantics(
              label: spoken(muscleLabel(l10n, m)),
              child: ExcludeSemantics(
                child: RfChip.filter(
                  label: muscleLabel(l10n, m),
                  selected: picked.contains(m),
                  onSelected: (on) => setState(() {
                    on ? picked.add(m) : picked.remove(m);
                    if (on && identical(picked, _primary)) {
                      _secondary.remove(m);
                    }
                  }),
                ),
              ),
            ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? l10n.customNew : l10n.customEditTitle),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RfSpace.s16),
          child: RfButton(
            key: CustomExerciseForm.saveKey,
            label: l10n.customSave,
            loading: _saving,
            onPressed: ok && !_saving ? _save : null,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(RfSpace.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: CustomExerciseForm.nameKey,
                controller: _name,
                maxLength: CustomLimits.nameMax,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.customName,
                  errorText: _clash,
                ),
                onChanged: (_) => setState(() => _clash = null),
              ),
              label(l10n.customEquipment),
              DropdownButtonFormField<Equipment>(
                key: CustomExerciseForm.equipmentKey,
                initialValue: _equipment,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.customEquipment),
                items: [
                  for (final e in Equipment.values)
                    DropdownMenuItem(
                      value: e,
                      child: Text(equipmentLabel(l10n, e), style: t.body),
                    ),
                ],
                onChanged: (e) => setState(() => _equipment = e ?? _equipment),
              ),
              label(l10n.customMain),
              chips(_primary, l10n.customMuscleChip),
              if (_primary.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: RfSpace.s4),
                  child: Text(
                    l10n.customNeedMuscle,
                    style: t.label.copyWith(color: c.textSecondary),
                  ),
                ),
              label(l10n.customOther),
              chips(_secondary, l10n.customOtherChip, hide: _primary),
              const SizedBox(height: RfSpace.s20),
              TextField(
                key: CustomExerciseForm.notesKey,
                controller: _notes,
                maxLength: CustomLimits.notesMax,
                minLines: 3,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.customNotes,
                  hintText: l10n.customNotesHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
