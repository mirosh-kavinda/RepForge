import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../app/widgets/rf_segmented.dart';
import '../../../app/widgets/rf_stepper.dart';
import '../../../core/metrics/units.dart';
import '../domain/template_rules.dart';
import '../domain/workout_template.dart';
import 'template_editor_controller.dart';
import 'template_format.dart';

// Targets for one row (AC4, AC7). Edits apply to the draft as they are made.
class ExerciseTargetsSheet extends ConsumerStatefulWidget {
  const ExerciseTargetsSheet({
    required this.editor,
    required this.rowId,
    required this.title,
    required this.unit,
    super.key,
  });

  static const weightKey = ValueKey('targets.weight');
  static const doneKey = ValueKey('targets.done');

  final TemplateEditorProvider editor;
  final String rowId;
  final String title;
  final MassUnit unit;

  @override
  ConsumerState<ExerciseTargetsSheet> createState() =>
      _ExerciseTargetsSheetState();
}

class _ExerciseTargetsSheetState extends ConsumerState<ExerciseTargetsSheet> {
  late final TextEditingController _weight;
  WeightError? _weightError;

  @override
  void initState() {
    super.initState();
    final kg = _row(ref.read(widget.editor).requireValue)?.targetKg;
    _weight = TextEditingController(
      text: kg == null ? '' : weightInput(kg, widget.unit),
    );
  }

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

  TemplateExercise? _row(EditorState s) =>
      s.exercises.where((e) => e.id == widget.rowId).firstOrNull;

  void _change(TemplateExercise Function(TemplateExercise) f) =>
      ref.read(widget.editor.notifier).replace(widget.rowId, f);

  void _weightChanged(String text) {
    final parsed = parseWeight(text, widget.unit);
    setState(() => _weightError = parsed.error);
    if (parsed.error == null) {
      _change((e) => e.copyWith(targetKg: parsed.kg));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final s = ref.watch(widget.editor).value;
    final e = s == null ? null : _row(s);
    if (s == null || e == null) return const SizedBox.shrink();
    final index = s.exercises.indexOf(e);
    final innerSuperset = restsInsideSuperset(s.exercises, index);
    final fixed = e.repMin == e.repMax;
    final unit = unitLabel(l10n, widget.unit);
    final maxWeight = weightNumber(TemplateLimits.weightMaxKg, widget.unit);

    Widget field(String label, Widget child) => Padding(
      padding: const EdgeInsets.only(top: RfSpace.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.labelStrong.copyWith(color: c.textSecondary)),
          const SizedBox(height: RfSpace.s4),
          child,
        ],
      ),
    );

    RfStepper stepper({
      required String label,
      required int value,
      required int min,
      required int max,
      int step = 1,
      String Function(double)? format,
      required ValueChanged<int> onChanged,
    }) => RfStepper(
      label: label,
      value: value.toDouble(),
      step: step.toDouble(),
      min: min.toDouble(),
      max: max.toDouble(),
      format: format,
      onChanged: (v) => onChanged(v.round()),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          RfSpace.s20,
          0,
          RfSpace.s20,
          RfSpace.s16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(widget.title, style: t.heading),
            ),
            field(
              l10n.targetsSets,
              stepper(
                label: l10n.targetsSets,
                value: e.sets,
                min: TemplateLimits.setsMin,
                max: TemplateLimits.setsMax,
                onChanged: (v) => _change((e) => e.copyWith(sets: v)),
              ),
            ),
            field(
              l10n.targetsKind,
              RfSegmented<TargetKind>(
                label: l10n.targetsKind,
                allowNone: false,
                options: {
                  TargetKind.reps: l10n.targetsReps,
                  TargetKind.time: l10n.targetsTime,
                },
                selected: e.kind,
                onChanged: (k) => _change((e) => e.copyWith(kind: k!)),
              ),
            ),
            if (e.kind == TargetKind.reps) ...[
              field(
                l10n.targetsRepsMode,
                RfSegmented<bool>(
                  label: l10n.targetsRepsMode,
                  allowNone: false,
                  options: {false: l10n.targetsRange, true: l10n.targetsFixed},
                  selected: fixed,
                  onChanged: (toFixed) => _change(
                    (e) => toFixed!
                        ? e.copyWith(repMax: e.repMin)
                        : e.copyWith(
                            repMax: (e.repMin + 4).clamp(
                              e.repMin,
                              TemplateLimits.repsMax,
                            ),
                          ),
                  ),
                ),
              ),
              if (fixed)
                field(
                  l10n.targetsReps,
                  stepper(
                    label: l10n.targetsReps,
                    value: e.repMin,
                    min: TemplateLimits.repsMin,
                    max: TemplateLimits.repsMax,
                    onChanged: (v) =>
                        _change((e) => e.copyWith(repMin: v, repMax: v)),
                  ),
                )
              else ...[
                field(
                  l10n.targetsRepMin,
                  stepper(
                    label: l10n.targetsRepMin,
                    value: e.repMin,
                    min: TemplateLimits.repsMin,
                    max: TemplateLimits.repsMax,
                    onChanged: (v) => _change((e) => e.copyWith(repMin: v)),
                  ),
                ),
                field(
                  l10n.targetsRepMax,
                  stepper(
                    label: l10n.targetsRepMax,
                    value: e.repMax,
                    min: TemplateLimits.repsMin,
                    max: TemplateLimits.repsMax,
                    onChanged: (v) => _change((e) => e.copyWith(repMax: v)),
                  ),
                ),
              ],
            ] else
              field(
                l10n.targetsSeconds,
                stepper(
                  label: l10n.targetsSeconds,
                  value: e.seconds,
                  min: TemplateLimits.secondsMin,
                  max: TemplateLimits.secondsMax,
                  step: TemplateLimits.secondsStep,
                  onChanged: (v) => _change((e) => e.copyWith(seconds: v)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: RfSpace.s16),
              child: TextField(
                key: ExerciseTargetsSheet.weightKey,
                controller: _weight,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                ],
                onChanged: _weightChanged,
                decoration: InputDecoration(
                  labelText: l10n.targetsWeight(unit),
                  errorText: switch (_weightError) {
                    null => null,
                    WeightError.unreadable => l10n.targetsWeightUnreadable,
                    WeightError.outOfRange => l10n.targetsWeightRange(
                      '$maxWeight $unit',
                    ),
                  },
                ),
              ),
            ),
            field(
              l10n.targetsRest,
              innerSuperset
                  ? Text(
                      l10n.targetsRestSuperset,
                      style: t.body.copyWith(color: c.textSecondary),
                    )
                  : stepper(
                      label: l10n.targetsRest,
                      value: e.restSec,
                      min: 0,
                      max: TemplateLimits.restMax,
                      step: TemplateLimits.restStep,
                      format: (v) => restText(v.round()),
                      onChanged: (v) => _change((e) => e.copyWith(restSec: v)),
                    ),
            ),
            const SizedBox(height: RfSpace.s20),
            RfButton(
              key: ExerciseTargetsSheet.doneKey,
              label: l10n.targetsDone,
              // A typed weight that cannot be saved must be fixed first.
              onPressed: _weightError == null
                  ? () => Navigator.of(context).pop()
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
