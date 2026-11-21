// Values mirror docs/design.md; rf_tokens_test parses it, so change both together.
import 'package:flutter/material.dart';

enum RfRole { action, success, rest, missed }

@immutable
class RfColors extends ThemeExtension<RfColors> {
  const RfColors({
    required this.bg,
    required this.navBar,
    required this.surface,
    required this.divider,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.onSolid,
    required this.actionFill,
    required this.actionInk,
    required this.actionTint,
    required this.actionOnTint,
    required this.successFill,
    required this.successInk,
    required this.successTint,
    required this.successOnTint,
    required this.successBorder,
    required this.restFill,
    required this.restInk,
    required this.restTint,
    required this.restOnTint,
    required this.missedFill,
    required this.missedInk,
    required this.missedTint,
    required this.missedOnTint,
  });

  static const dark = RfColors(
    bg: Color(0xFF0E0F12),
    navBar: Color(0xFF15171C),
    surface: Color(0xFF1A1C22),
    divider: Color(0xFF23262D),
    border: Color(0xFF2A2D35),
    textPrimary: Color(0xFFF4F5F7),
    textSecondary: Color(0xFFC9CED8),
    textMuted: Color(0xFF8A93A6),
    onSolid: Color(0xFF0E0F12),
    actionFill: Color(0xFFFF6B2C),
    actionInk: Color(0xFFFF8A55),
    actionTint: Color(0xFF2A1A12),
    actionOnTint: Color(0xFFFF8A55),
    successFill: Color(0xFFC8F560),
    successInk: Color(0xFFC8F560),
    successTint: Color(0xFF20241A),
    successOnTint: Color(0xFFC8F560),
    successBorder: Color(0xFF5C7A2A),
    restFill: Color(0xFF5AA9FF),
    restInk: Color(0xFF8CC4FF),
    restTint: Color(0xFF13233A),
    restOnTint: Color(0xFF8CC4FF),
    missedFill: Color(0xFFFF5D5D),
    missedInk: Color(0xFFFF9A9A),
    missedTint: Color(0xFF4A1E1E),
    missedOnTint: Color(0xFFFF9A9A),
  );

  static const light = RfColors(
    bg: Color(0xFFF3F4F6),
    navBar: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    divider: Color(0xFFE6E8EC),
    border: Color(0xFFD9DCE2),
    textPrimary: Color(0xFF12141A),
    textSecondary: Color(0xFF3D4350),
    textMuted: Color(0xFF5E6678),
    onSolid: Color(0xFF0E0F12),
    actionFill: Color(0xFFFF6B2C),
    actionInk: Color(0xFFC2410C),
    actionTint: Color(0xFFFFE4D5),
    actionOnTint: Color(0xFF9A3412),
    successFill: Color(0xFFC8F560),
    successInk: Color(0xFF3F6212),
    successTint: Color(0xFFD5EDA6),
    successOnTint: Color(0xFF3F6212),
    successBorder: Color(0xFF5E8A18),
    restFill: Color(0xFF5AA9FF),
    restInk: Color(0xFF1D5FB0),
    restTint: Color(0xFFDCEBFF),
    restOnTint: Color(0xFF144A8C),
    missedFill: Color(0xFFFF5D5D),
    missedInk: Color(0xFFB91C1C),
    missedTint: Color(0xFFFFDADA),
    missedOnTint: Color(0xFF8F1A1A),
  );

  static RfColors of(BuildContext context) =>
      Theme.of(context).extension<RfColors>()!;

  final Color bg;

  final Color navBar;

  final Color surface;

  final Color divider;

  final Color border;

  final Color textPrimary;

  final Color textSecondary;

  final Color textMuted;

  final Color onSolid;

  final Color actionFill;

  final Color actionInk;

  final Color actionTint;

  final Color actionOnTint;

  final Color successFill;

  final Color successInk;

  final Color successTint;

  final Color successOnTint;

  final Color successBorder;

  final Color restFill;

  final Color restInk;

  final Color restTint;

  final Color restOnTint;

  final Color missedFill;

  final Color missedInk;

  final Color missedTint;

  final Color missedOnTint;

  Color fill(RfRole role) => switch (role) {
    RfRole.action => actionFill,
    RfRole.success => successFill,
    RfRole.rest => restFill,
    RfRole.missed => missedFill,
  };

  Color ink(RfRole role) => switch (role) {
    RfRole.action => actionInk,
    RfRole.success => successInk,
    RfRole.rest => restInk,
    RfRole.missed => missedInk,
  };

  Color tint(RfRole role) => switch (role) {
    RfRole.action => actionTint,
    RfRole.success => successTint,
    RfRole.rest => restTint,
    RfRole.missed => missedTint,
  };

  Color onTint(RfRole role) => switch (role) {
    RfRole.action => actionOnTint,
    RfRole.success => successOnTint,
    RfRole.rest => restOnTint,
    RfRole.missed => missedOnTint,
  };

  Map<String, Color> toMap() => {
    'bg': bg,
    'navBar': navBar,
    'surface': surface,
    'divider': divider,
    'border': border,
    'textPrimary': textPrimary,
    'textSecondary': textSecondary,
    'textMuted': textMuted,
    'onSolid': onSolid,
    'actionFill': actionFill,
    'actionInk': actionInk,
    'actionTint': actionTint,
    'actionOnTint': actionOnTint,
    'successFill': successFill,
    'successInk': successInk,
    'successTint': successTint,
    'successOnTint': successOnTint,
    'successBorder': successBorder,
    'restFill': restFill,
    'restInk': restInk,
    'restTint': restTint,
    'restOnTint': restOnTint,
    'missedFill': missedFill,
    'missedInk': missedInk,
    'missedTint': missedTint,
    'missedOnTint': missedOnTint,
  };

  @override
  RfColors copyWith({
    Color? bg,
    Color? navBar,
    Color? surface,
    Color? divider,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? onSolid,
    Color? actionFill,
    Color? actionInk,
    Color? actionTint,
    Color? actionOnTint,
    Color? successFill,
    Color? successInk,
    Color? successTint,
    Color? successOnTint,
    Color? successBorder,
    Color? restFill,
    Color? restInk,
    Color? restTint,
    Color? restOnTint,
    Color? missedFill,
    Color? missedInk,
    Color? missedTint,
    Color? missedOnTint,
  }) {
    return RfColors(
      bg: bg ?? this.bg,
      navBar: navBar ?? this.navBar,
      surface: surface ?? this.surface,
      divider: divider ?? this.divider,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      onSolid: onSolid ?? this.onSolid,
      actionFill: actionFill ?? this.actionFill,
      actionInk: actionInk ?? this.actionInk,
      actionTint: actionTint ?? this.actionTint,
      actionOnTint: actionOnTint ?? this.actionOnTint,
      successFill: successFill ?? this.successFill,
      successInk: successInk ?? this.successInk,
      successTint: successTint ?? this.successTint,
      successOnTint: successOnTint ?? this.successOnTint,
      successBorder: successBorder ?? this.successBorder,
      restFill: restFill ?? this.restFill,
      restInk: restInk ?? this.restInk,
      restTint: restTint ?? this.restTint,
      restOnTint: restOnTint ?? this.restOnTint,
      missedFill: missedFill ?? this.missedFill,
      missedInk: missedInk ?? this.missedInk,
      missedTint: missedTint ?? this.missedTint,
      missedOnTint: missedOnTint ?? this.missedOnTint,
    );
  }

  @override
  RfColors lerp(RfColors? other, double t) {
    if (other == null) return this;
    return RfColors(
      bg: Color.lerp(bg, other.bg, t)!,
      navBar: Color.lerp(navBar, other.navBar, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      onSolid: Color.lerp(onSolid, other.onSolid, t)!,
      actionFill: Color.lerp(actionFill, other.actionFill, t)!,
      actionInk: Color.lerp(actionInk, other.actionInk, t)!,
      actionTint: Color.lerp(actionTint, other.actionTint, t)!,
      actionOnTint: Color.lerp(actionOnTint, other.actionOnTint, t)!,
      successFill: Color.lerp(successFill, other.successFill, t)!,
      successInk: Color.lerp(successInk, other.successInk, t)!,
      successTint: Color.lerp(successTint, other.successTint, t)!,
      successOnTint: Color.lerp(successOnTint, other.successOnTint, t)!,
      successBorder: Color.lerp(successBorder, other.successBorder, t)!,
      restFill: Color.lerp(restFill, other.restFill, t)!,
      restInk: Color.lerp(restInk, other.restInk, t)!,
      restTint: Color.lerp(restTint, other.restTint, t)!,
      restOnTint: Color.lerp(restOnTint, other.restOnTint, t)!,
      missedFill: Color.lerp(missedFill, other.missedFill, t)!,
      missedInk: Color.lerp(missedInk, other.missedInk, t)!,
      missedTint: Color.lerp(missedTint, other.missedTint, t)!,
      missedOnTint: Color.lerp(missedOnTint, other.missedOnTint, t)!,
    );
  }
}
