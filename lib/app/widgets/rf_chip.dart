import 'package:flutter/material.dart';

import '../theme/rf_scales.dart';
import '../theme/rf_tokens.dart';
import '../theme/rf_typography.dart';
import 'rf_tappable.dart';

class RfChip extends StatelessWidget {
  const RfChip.filter({
    required this.label,
    required bool this.selected,
    required ValueChanged<bool> this.onSelected,
    super.key,
  }) : role = null;

  const RfChip.status({
    required this.label,
    required RfRole this.role,
    super.key,
  }) : selected = null,
       onSelected = null;

  static const surfaceKey = ValueKey('RfChip.surface');

  final String label;
  final bool? selected;
  final ValueChanged<bool>? onSelected;
  final RfRole? role;

  @override
  Widget build(BuildContext context) {
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);

    final Color? fill;
    final Color text;
    Border? border;
    if (role case final role?) {
      fill = c.tint(role);
      text = c.onTint(role);
    } else if (selected!) {
      fill = c.actionFill;
      text = c.onSolid;
    } else {
      fill = null;
      text = c.textSecondary;
      border = Border.all(color: c.textMuted);
    }

    final chip = DecoratedBox(
      key: surfaceKey,
      decoration: BoxDecoration(
        color: fill,
        border: border,
        borderRadius: BorderRadius.circular(RfRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: RfSpace.s12,
          vertical: RfSpace.s4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected ?? false) ...[
              Icon(Icons.check, size: RfSpace.s16, color: text),
              const SizedBox(width: RfSpace.s4),
            ],
            Flexible(
              child: Text(label, style: t.labelStrong.copyWith(color: text)),
            ),
          ],
        ),
      ),
    );

    final onSelected = this.onSelected;
    if (onSelected == null) {
      return Semantics(label: label, excludeSemantics: true, child: chip);
    }
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: () => onSelected(!selected!),
      excludeSemantics: true,
      child: RfTappable(
        radius: RfRadius.pill,
        onTap: () => onSelected(!selected!),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: RfSize.minTarget,
            minWidth: RfSize.minTarget,
          ),
          child: Center(widthFactor: 1, heightFactor: 1, child: chip),
        ),
      ),
    );
  }
}
