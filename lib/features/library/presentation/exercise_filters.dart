import 'package:flutter/material.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../app/widgets/rf_chip.dart';
import '../domain/exercise.dart';
import 'muscle_groups.dart';

// Muscle group chips and the equipment button, shared by the picker and the
// Library (WKT-01 AC3, EXL-01 AC3).
class ExerciseFilters extends StatelessWidget {
  const ExerciseFilters({
    required this.group,
    required this.equipment,
    required this.onGroup,
    required this.onEquipment,
    super.key,
  });

  final MuscleGroup? group;
  final Equipment? equipment;
  final ValueChanged<MuscleGroup?> onGroup;
  final ValueChanged<Equipment?> onEquipment;

  Future<void> _pickEquipment(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    const none = 'none';
    final picked = await showModalBottomSheet<Object>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: RadioGroup<Object>(
          groupValue: equipment ?? none,
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
    onEquipment(picked is Equipment ? picked : null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                    selected: group == g,
                    onSelected: (on) => onGroup(on ? g : null),
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
                equipment == null
                    ? l10n.pickerAll
                    : equipmentLabel(l10n, equipment!),
              ),
              variant: RfButtonVariant.secondary,
              size: RfButtonSize.md,
              onPressed: () => _pickEquipment(context),
            ),
          ),
        ),
      ],
    );
  }
}
