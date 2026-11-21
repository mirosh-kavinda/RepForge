import 'package:flutter/material.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/widgets/placeholder_screen.dart';
import '../../auth/presentation/verify_email_banner.dart';

/// Placeholder until its slice ships (FND-01 AC6); hosts the AUTH-01 verify notice.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      header: const VerifyEmailBanner(),
      title: AppLocalizations.of(context).appTitle,
    );
  }
}
