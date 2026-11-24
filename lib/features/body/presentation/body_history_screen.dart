import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_tappable.dart';
import '../../../core/clock.dart';
import '../../../core/metrics/units.dart';
import '../../onboarding/data/providers.dart';
import '../data/providers.dart';
import '../domain/body_rules.dart';
import '../domain/body_snapshot.dart';
import 'body_results.dart';

String _date(BuildContext context, DateTime d) =>
    DateFormat.yMMMEd(Localizations.localeOf(context).toString()).format(d);

// AC7: "82.5 kg · Body fat 18.0 % · from scale".
String snapshotSummary(AppLocalizations l10n, BodySnapshot s, UnitSystem u) {
  final fat = s.results?[BodyMetric.bodyFat]?.valueOrNull;
  return [
    if (s.weightKg case final w?) weightText(l10n, w, u),
    l10n.bodyRowFat(fat == null ? '—' : pctText(l10n, fat)),
    if (fat != null && s.fatFromScale) l10n.bodyFromScale,
  ].join(' · ');
}

class BodyHistoryScreen extends ConsumerWidget {
  const BodyHistoryScreen({super.key});

  static const newKey = ValueKey('bodyHistory.new');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final units = ref.watch(unitSystemProvider).value ?? UnitSystem.metric;
    final all = ref.watch(bodySnapshotsProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bodyHistoryTitle),
        actions: [
          IconButton(
            key: newKey,
            tooltip: l10n.bodyNew,
            icon: const Icon(Icons.add),
            onPressed: () => context.push(Routes.bodyNew),
          ),
        ],
      ),
      body: SafeArea(
        child: switch (all) {
          null => const Center(child: CircularProgressIndicator()),
          [] => Center(
            child: Text(
              l10n.bodyNone,
              style: t.body.copyWith(color: c.textSecondary),
            ),
          ),
          final list => ListView.separated(
            padding: const EdgeInsets.all(RfSpace.s16),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: RfSpace.s8),
            itemBuilder: (context, i) {
              final s = list[i];
              final date = _date(context, s.date);
              final summary = snapshotSummary(l10n, s, units);
              return Semantics(
                button: true,
                excludeSemantics: true,
                label: '$date, $summary',
                onTap: () => context.push(Routes.bodySnapshot(s.id)),
                child: RfTappable(
                  radius: RfRadius.lg,
                  onTap: () => context.push(Routes.bodySnapshot(s.id)),
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: RfSize.minTarget,
                    ),
                    padding: const EdgeInsets.all(RfSpace.s12),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(RfRadius.lg),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(date, style: t.labelStrong),
                        Text(
                          summary,
                          style: t.label.copyWith(color: c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        },
      ),
    );
  }
}

// AC7: one saved snapshot, read-only; delete with Undo.
class BodySnapshotScreen extends ConsumerWidget {
  const BodySnapshotScreen({required this.id, super.key});

  static const deleteKey = ValueKey('bodySnapshot.delete');

  final String id;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(bodyRepositoryProvider);
    try {
      await repo.delete(id);
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.bodyDeleteFailed)));
      return;
    }
    if (context.mounted) context.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.bodyDeleted),
        action: SnackBarAction(
          label: l10n.bodyUndo,
          onPressed: () async {
            try {
              await repo.restore(id);
            } on Object {
              messenger.showSnackBar(
                SnackBar(content: Text(l10n.bodySaveFailed)),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final units = ref.watch(unitSystemProvider).value ?? UnitSystem.metric;
    final s = ref.watch(bodySnapshotProvider(id)).value;
    if (s == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    // Onboarding snapshots saved no results: worked out on view, not stored.
    final profile = ref.watch(bodyProfileProvider).value;
    final results =
        s.results ??
        (s.weightKg == null || profile == null
            ? null
            : computeBodyResults(
                BodyInput(
                  weightKg: s.weightKg!,
                  activity: s.activity ?? profile.activity ?? defaultActivity,
                  waistCm: s.waistCm,
                ),
                profile,
                ref.read(clockProvider)(),
              ));

    Widget input(String label, String value, String spoken) => Padding(
      padding: const EdgeInsets.only(top: RfSpace.s4),
      child: Semantics(
        container: true,
        excludeSemantics: true,
        label: '$label, $spoken',
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: t.body.copyWith(color: c.textSecondary),
              ),
            ),
            Text(value, style: t.body.copyWith(color: c.textPrimary)),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_date(context, s.date)),
        actions: [
          IconButton(
            key: deleteKey,
            tooltip: l10n.bodyDelete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(RfSpace.s16),
          children: [
            if (s.weightKg case final w?)
              input(
                l10n.bodyWeight,
                weightText(l10n, w, units),
                spokenWeight(l10n, w, units),
              ),
            if (s.waistCm case final v?)
              input(
                l10n.bodyWaist,
                lengthText(l10n, v, units),
                spokenLength(l10n, v, units),
              ),
            if (s.neckCm case final v?)
              input(
                l10n.bodyNeck,
                lengthText(l10n, v, units),
                spokenLength(l10n, v, units),
              ),
            if (s.hipCm case final v?)
              input(
                l10n.bodyHip,
                lengthText(l10n, v, units),
                spokenLength(l10n, v, units),
              ),
            const SizedBox(height: RfSpace.s16),
            if (results != null)
              BodyResultsList(
                results: results,
                units: units,
                fatFromScale: s.fatFromScale,
              ),
          ],
        ),
      ),
    );
  }
}
