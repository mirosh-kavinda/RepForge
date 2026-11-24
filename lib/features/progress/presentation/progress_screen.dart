import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/widgets/rf_segmented.dart';
import '../../body/presentation/body_card.dart';
import '../data/providers.dart';
import '../domain/progress_rules.dart';
import 'progress_charts.dart';
import 'progress_sections.dart';

// Screen 06: range switch, charts (PRG-01), Body card (BOD-01).
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final range = ref.watch(selectedRangeProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabProgress)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(RfSpace.s16),
          children: [
            RfSegmented<ProgressRange>(
              label: l10n.rangeLabel,
              options: {
                for (final r in ProgressRange.values) r: rangeName(l10n, r),
              },
              selected: range,
              onChanged: (r) {
                if (r != null) ref.read(selectedRangeProvider.notifier).set(r);
              },
            ),
            const SizedBox(height: RfSpace.s16),
            const StrengthSection(),
            const VolumeSection(),
            const BodyTrendsSection(),
            const BodyCard(),
          ],
        ),
      ),
    );
  }
}
