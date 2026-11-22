import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/widgets/placeholder_screen.dart';
import '../../auth/presentation/verify_email_banner.dart';
import '../../schedule/data/providers.dart';
import 'today_card.dart';

/// Placeholder until its slice ships (FND-01 AC6); hosts the AUTH-01 verify
/// notice and SCH-02's today card.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Records missed / rest days while Home is shown (SCH-02 AC6, AC7).
    ref.listen(cycleSettlerProvider, (_, _) {});
    return PlaceholderScreen(
      header: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [VerifyEmailBanner(), TodayCard()],
      ),
      title: AppLocalizations.of(context).appTitle,
    );
  }
}
