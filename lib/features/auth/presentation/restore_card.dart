import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../data/sync/providers.dart';

// The card where it doesn't lead anywhere after a choice: Home and Backup
// and sync, so a choice skipped on Account can still be made (AC1).
class HomeRestoreCard extends StatelessWidget {
  const HomeRestoreCard({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: RfSpace.s16),
    child: RestoreCard(onDone: () {}),
  );
}

// SYN-02 AC1, AC2, AC6, AC10: shown on Account (09b) when the account has a
// backup and this phone hasn't chosen yet. [onDone] continues as Continue does.
class RestoreCard extends ConsumerStatefulWidget {
  const RestoreCard({required this.onDone, super.key});

  final VoidCallback onDone;

  static const restoreKey = ValueKey('restore.restore');
  static const freshKey = ValueKey('restore.fresh');

  @override
  ConsumerState<RestoreCard> createState() => _RestoreCardState();
}

class _RestoreCardState extends ConsumerState<RestoreCard> {
  var _busy = false;
  var _failed = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await action();
    } on Object {
      if (mounted) {
        setState(() {
          _busy = false;
          _failed = true;
        });
      }
      return;
    }
    if (mounted) {
      setState(() => _busy = false);
      widget.onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(backupSummaryProvider).value;
    if (summary == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final locale = Localizations.localeOf(context).toString();
    final online = ref.watch(onlineProvider).value ?? true;
    final controller = ref.read(restoreControllerProvider);

    return Container(
      margin: const EdgeInsets.only(top: RfSpace.s16),
      padding: const EdgeInsets.all(RfSpace.s16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(RfRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.restoreTitle(
                DateFormat.yMMMd(locale).format(summary.newest.toLocal()),
              ),
              style: t.heading.copyWith(color: c.textPrimary),
            ),
          ),
          Text(
            l10n.restoreWorkouts(summary.workouts),
            style: t.body.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: RfSpace.s8),
          Text(
            l10n.restoreBody,
            style: t.label.copyWith(color: c.textSecondary),
          ),
          if (!online || _failed) ...[
            const SizedBox(height: RfSpace.s8),
            Text(
              online ? l10n.restoreFailed : l10n.restoreNeedsConnection,
              style: t.body.copyWith(color: c.textPrimary),
            ),
          ],
          const SizedBox(height: RfSpace.s12),
          RfButton(
            key: RestoreCard.restoreKey,
            label: _failed ? l10n.restoreTryAgain : l10n.restoreRestore,
            loading: _busy,
            onPressed: online && !_busy ? () => _run(controller.restore) : null,
          ),
          const SizedBox(height: RfSpace.s8),
          RfButton(
            key: RestoreCard.freshKey,
            label: l10n.restoreFresh,
            variant: RfButtonVariant.secondary,
            onPressed: _busy ? null : () => _run(controller.startFresh),
          ),
        ],
      ),
    );
  }
}
