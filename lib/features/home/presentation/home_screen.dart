import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/placeholder_screen.dart';
import '../../../core/clock.dart';
import '../../auth/presentation/verify_email_banner.dart';
import '../../schedule/data/providers.dart';
import '../../schedule/domain/cycle_rules.dart';
import '../../workout/data/providers.dart';

/// Placeholder until its slice ships (FND-01 AC6); hosts the AUTH-01 verify
/// notice and SCH-01's day in the cycle.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      header: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [VerifyEmailBanner(), TodayInCycle()],
      ),
      title: AppLocalizations.of(context).appTitle,
    );
  }
}

// SCH-01 AC7: "Day n of N · Push" or "· Rest".
class TodayInCycle extends ConsumerWidget {
  const TodayInCycle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final active = ref.watch(activeCycleProvider);
    if (!active.hasValue) return const SizedBox.shrink();
    final cycle = active.value;
    final String text;
    if (cycle == null) {
      text = l10n.homeNoCycle;
    } else {
      final i = dayIndexOn(cycle, ref.watch(clockProvider)());
      final day = cycle.days[i];
      final workouts = ref.watch(templatesProvider).value ?? const [];
      final name = day.isRest
          ? l10n.cycleRest
          : workouts.where((w) => w.id == day.workoutId).firstOrNull?.name ??
                l10n.cycleWorkoutDeleted;
      text = l10n.homeToday(i + 1, cycle.days.length, name);
    }
    return Padding(
      padding: const EdgeInsets.all(RfSpace.s20),
      child: Text(
        text,
        style: cycle == null
            ? t.body.copyWith(color: c.textSecondary)
            : t.heading,
      ),
    );
  }
}
