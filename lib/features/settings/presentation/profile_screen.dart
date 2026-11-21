import 'package:flutter/material.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/widgets/placeholder_screen.dart';
import '../../auth/presentation/account_section.dart';

/// Placeholder until its slice ships (FND-01 AC6); hosts the AUTH-01 account actions.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      header: const AccountSection(),
      title: AppLocalizations.of(context).tabProfile,
    );
  }
}
