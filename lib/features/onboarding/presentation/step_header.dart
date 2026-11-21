import 'package:flutter/material.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';

// Progress bars + "Step n of total" (design canvas 10, 11). Two steps until
// SCH-01 adds the starter plan.
class StepHeader extends StatelessWidget {
  const StepHeader({required this.step, this.total = 2, super.key});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final label = AppLocalizations.of(context).onbStep('$step', '$total');
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 1; i <= total; i++) ...[
                if (i > 1) const SizedBox(width: RfSpace.s4),
                Expanded(
                  child: Container(
                    height: RfSpace.s4,
                    decoration: BoxDecoration(
                      color: i <= step ? c.actionFill : c.surface,
                      borderRadius: BorderRadius.circular(RfRadius.xs),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: RfSpace.s8),
          Text(label, style: t.label.copyWith(color: c.textSecondary)),
        ],
      ),
    );
  }
}
