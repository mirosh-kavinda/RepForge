import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/rf_scales.dart';
import '../theme/rf_tokens.dart';
import '../theme/rf_typography.dart';
import 'rf_tappable.dart';

class RfStepper extends StatefulWidget {
  const RfStepper({
    required this.label,
    required this.value,
    required this.step,
    required this.min,
    required this.max,
    required this.onChanged,
    this.unit,
    this.format,
    super.key,
  }) : assert(step > 0),
       assert(min < max);

  static const valueKey = ValueKey('RfStepper.value');
  static const repeatInterval = Duration(milliseconds: 120);

  final String label;
  final double value;
  final double step;
  final double min;
  final double max;
  final String? unit;
  // Replaces the number and unit, e.g. m:ss for rest times.
  final String Function(double value)? format;
  final ValueChanged<double> onChanged;

  @override
  State<RfStepper> createState() => _RfStepperState();
}

class _RfStepperState extends State<RfStepper> {
  Timer? _repeat;
  late double _value = _clamp(widget.value);

  double _clamp(double v) => v.clamp(widget.min, widget.max).toDouble();

  int get _decimals {
    final text = widget.step.toString();
    return text.contains('.')
        ? text.split('.').last.replaceAll(RegExp(r'0+$'), '').length
        : 0;
  }

  // Values are rounded to the step's decimal places so 70 + 3 × 0.1 is 70.3,
  // not 70.30000000000001.
  double _round(double v) {
    final f = math.pow(10, _decimals);
    return (v * f).round() / f;
  }

  // Steps are counted from min, so an off-grid value (61 with step 2.5)
  // snaps to the grid on the next tap.
  double? _next(int direction) {
    final steps = (_value - widget.min) / widget.step;
    final n = direction > 0
        ? (steps + 1e-9).floor() + 1
        : (steps - 1e-9).ceil() - 1;
    final next = _clamp(_round(widget.min + n * widget.step));
    return next == _value ? null : next;
  }

  String _format(double v) {
    if (widget.format case final format?) return format(v);
    final number = NumberFormat.decimalPatternDigits(
      locale: 'en',
      decimalDigits: 0,
    )..maximumFractionDigits = _decimals;
    final text = number.format(v);
    return widget.unit == null ? text : '$text ${widget.unit}';
  }

  bool _apply(int direction) {
    final next = _next(direction);
    if (next == null) return false;
    setState(() => _value = next);
    HapticFeedback.selectionClick();
    widget.onChanged(next);
    return true;
  }

  void _startRepeat(int direction) {
    if (!_apply(direction)) return;
    _repeat?.cancel();
    _repeat = Timer.periodic(RfStepper.repeatInterval, (_) {
      if (!_apply(direction)) _stopRepeat();
    });
  }

  void _stopRepeat() {
    _repeat?.cancel();
    _repeat = null;
  }

  @override
  void didUpdateWidget(RfStepper old) {
    super.didUpdateWidget(old);
    _value = _clamp(widget.value);
  }

  @override
  void dispose() {
    _stopRepeat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final up = _next(1);
    final down = _next(-1);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(
          icon: Icons.remove,
          label: l10n.stepperDecrease(widget.label),
          hint: down == null ? l10n.stepperAtMin : null,
          onTap: down == null ? null : () => _apply(-1),
          onHoldStart: () => _startRepeat(-1),
          onHoldEnd: _stopRepeat,
        ),
        Flexible(
          child: Semantics(
            key: RfStepper.valueKey,
            label: widget.label,
            value: _format(_value),
            increasedValue: up == null ? null : _format(up),
            decreasedValue: down == null ? null : _format(down),
            onIncrease: up == null ? null : () => _apply(1),
            onDecrease: down == null ? null : () => _apply(-1),
            liveRegion: true,
            excludeSemantics: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: RfSpace.s8),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: widget.format == null
                          ? _format(_value).split(' ').first
                          : _format(_value),
                      style: t.heading.copyWith(color: c.textPrimary),
                    ),
                    if (widget.unit != null && widget.format == null)
                      TextSpan(
                        text: ' ${widget.unit}',
                        style: t.label.copyWith(color: c.textSecondary),
                      ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        _StepButton(
          icon: Icons.add,
          label: l10n.stepperIncrease(widget.label),
          hint: up == null ? l10n.stepperAtMax : null,
          onTap: up == null ? null : () => _apply(1),
          onHoldStart: () => _startRepeat(1),
          onHoldEnd: _stopRepeat,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.onHoldStart,
    required this.onHoldEnd,
    this.hint,
  });

  final IconData icon;
  final String label;
  final String? hint;
  final VoidCallback? onTap;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;

  @override
  Widget build(BuildContext context) {
    final c = RfColors.of(context);
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      hint: hint,
      onTap: onTap,
      excludeSemantics: true,
      child: RfTappable(
        radius: RfRadius.md,
        onTap: onTap,
        onLongPressStart: (_) => onHoldStart(),
        onLongPressEnd: onHoldEnd,
        child: SizedBox.square(
          dimension: RfSize.minTarget,
          child: Center(
            child: Opacity(
              opacity: enabled ? 1 : 0.4,
              child: Container(
                width: RfSize.stepperButton,
                height: RfSize.stepperButton,
                decoration: BoxDecoration(
                  color: c.surface,
                  border: Border.all(color: c.textMuted),
                  borderRadius: BorderRadius.circular(RfRadius.md),
                ),
                child: Icon(icon, color: c.textPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
