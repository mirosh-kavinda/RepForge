import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/rf_scales.dart';
import '../theme/rf_tokens.dart';
import '../theme/rf_typography.dart';
import 'rf_tappable.dart';

enum RfDayState { done, today, rest, missed, planned }

class RfDayTile extends StatelessWidget {
  const RfDayTile({
    required this.day,
    required this.state,
    this.onTap,
    super.key,
  });

  static const surfaceKey = ValueKey('RfDayTile.surface');
  static const dashedKey = ValueKey('RfDayTile.dashed');

  final int day;
  final RfDayState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final l10n = AppLocalizations.of(context);

    final (label, fill, text, border) = switch (state) {
      RfDayState.done => (l10n.dayDone, c.successTint, c.successOnTint, null),
      RfDayState.rest => (l10n.dayRest, c.restTint, c.restOnTint, null),
      RfDayState.missed => (l10n.dayMissed, c.missedTint, c.missedOnTint, null),
      RfDayState.today => (
        l10n.dayToday,
        c.surface,
        c.textPrimary,
        Border.all(color: c.actionInk, width: 2),
      ),
      RfDayState.planned => (l10n.dayPlanned, c.surface, c.textSecondary, null),
    };

    Widget tile = DecoratedBox(
      key: surfaceKey,
      decoration: BoxDecoration(
        color: fill,
        border: border,
        borderRadius: BorderRadius.circular(RfRadius.sm),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: RfSize.minTarget,
          minHeight: RfSize.minTarget,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RfSpace.s4,
            vertical: RfSpace.s4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$day', style: t.labelStrong.copyWith(color: text)),
              Text(label, style: t.overline.copyWith(color: text)),
            ],
          ),
        ),
      ),
    );

    if (state == RfDayState.planned) {
      tile = CustomPaint(
        key: dashedKey,
        foregroundPainter: _DashedBorderPainter(c.textMuted),
        child: tile,
      );
    }

    return Semantics(
      button: onTap != null,
      label: '$day, $label',
      onTap: onTap,
      excludeSemantics: true,
      child: RfTappable(radius: RfRadius.sm, onTap: onTap, child: tile),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.75),
          const Radius.circular(RfRadius.sm),
        ),
      );
    for (final PathMetric metric in outline.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 7) {
        canvas.drawPath(metric.extractPath(d, d + 4), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}
