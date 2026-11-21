import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';

// Screen 08. Hero art comes with the illustration set.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);

    Widget feature(IconData icon, Color tint, Color ink, String text) =>
        Padding(
          padding: const EdgeInsets.only(bottom: RfSpace.s12),
          child: Row(
            children: [
              Container(
                width: RfSpace.s32 + RfSpace.s4,
                height: RfSpace.s32 + RfSpace.s4,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(RfRadius.md),
                ),
                child: Icon(icon, size: RfSpace.s20, color: ink),
              ),
              const SizedBox(width: RfSpace.s12),
              Expanded(child: Text(text, style: t.label)),
            ],
          ),
        );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  RfSpace.s20,
                  RfSpace.s32,
                  RfSpace.s20,
                  RfSpace.s12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.appTitle, style: t.heading),
                    const SizedBox(height: RfSpace.s24),
                    Semantics(
                      header: true,
                      child: Text(l10n.welcomeHeadline, style: t.title),
                    ),
                    const SizedBox(height: RfSpace.s12),
                    Text(
                      l10n.welcomeBody,
                      style: t.body.copyWith(color: c.textSecondary),
                    ),
                    const SizedBox(height: RfSpace.s24),
                    feature(
                      Icons.calendar_month_outlined,
                      c.actionTint,
                      c.actionOnTint,
                      l10n.welcomeFeatureCycles,
                    ),
                    feature(
                      Icons.show_chart,
                      c.successTint,
                      c.successOnTint,
                      l10n.welcomeFeatureGhost,
                    ),
                    feature(
                      Icons.person_outline,
                      c.restTint,
                      c.restOnTint,
                      l10n.welcomeFeatureBody,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                RfSpace.s20,
                0,
                RfSpace.s20,
                RfSpace.s24,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: RfButton(
                      label: l10n.welcomeStart,
                      onPressed: () => context.go(Routes.signIn),
                    ),
                  ),
                  const SizedBox(height: RfSpace.s12),
                  SizedBox(
                    width: double.infinity,
                    child: RfButton(
                      label: l10n.welcomeAlreadyHaveAccount,
                      variant: RfButtonVariant.secondary,
                      onPressed: () => context.go(Routes.signIn),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
