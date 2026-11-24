import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../core/clock.dart';
import '../../../data/sync/providers.dart';
import '../../../data/sync/remote_store.dart';
import '../../auth/data/providers.dart';

// SYN-01 AC9: "Backed up 5 min ago" and the like.
String backedUpText(
  AppLocalizations l10n,
  String locale,
  DateTime? at,
  DateTime now,
) {
  if (at == null) return l10n.backupNever;
  final ago = now.difference(at);
  if (ago.inMinutes < 1) return l10n.backupJustNow;
  if (ago.inHours < 1) return l10n.backupMinutes(ago.inMinutes);
  if (ago.inDays < 1) return l10n.backupHours(ago.inHours);
  return l10n.backupOn(DateFormat.yMMMd(locale).format(at));
}

String _reason(AppLocalizations l10n, SyncErrorKind k) => switch (k) {
  SyncErrorKind.offline => l10n.backupOffline,
  SyncErrorKind.signedOut => l10n.backupSignedOut,
  SyncErrorKind.server || SyncErrorKind.rejected => l10n.backupServer,
};

// Screen 24 (AC9, AC10).
class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  static const nowKey = ValueKey('backup.now');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final locale = Localizations.localeOf(context).toString();
    final user = ref.watch(currentUserProvider).value;
    final status = ref.watch(syncStatusProvider).value;
    final can = user?.canBackUp ?? false;
    final now = ref.read(clockProvider)();

    Widget line(String text, {bool strong = false}) => Padding(
      padding: const EdgeInsets.only(bottom: RfSpace.s8),
      child: Text(
        text,
        style: strong
            ? t.heading.copyWith(color: c.textPrimary)
            : t.body.copyWith(color: c.textSecondary),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(RfSpace.s16),
          children: [
            if (user == null || user.isGuest)
              line(l10n.backupGuest, strong: true)
            else if (!can)
              line(l10n.accountBackupAfterVerify, strong: true)
            else ...[
              line(
                backedUpText(l10n, locale, status?.backedUpAt, now),
                strong: true,
              ),
            ],
            if (status != null)
              line(
                status.waiting == 0
                    ? l10n.backupAllDone
                    : l10n.backupWaiting(status.waiting),
              ),
            if (can)
              if (status?.error case final e?) ...[
                line(l10n.backupFailed),
                line(_reason(l10n, e)),
              ],
            const SizedBox(height: RfSpace.s16),
            RfButton(
              key: nowKey,
              label: l10n.backupNow,
              onPressed: can
                  ? () => ref.read(syncSchedulerProvider).backUpNow()
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
