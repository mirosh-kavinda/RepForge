import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/rf_scales.dart';
import '../theme/rf_theme.dart';
import '../theme/rf_tokens.dart';
import '../theme/rf_typography.dart';
import 'rf_tappable.dart';

enum RfButtonVariant { primary, secondary, ghost }

enum RfButtonSize { lg, md }

class RfButton extends StatefulWidget {
  const RfButton({
    required this.label,
    required this.onPressed,
    this.variant = RfButtonVariant.primary,
    this.size = RfButtonSize.lg,
    this.loading = false,
    super.key,
  });

  static const surfaceKey = ValueKey('RfButton.surface');

  final String label;
  final VoidCallback? onPressed;
  final RfButtonVariant variant;
  final RfButtonSize size;
  final bool loading;

  @override
  State<RfButton> createState() => _RfButtonState();
}

class _RfButtonState extends State<RfButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  void _setPressed(bool value) {
    if (_enabled && _pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final l10n = AppLocalizations.of(context);

    // Pressed darkens the colour that carries the variant: fill for primary,
    // ink (text + outline) for secondary and ghost.
    final primary = widget.variant == RfButtonVariant.primary;
    final base = primary ? c.actionFill : c.actionInk;
    final shade = _pressed ? rfPressed(base) : base;
    final fill = primary ? shade : null;
    final foreground = primary ? c.onSolid : shade;
    final outline = widget.variant == RfButtonVariant.secondary
        ? Border.all(color: shade, width: 1.5)
        : null;

    final height = widget.size == RfButtonSize.lg
        ? RfSize.buttonLg
        : RfSize.buttonMd;

    final surface = DecoratedBox(
      key: RfButton.surfaceKey,
      decoration: BoxDecoration(
        color: fill,
        border: outline,
        borderRadius: BorderRadius.circular(RfRadius.md),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: height),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: RfSpace.s20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.loading) ...[
                SizedBox.square(
                  dimension: RfSpace.s16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: foreground,
                  ),
                ),
                const SizedBox(width: RfSpace.s8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: t.button.copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.loading ? '${widget.label}, ${l10n.loading}' : widget.label,
      onTap: _enabled ? widget.onPressed : null,
      excludeSemantics: true,
      child: RfTappable(
        radius: RfRadius.md,
        onTap: _enabled ? widget.onPressed : null,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: RfSize.minTarget,
            minWidth: RfSize.minTarget,
          ),
          child: Center(
            heightFactor: 1,
            widthFactor: 1,
            child: Opacity(
              opacity: widget.onPressed == null ? 0.4 : 1,
              child: surface,
            ),
          ),
        ),
      ),
    );
  }
}
