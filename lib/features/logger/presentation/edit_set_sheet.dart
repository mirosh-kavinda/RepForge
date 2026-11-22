import 'package:flutter/material.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../core/metrics/units.dart';
import '../domain/logger_rules.dart';
import '../domain/workout_session.dart';
import 'set_row.dart';

sealed class SetEdit {}

class SetChanged extends SetEdit {
  SetChanged(this.values);
  final SetValues values;
}

class SetDeleted extends SetEdit {}

// LOG-01 AC5: change or delete a logged set.
Future<SetEdit?> editSet(
  BuildContext context,
  SessionExercise row,
  LoggedSet set,
  UnitSystem units,
) {
  var values = (kg: set.kg, reps: set.reps, seconds: set.seconds);
  return showModalBottomSheet<SetEdit>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      final t = RfTextStyles.of(context);
      return StatefulBuilder(
        builder: (context, setState) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              RfSpace.s20,
              0,
              RfSpace.s20,
              RfSpace.s20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    '${row.name} · ${l10n.loggerEditSet(set.setNo)}',
                    style: t.heading,
                  ),
                ),
                const SizedBox(height: RfSpace.s12),
                SetSteppers(
                  row: row,
                  values: values,
                  units: units,
                  onChanged: (v) => setState(() => values = v),
                ),
                const SizedBox(height: RfSpace.s12),
                RfButton(
                  label: l10n.editorSave,
                  onPressed: () =>
                      Navigator.of(context).pop(SetChanged(values)),
                ),
                const SizedBox(height: RfSpace.s8),
                RfButton(
                  label: l10n.loggerDeleteSet,
                  variant: RfButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).pop(SetDeleted()),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
