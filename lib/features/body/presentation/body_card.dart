import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../app/widgets/rf_tappable.dart';
import '../../../core/metrics/units.dart';
import '../../onboarding/data/providers.dart';
import '../data/providers.dart';
import 'body_history_screen.dart';
import 'body_results.dart';

// BOD-01 AC1: the latest snapshot on the Progress tab.
class BodyCard extends ConsumerWidget {
  const BodyCard({super.key});

  static const newKey = ValueKey('bodyCard.new');
  static const openKey = ValueKey('bodyCard.open');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final units = ref.watch(unitSystemProvider).value ?? UnitSystem.metric;
    final all = ref.watch(bodySnapshotsProvider).value;
    final latest = all?.firstOrNull;
    final locale = Localizations.localeOf(context).toString();

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(header: true, child: Text(l10n.bodyTitle, style: t.heading)),
        const SizedBox(height: RfSpace.s8),
        // Nothing while loading, so an empty card never flashes (AC1).
        if (all == null)
          const SizedBox.shrink()
        else if (latest == null)
          Text(l10n.bodyNone, style: t.body.copyWith(color: c.textSecondary))
        else ...[
          Text(
            DateFormat.yMMMEd(locale).format(latest.date),
            style: t.label.copyWith(color: c.textSecondary),
          ),
          Text(
            snapshotSummary(l10n, latest, units),
            style: t.body.copyWith(color: c.textPrimary),
          ),
          if (latest.results case final r?)
            BodyResultsList(
              results: r,
              units: units,
              fatFromScale: latest.fatFromScale,
            ),
        ],
        const SizedBox(height: RfSpace.s12),
        Align(
          alignment: Alignment.centerLeft,
          child: RfButton(
            key: newKey,
            label: l10n.bodyNew,
            size: RfButtonSize.md,
            onPressed: () => context.push(Routes.bodyNew),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      label: l10n.bodyOpenHistory,
      onTap: () => context.push(Routes.body),
      child: RfTappable(
        key: openKey,
        radius: RfRadius.lg,
        onTap: () => context.push(Routes.body),
        child: Container(
          padding: const EdgeInsets.all(RfSpace.s16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(RfRadius.lg),
          ),
          child: body,
        ),
      ),
    );
  }
}
