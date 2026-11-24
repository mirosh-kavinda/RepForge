import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../auth/presentation/verify_email_banner.dart';
import '../../goals/data/providers.dart';
import '../../goals/presentation/goal_card.dart';
import '../../schedule/data/providers.dart';
import 'streak_chip.dart';
import 'today_card.dart';

// Home, screen 01: the AUTH-01 verify notice, the PRG-02 streak and today's
// card. Scrolls so the card's actions fit at 200 % text (NFR-06).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Records missed / rest days while Home is shown (SCH-02 AC6, AC7).
    ref.listen(cycleSettlerProvider, (_, _) {});
    // Marks goals achieved as data arrives (GOL-01 AC6).
    ref.listen(goalSettlerProvider, (_, _) {});
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).appTitle)),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VerifyEmailBanner(),
            StreakChip(),
            TodayCard(),
            GoalCard(),
          ],
        ),
      ),
    );
  }
}
