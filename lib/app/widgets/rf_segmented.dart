import 'package:flutter/material.dart';

import '../theme/rf_scales.dart';
import '../theme/rf_tokens.dart';
import '../theme/rf_typography.dart';
import 'rf_tappable.dart';

// Segmented single choice (design canvas 10, 11). The selected segment is
// inverted and bold, so it differs in lightness and weight, not hue alone.
class RfSegmented<T> extends StatelessWidget {
  const RfSegmented({
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.allowNone = true,
    this.disabled = const {},
    super.key,
  });

  final String label;
  final Map<T, String> options;
  final T? selected;
  final ValueChanged<T?> onChanged;

  // When true, tapping the selected segment clears the choice.
  final bool allowNone;

  // Options shown but not choosable; the caller says why in text.
  final Set<T> disabled;

  void _tap(T value) =>
      onChanged(value == selected && allowNone ? null : value);

  @override
  Widget build(BuildContext context) {
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    return Semantics(
      container: true,
      label: label,
      child: Container(
        padding: const EdgeInsets.all(RfSpace.s4),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(RfRadius.md),
        ),
        child: Row(
          children: [
            for (final MapEntry(key: value, value: text) in options.entries)
              Expanded(
                child: Semantics(
                  button: true,
                  enabled: !disabled.contains(value),
                  selected: value == selected,
                  inMutuallyExclusiveGroup: true,
                  label: text,
                  onTap: disabled.contains(value) ? null : () => _tap(value),
                  excludeSemantics: true,
                  child: RfTappable(
                    radius: RfRadius.sm,
                    onTap: disabled.contains(value) ? null : () => _tap(value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      constraints: const BoxConstraints(
                        minHeight: RfSize.minTarget,
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: RfSpace.s8,
                        vertical: RfSpace.s8,
                      ),
                      decoration: BoxDecoration(
                        color: value == selected ? c.textPrimary : null,
                        borderRadius: BorderRadius.circular(RfRadius.sm),
                      ),
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        style: value == selected
                            ? t.labelStrong.copyWith(color: c.bg)
                            : t.label.copyWith(
                                color: disabled.contains(value)
                                    ? c.textMuted
                                    : c.textSecondary,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
