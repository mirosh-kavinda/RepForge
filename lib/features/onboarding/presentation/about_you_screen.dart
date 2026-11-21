import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../app/widgets/rf_segmented.dart';
import '../../../core/metrics/energy.dart';
import '../../../core/metrics/units.dart';
import '../../auth/presentation/auth_messages.dart';
import '../domain/answer_validation.dart';
import 'onboarding_controller.dart';
import 'step_header.dart';

// Screen 11 (AC4–AC6). Finishing flips the onboarded gate, and the router
// then moves to Home by itself.
class AboutYouScreen extends ConsumerStatefulWidget {
  const AboutYouScreen({super.key});

  static const birthYearKey = ValueKey('onb.birthYear');
  static const heightKey = ValueKey('onb.height');
  static const heightInchesKey = ValueKey('onb.heightInches');
  static const weightKey = ValueKey('onb.weight');
  static const waistKey = ValueKey('onb.waist');
  static const activityKey = ValueKey('onb.activity');

  @override
  ConsumerState<AboutYouScreen> createState() => _AboutYouScreenState();
}

class _AboutYouScreenState extends ConsumerState<AboutYouScreen> {
  Set<AnswerField> _invalid = const {};
  var _saving = false;
  var _failed = false;

  Future<void> _finish() async {
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      final invalid = await ref
          .read(onboardingControllerProvider.notifier)
          .finish();
      if (mounted) setState(() => _invalid = invalid);
    } on Object {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Map<ActivityLevel, String> _activities(AppLocalizations l10n) => {
    ActivityLevel.sedentary: l10n.activitySedentary,
    ActivityLevel.light: l10n.activityLight,
    ActivityLevel.moderate: l10n.activityModerate,
    ActivityLevel.active: l10n.activityActive,
    ActivityLevel.veryActive: l10n.activityVeryActive,
  };

  Future<void> _pickActivity(AppLocalizations l10n) async {
    final controller = ref.read(onboardingControllerProvider.notifier);
    final current = ref.read(onboardingControllerProvider).activity;
    final picked = await showModalBottomSheet<ActivityLevel>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: RadioGroup<ActivityLevel>(
          groupValue: current,
          onChanged: (v) => Navigator.of(context).pop(v),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final MapEntry(key: level, value: text) in _activities(
                l10n,
              ).entries)
                RadioListTile<ActivityLevel>(value: level, title: Text(text)),
            ],
          ),
        ),
      ),
    );
    if (picked != null) controller.update((d) => d.copyWith(activity: picked));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final draft = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final imperial = draft.units == UnitSystem.imperial;
    const digits = TextInputType.numberWithOptions(decimal: true);

    Widget field({
      required Key key,
      required String label,
      required String value,
      required ValueChanged<String> onChanged,
      String? error,
      TextInputType keyboard = digits,
    }) => TextFormField(
      // Re-keyed on unit switch so converted values show (AC4).
      key: ValueKey('$key-${draft.units.name}'),
      initialValue: value,
      keyboardType: keyboard,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))],
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label, errorText: error),
    );

    Widget pair(Widget a, Widget b) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        const SizedBox(width: RfSpace.s12),
        Expanded(child: b),
      ],
    );

    final height = imperial
        ? pair(
            field(
              key: AboutYouScreen.heightKey,
              label: l10n.onbHeightFt,
              value: draft.height,
              keyboard: TextInputType.number,
              onChanged: (v) => controller.update(
                (d) => d.copyWith(height: v, exactHeightCm: null),
              ),
            ),
            field(
              key: AboutYouScreen.heightInchesKey,
              label: l10n.onbHeightIn,
              value: draft.heightInches,
              onChanged: (v) => controller.update(
                (d) => d.copyWith(heightInches: v, exactHeightCm: null),
              ),
            ),
          )
        : field(
            key: AboutYouScreen.heightKey,
            label: l10n.onbHeightCm,
            value: draft.height,
            onChanged: (v) => controller.update(
              (d) => d.copyWith(height: v, exactHeightCm: null),
            ),
          );

    final activityText = draft.activity == null
        ? l10n.onbActivityNone
        : _activities(l10n)[draft.activity]!;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  RfSpace.s20,
                  0,
                  RfSpace.s20,
                  RfSpace.s12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StepHeader(step: 2),
                    const SizedBox(height: RfSpace.s8),
                    Semantics(
                      header: true,
                      child: Text(l10n.onbAboutTitle, style: t.title),
                    ),
                    const SizedBox(height: RfSpace.s4),
                    Text(
                      l10n.onbAboutHint,
                      style: t.body.copyWith(color: c.textSecondary),
                    ),
                    const SizedBox(height: RfSpace.s16),
                    RfSegmented<UnitSystem>(
                      label: l10n.onbUnitsLabel,
                      allowNone: false,
                      options: {
                        UnitSystem.metric: l10n.unitsMetric,
                        UnitSystem.imperial: l10n.unitsImperial,
                      },
                      selected: draft.units,
                      onChanged: (u) => controller.setUnits(u!),
                    ),
                    const SizedBox(height: RfSpace.s12),
                    RfSegmented<SexChoice>(
                      label: l10n.onbSexLabel,
                      options: {
                        SexChoice.male: l10n.sexMale,
                        SexChoice.female: l10n.sexFemale,
                        SexChoice.preferNot: l10n.sexPreferNot,
                      },
                      selected: draft.sex,
                      onChanged: (s) =>
                          controller.update((d) => d.copyWith(sex: s)),
                    ),
                    const SizedBox(height: RfSpace.s16),
                    field(
                      key: AboutYouScreen.birthYearKey,
                      label: l10n.onbBirthYear,
                      value: draft.birthYear,
                      keyboard: TextInputType.number,
                      error: _invalid.contains(AnswerField.birthYear)
                          ? l10n.onbBirthYearError
                          : null,
                      onChanged: (v) =>
                          controller.update((d) => d.copyWith(birthYear: v)),
                    ),
                    const SizedBox(height: RfSpace.s16),
                    height,
                    if (_invalid.contains(AnswerField.height))
                      AuthMessage(l10n.onbHeightError),
                    const SizedBox(height: RfSpace.s16),
                    pair(
                      field(
                        key: AboutYouScreen.weightKey,
                        label: imperial ? l10n.onbWeightLb : l10n.onbWeightKg,
                        value: draft.weight,
                        onChanged: (v) => controller.update(
                          (d) => d.copyWith(weight: v, exactWeightKg: null),
                        ),
                      ),
                      field(
                        key: AboutYouScreen.waistKey,
                        label: imperial ? l10n.onbWaistIn : l10n.onbWaistCm,
                        value: draft.waist,
                        onChanged: (v) => controller.update(
                          (d) => d.copyWith(waist: v, exactWaistCm: null),
                        ),
                      ),
                    ),
                    if (_invalid.contains(AnswerField.weight))
                      AuthMessage(l10n.onbWeightError),
                    if (_invalid.contains(AnswerField.waist))
                      AuthMessage(l10n.onbWaistError),
                    const SizedBox(height: RfSpace.s16),
                    Text(
                      l10n.onbActivityLabel,
                      style: t.label.copyWith(color: c.textSecondary),
                    ),
                    const SizedBox(height: RfSpace.s4),
                    Semantics(
                      button: true,
                      label: '${l10n.onbActivityLabel}: $activityText',
                      excludeSemantics: true,
                      child: ListTile(
                        key: AboutYouScreen.activityKey,
                        minTileHeight: RfSize.minTarget,
                        tileColor: c.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(RfRadius.md),
                        ),
                        title: Text(activityText, style: t.body),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: c.textSecondary,
                        ),
                        onTap: () => _pickActivity(l10n),
                      ),
                    ),
                    if (_failed) AuthMessage(l10n.onbSaveFailed),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                RfSpace.s20,
                0,
                RfSpace.s20,
                RfSpace.s24,
              ),
              child: SizedBox(
                width: double.infinity,
                child: RfButton(
                  label: l10n.onbFinish,
                  loading: _saving,
                  onPressed: _saving ? null : _finish,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
