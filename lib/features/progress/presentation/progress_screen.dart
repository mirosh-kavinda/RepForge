import 'package:flutter/material.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../body/presentation/body_card.dart';

// Screen 06. BOD-01 adds the Body card; PRG-01 adds charts.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).tabProgress)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(RfSpace.s16),
          children: const [BodyCard()],
        ),
      ),
    );
  }
}
