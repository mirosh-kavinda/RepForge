import 'package:flutter/material.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../app/widgets/rf_chip.dart';
import '../../../app/widgets/rf_stepper.dart';
import '../../../app/widgets/rf_tappable.dart';
import '../../../core/metrics/units.dart';
import '../domain/logger_rules.dart';
import '../domain/workout_session.dart';

String _num(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

// "62.5 kg", "140 lb", or "Bodyweight" for 0 on a bodyweight exercise.
String weightText(
  AppLocalizations l10n,
  double kg,
  UnitSystem units, {
  required bool bodyweight,
}) {
  if (bodyweight && kg == 0) return l10n.loggerBodyweight;
  final v = _num(displayWeight(kg, units));
  return units == UnitSystem.metric ? l10n.loggerKg(v) : l10n.loggerLb(v);
}

String setText(
  AppLocalizations l10n,
  SessionExercise row,
  SetValues v,
  UnitSystem units,
) => [
  weightText(l10n, v.kg, units, bodyweight: row.bodyweight),
  if (v.reps case final r?) l10n.loggerReps1(r),
  if (v.seconds case final s?) l10n.loggerSeconds1(s),
].join(' · ');

// LOG-02 AC1, AC5: "60 kg × 8", "Bodyweight × 12" or "40 s".
String shortSetText(
  AppLocalizations l10n,
  SessionExercise row,
  SetValues v,
  UnitSystem units,
) {
  if (v.seconds case final s?) return l10n.loggerSeconds1(s);
  final w = weightText(l10n, v.kg, units, bodyweight: row.bodyweight);
  return v.reps == null ? w : l10n.loggerTimes(w, v.reps!);
}

// Weight, then reps or seconds, as steppers in the user's unit.
class SetSteppers extends StatelessWidget {
  const SetSteppers({
    required this.row,
    required this.values,
    required this.units,
    required this.onChanged,
    super.key,
  });

  final SessionExercise row;
  final SetValues values;
  final UnitSystem units;
  final ValueChanged<SetValues> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metric = units == UnitSystem.metric;
    final v = values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RfStepper(
          label: l10n.loggerWeight,
          value: displayWeight(v.kg, units),
          step: weightStep(units),
          min: 0,
          max: metric ? 500 : 1100,
          unit: metric ? l10n.unitKg : l10n.unitLb,
          format: row.bodyweight
              ? (d) => d == 0
                    ? l10n.loggerBodyweight
                    : weightText(
                        l10n,
                        metric ? d : lbToKg(d),
                        units,
                        bodyweight: false,
                      )
              : null,
          onChanged: (d) => onChanged((
            kg: metric ? d : lbToKg(d),
            reps: v.reps,
            seconds: v.seconds,
          )),
        ),
        const SizedBox(height: RfSpace.s8),
        if (v.seconds != null)
          RfStepper(
            label: l10n.loggerSeconds,
            value: v.seconds!.toDouble(),
            step: countStep,
            min: 1,
            max: 3600,
            onChanged: (d) =>
                onChanged((kg: v.kg, reps: null, seconds: d.round())),
          )
        else
          RfStepper(
            label: l10n.loggerReps,
            value: (v.reps ?? 1).toDouble(),
            step: countStep,
            min: 1,
            max: 100,
            onChanged: (d) =>
                onChanged((kg: v.kg, reps: d.round(), seconds: null)),
          ),
      ],
    );
  }
}

// LOG-01 AC3–AC5: a pending set (steppers + Log) or a logged one (Done, tap
// to edit).
class SetRow extends StatefulWidget {
  const SetRow({
    required this.row,
    required this.setNo,
    required this.prefill,
    required this.units,
    required this.onLog,
    required this.onEdit,
    this.logged,
    this.ghost,
    this.target,
    this.isPr = false,
    super.key,
  });

  final SessionExercise row;
  final int setNo;
  final SetValues prefill;
  final UnitSystem units;
  final LoggedSet? logged;
  // LOG-02: last session's same set and today's suggested target.
  final SetValues? ghost;
  final SetValues? target;
  final bool isPr;
  final Future<void> Function(SetValues values) onLog;
  final VoidCallback onEdit;

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> {
  late SetValues _values = widget.prefill;
  var _touched = false;
  var _busy = false;

  @override
  void didUpdateWidget(SetRow old) {
    super.didUpdateWidget(old);
    // A new prefill (an earlier set just logged) applies until the user
    // changes this set by hand.
    if (!_touched && old.prefill != widget.prefill) _values = widget.prefill;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final logged = widget.logged;
    final ghost = widget.ghost == null
        ? null
        : l10n.loggerLast(
            shortSetText(l10n, widget.row, widget.ghost!, widget.units),
          );
    final target = widget.target == null
        ? null
        : l10n.loggerTarget(
            shortSetText(l10n, widget.row, widget.target!, widget.units),
          );
    Widget muted(String text) =>
        Text(text, style: t.label.copyWith(color: c.textMuted));

    if (logged != null) {
      final values = (
        kg: logged.kg,
        reps: logged.reps,
        seconds: logged.seconds,
      );
      final text = setText(l10n, widget.row, values, widget.units);
      return Semantics(
        container: true,
        button: true,
        label: [
          widget.row.name,
          l10n.loggerSet(widget.setNo),
          text,
          l10n.homeDone,
          if (widget.isPr) l10n.loggerPr,
          ?ghost,
        ].join(', '),
        onTap: widget.onEdit,
        excludeSemantics: true,
        child: RfTappable(
          radius: RfRadius.md,
          onTap: widget.onEdit,
          child: Container(
            constraints: const BoxConstraints(minHeight: RfSize.minTarget),
            padding: const EdgeInsets.all(RfSpace.s12),
            decoration: BoxDecoration(
              color: c.tint(RfRole.success),
              borderRadius: BorderRadius.circular(RfRadius.md),
              border: Border.all(color: c.successInk, width: RfStroke.medium),
            ),
            child: Wrap(
              spacing: RfSpace.s8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(l10n.loggerSet(widget.setNo), style: t.labelStrong),
                Text(text, style: t.label.copyWith(color: c.textPrimary)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: c.successInk),
                    const SizedBox(width: RfSpace.s4),
                    Text(l10n.homeDone, style: t.labelStrong),
                  ],
                ),
                if (widget.isPr)
                  RfChip.status(label: l10n.loggerPr, role: RfRole.action),
                ?(ghost == null ? null : muted(ghost)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(RfSpace.s12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(RfRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.loggerSet(widget.setNo), style: t.labelStrong),
          if (ghost != null || target != null) ...[
            const SizedBox(height: RfSpace.s4),
            Wrap(
              spacing: RfSpace.s12,
              children: [
                ?(ghost == null ? null : muted(ghost)),
                ?(target == null ? null : muted(target)),
              ],
            ),
          ],
          const SizedBox(height: RfSpace.s8),
          SetSteppers(
            row: widget.row,
            values: _values,
            units: widget.units,
            onChanged: (v) => setState(() {
              _values = v;
              _touched = true;
            }),
          ),
          const SizedBox(height: RfSpace.s8),
          Semantics(
            label: l10n.loggerLogSet(widget.setNo),
            excludeSemantics: true,
            button: true,
            child: RfButton(
              label: l10n.loggerLog,
              loading: _busy,
              onPressed: () async {
                setState(() => _busy = true);
                try {
                  await widget.onLog(_values);
                } finally {
                  if (mounted) setState(() => _busy = false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
