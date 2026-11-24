import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../data/sync/providers.dart';

// SYN-02 AC3: older history still coming down after a restore.
class RestoringLine extends ConsumerWidget {
  const RestoringLine({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(restoreProgressProvider).value;
    if (p == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        RfSpace.s20,
        RfSpace.s12,
        RfSpace.s20,
        0,
      ),
      child: Semantics(
        liveRegion: true,
        child: Row(
          children: [
            SizedBox.square(
              dimension: RfSize.iconSm,
              child: CircularProgressIndicator(
                strokeWidth: RfStroke.medium,
                value: p.total == 0 ? null : p.done / p.total,
                color: c.actionFill,
              ),
            ),
            const SizedBox(width: RfSpace.s8),
            Expanded(
              child: Text(
                l10n.restoringHome,
                style: t.label.copyWith(color: c.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
