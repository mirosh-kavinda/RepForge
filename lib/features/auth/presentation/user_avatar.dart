import 'package:flutter/material.dart';

import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../domain/auth_user.dart';

// Provider photo when allowed and available, else initials (AUTH-01 AC13).
class UserAvatar extends StatelessWidget {
  const UserAvatar({required this.user, required this.showPhoto, super.key});

  final AuthUser? user;
  final bool showPhoto;

  @override
  Widget build(BuildContext context) {
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final photo = showPhoto ? user?.photoUrl : null;
    final initials = user?.initials ?? '';
    return ExcludeSemantics(
      child: CircleAvatar(
        radius: RfSpace.s24,
        backgroundColor: c.actionTint,
        foregroundImage: photo == null ? null : NetworkImage(photo),
        child: initials.isEmpty
            ? Icon(Icons.person_outline, color: c.actionOnTint)
            : Text(
                initials,
                style: t.labelStrong.copyWith(color: c.actionOnTint),
              ),
      ),
    );
  }
}
