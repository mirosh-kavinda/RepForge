import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../core/clock.dart';
import '../../../core/metrics/body.dart';
import '../../../core/metrics/energy.dart';
import '../../../core/metrics/estimate.dart';
import '../../../core/metrics/units.dart';
import '../../onboarding/data/providers.dart';
import '../data/providers.dart';
import '../domain/body_rules.dart';
import '../domain/body_snapshot.dart';

String activityLabel(AppLocalizations l10n, ActivityLevel a) => switch (a) {
  ActivityLevel.sedentary => l10n.activitySedentary,
  ActivityLevel.light => l10n.activityLight,
  ActivityLevel.moderate => l10n.activityModerate,
  ActivityLevel.active => l10n.activityActive,
  ActivityLevel.veryActive => l10n.activityVeryActive,
};

// Screen 05 (BOD-01 AC2, AC3, AC6).
class BodyFormScreen extends ConsumerStatefulWidget {
  const BodyFormScreen({super.key});

  static const weightKey = ValueKey('body.weight');
  static const waistKey = ValueKey('body.waist');
  static const neckKey = ValueKey('body.neck');
  static const hipKey = ValueKey('body.hip');
  static const scaleKey = ValueKey('body.scale');
  static const activityKey = ValueKey('body.activity');
  static const saveKey = ValueKey('body.save');

  @override
  ConsumerState<BodyFormScreen> createState() => _BodyFormScreenState();
}

class _BodyFormScreenState extends ConsumerState<BodyFormScreen> {
  final _weight = TextEditingController();
  final _waist = TextEditingController();
  final _neck = TextEditingController();
  final _hip = TextEditingController();
  final _scale = TextEditingController();
  ActivityLevel? _activity;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_weight, _waist, _neck, _hip, _scale]) {
      c.dispose();
    }
    super.dispose();
  }

  static double? _parse(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  UnitSystem get _units =>
      ref.read(unitSystemProvider).value ?? UnitSystem.metric;

  double? _kg() => switch (_parse(_weight)) {
    final v? => _units == UnitSystem.metric ? v : lbToKg(v),
    null => null,
  };

  double? _cm(TextEditingController c) => switch (_parse(c)) {
    final v? => _units == UnitSystem.metric ? v : inToCm(v),
    null => null,
  };

  // Edge: a value the metrics would reject is refused here, with its range.
  String? _rangeError(
    AppLocalizations l10n,
    TextEditingController c,
    Measure m,
    double? stored,
  ) {
    if (c.text.trim().isEmpty) return null;
    if (stored != null && m.accepts(stored)) return null;
    final metric = _units == UnitSystem.metric;
    String show(double v) => switch (m) {
      Measure.weightKg => (metric ? v : kgToLb(v)).round().toString(),
      Measure.bodyFatPct => v.round().toString(),
      _ => (metric ? v : cmToIn(v)).round().toString(),
    };
    return m == Measure.weightKg
        ? l10n.bodyWeightRange(show(m.min), show(m.max))
        : l10n.bodyFieldRange(show(m.min), show(m.max));
  }

  Future<void> _save(BodyProfile profile) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final input = BodyInput(
      weightKg: _kg()!,
      activity: _activity ?? profile.activity ?? defaultActivity,
      waistCm: _cm(_waist),
      neckCm: _cm(_neck),
      hipCm: profile.sex == Sex.male ? null : _cm(_hip),
      scaleBodyFatPct: _parse(_scale),
    );
    final results = computeBodyResults(
      input,
      profile,
      ref.read(clockProvider)(),
    );
    setState(() => _saving = true);
    try {
      final id = await ref
          .read(bodyRepositoryProvider)
          .saveToday(input, results);
      unawaited(router.pushReplacement(Routes.bodySnapshot(id)));
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.bodySaveFailed)));
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final units = ref.watch(unitSystemProvider).value ?? UnitSystem.metric;
    final profile = ref.watch(bodyProfileProvider).value ?? const BodyProfile();
    final metric = units == UnitSystem.metric;
    final mass = metric ? l10n.unitKg : l10n.unitLb;
    final length = metric ? l10n.unitCm : l10n.unitIn;
    final massWord = metric ? l10n.unitKilograms : l10n.unitPounds;
    final lengthWord = metric ? l10n.unitCentimetres : l10n.unitInches;
    final profileAsync = ref.watch(bodyProfileProvider);

    final weightError = _rangeError(l10n, _weight, Measure.weightKg, _kg());
    final errors = {
      _waist: _rangeError(l10n, _waist, Measure.waistCm, _cm(_waist)),
      _neck: _rangeError(l10n, _neck, Measure.neckCm, _cm(_neck)),
      _hip: _rangeError(l10n, _hip, Measure.hipCm, _cm(_hip)),
      _scale: _rangeError(l10n, _scale, Measure.bodyFatPct, _parse(_scale)),
    };
    final ok =
        _kg() != null &&
        weightError == null &&
        errors.values.every((e) => e == null);

    Widget field(
      Key key,
      TextEditingController ctl,
      String label,
      String suffix,
      String unitWord, {
      String? error,
    }) => Padding(
      padding: const EdgeInsets.only(top: RfSpace.s12),
      // NFR-06: the unit in words, not "k g".
      child: Semantics(
        hint: l10n.fieldInUnit(label, unitWord),
        child: TextField(
          key: key,
          controller: ctl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
          ],
          decoration: InputDecoration(
            labelText: label,
            suffixText: suffix,
            errorText: error,
          ),
          onChanged: (_) => setState(() {}),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bodyFormTitle)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RfSpace.s16),
          child: RfButton(
            key: BodyFormScreen.saveKey,
            label: l10n.bodySave,
            loading: _saving,
            onPressed: ok && !_saving && profileAsync.hasValue
                ? () => _save(profile)
                : null,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(RfSpace.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.bodyReplaces,
                style: t.label.copyWith(color: c.textSecondary),
              ),
              field(
                BodyFormScreen.weightKey,
                _weight,
                l10n.bodyWeight,
                mass,
                massWord,
                error: weightError,
              ),
              const SizedBox(height: RfSpace.s16),
              Text(
                l10n.bodyTapeHint,
                style: t.label.copyWith(color: c.textSecondary),
              ),
              field(
                BodyFormScreen.waistKey,
                _waist,
                l10n.bodyWaist,
                length,
                lengthWord,
                error: errors[_waist],
              ),
              field(
                BodyFormScreen.neckKey,
                _neck,
                l10n.bodyNeck,
                length,
                lengthWord,
                error: errors[_neck],
              ),
              // The tape estimate needs hip unless sex is male (AC2, AC4).
              if (profile.sex != Sex.male)
                field(
                  BodyFormScreen.hipKey,
                  _hip,
                  l10n.bodyHip,
                  length,
                  lengthWord,
                  error: errors[_hip],
                ),
              field(
                BodyFormScreen.scaleKey,
                _scale,
                l10n.bodyScaleFat,
                '%',
                l10n.unitPercent,
                error: errors[_scale],
              ),
              const SizedBox(height: RfSpace.s16),
              DropdownButtonFormField<ActivityLevel>(
                key: BodyFormScreen.activityKey,
                initialValue: _activity ?? profile.activity ?? defaultActivity,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.bodyActivity),
                items: [
                  for (final a in ActivityLevel.values)
                    DropdownMenuItem(
                      value: a,
                      child: Text(activityLabel(l10n, a), style: t.body),
                    ),
                ],
                onChanged: (a) => setState(() => _activity = a),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
