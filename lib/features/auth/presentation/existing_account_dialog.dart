import 'package:flutter/material.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/widgets/rf_button.dart';

// AC8: null = cancelled (stay a guest), true = keep, false = discard.
Future<bool?> showExistingAccountDialog(BuildContext context) =>
    showDialog<bool>(
      context: context,
      builder: (context) => const ExistingAccountDialog(),
    );

class ExistingAccountDialog extends StatelessWidget {
  const ExistingAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.existingTitle),
      content: SingleChildScrollView(child: Text(l10n.existingBody)),
      actionsOverflowDirection: VerticalDirection.down,
      actions: [
        SizedBox(
          width: double.infinity,
          child: RfButton(
            label: l10n.existingKeep,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ),
        const SizedBox(height: RfSpace.s8),
        SizedBox(
          width: double.infinity,
          child: RfButton(
            label: l10n.existingDiscard,
            variant: RfButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ),
        const SizedBox(height: RfSpace.s8),
        SizedBox(
          width: double.infinity,
          child: RfButton(
            label: l10n.cancel,
            variant: RfButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}
