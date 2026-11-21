import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

/// Temporary body for tabs whose slice has not shipped yet (FND-01).
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(AppLocalizations.of(context).placeholderComingSoon),
      ),
    );
  }
}
