import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../data/providers.dart';

// AC5: shown on Home until the email is verified; re-checked on launch and resume.
class VerifyEmailBanner extends ConsumerStatefulWidget {
  const VerifyEmailBanner({super.key});

  @override
  ConsumerState<VerifyEmailBanner> createState() => _VerifyEmailBannerState();
}

class _VerifyEmailBannerState extends ConsumerState<VerifyEmailBanner> {
  late final AppLifecycleListener _lifecycle;
  var _sent = false;
  var _sending = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _refresh);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  void _refresh() {
    if (mounted) ref.read(authRepositoryProvider).refresh();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _resend() async {
    setState(() => _sending = true);
    final failure = await ref.read(authRepositoryProvider).resendVerification();
    if (!mounted) return;
    setState(() {
      _sending = false;
      _sent = failure == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    if (user == null || !user.needsEmailVerification) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    return Semantics(
      container: true,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(RfSpace.s16),
        padding: const EdgeInsets.all(RfSpace.s16),
        decoration: BoxDecoration(
          color: c.actionTint,
          borderRadius: BorderRadius.circular(RfRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mark_email_unread_outlined, color: c.actionOnTint),
                const SizedBox(width: RfSpace.s8),
                Expanded(
                  child: Text(
                    l10n.verifyTitle,
                    style: t.labelStrong.copyWith(color: c.actionOnTint),
                  ),
                ),
              ],
            ),
            const SizedBox(height: RfSpace.s8),
            Text(
              l10n.verifyBody(user.email ?? ''),
              style: t.body.copyWith(color: c.actionOnTint),
            ),
            const SizedBox(height: RfSpace.s12),
            if (_sent)
              Semantics(
                liveRegion: true,
                child: Text(
                  l10n.verifySent,
                  style: t.label.copyWith(color: c.actionOnTint),
                ),
              )
            else
              RfButton(
                label: l10n.verifyResend,
                size: RfButtonSize.md,
                variant: RfButtonVariant.secondary,
                loading: _sending,
                onPressed: _resend,
              ),
          ],
        ),
      ),
    );
  }
}
