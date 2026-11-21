import 'package:flutter/material.dart';

import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_tappable.dart';

// A goal option (design canvas 10): title, one-line meaning, radio mark.
// Selected adds a thicker accent border and a filled check, not colour only.
class GoalCard extends StatelessWidget {
  const GoalCard({
    required this.title,
    required this.hint,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String title;
  final String hint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: '$title. $hint',
      onTap: onTap,
      excludeSemantics: true,
      child: RfTappable(
        radius: RfRadius.lg,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: RfSize.minTarget),
          padding: const EdgeInsets.all(RfSpace.s16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(RfRadius.lg),
            border: Border.all(
              color: selected ? c.actionFill : c.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: t.labelStrong),
                    const SizedBox(height: RfSpace.s4),
                    Text(hint, style: t.label.copyWith(color: c.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: RfSpace.s12),
              Container(
                width: RfSpace.s24,
                height: RfSpace.s24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? c.actionFill : null,
                  border: selected
                      ? null
                      : Border.all(color: c.border, width: 2),
                ),
                child: selected
                    ? Icon(Icons.check, size: RfSpace.s16, color: c.onSolid)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
