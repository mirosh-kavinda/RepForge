import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../progress/data/providers.dart';

// PRG-02 AC1: the current streak; tapping opens Progress. Hidden with no
// schedule history, until it loads, and on an error, so Home never waits.
class StreakChip extends ConsumerWidget {
  const StreakChip({super.key});

  static const chipKey = ValueKey('home.streak');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.watch(streakProvider).value;
    if (n == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final text = n == 0 ? l10n.streakStart : l10n.streakDays(n);
    void open() => context.go(Routes.progress);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        RfSpace.s20,
        RfSpace.s12,
        RfSpace.s20,
        0,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Semantics(
          button: true,
          hint: l10n.streakChipHint,
          excludeSemantics: true,
          label: text,
          onTap: open,
          child: Material(
            color: c.actionTint,
            borderRadius: BorderRadius.circular(RfRadius.pill),
            child: InkWell(
              key: chipKey,
              borderRadius: BorderRadius.circular(RfRadius.pill),
              onTap: open,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: RfSize.minTarget,
                  minWidth: RfSize.minTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RfSpace.s16,
                    vertical: RfSpace.s8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department_outlined,
                        color: c.actionOnTint,
                      ),
                      const SizedBox(width: RfSpace.s8),
                      Flexible(
                        child: Text(
                          text,
                          style: t.labelStrong.copyWith(color: c.actionOnTint),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
