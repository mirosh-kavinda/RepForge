import 'package:flutter/material.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/widgets/placeholder_screen.dart';

/// Placeholder until its slice ships (FND-01 AC6).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(title: AppLocalizations.of(context).tabProfile);
  }
}
