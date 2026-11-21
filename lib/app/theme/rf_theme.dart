import 'package:flutter/material.dart';

import 'rf_tokens.dart';
import 'rf_typography.dart';

Color rfPressed(Color color) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - 0.08).clamp(0.0, 1.0)).toColor();
}

ThemeData rfTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? RfColors.dark : RfColors.light;
  final t = RfTextStyles.standard;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.actionFill,
    onPrimary: c.onSolid,
    primaryContainer: c.actionTint,
    onPrimaryContainer: c.actionOnTint,
    secondary: c.successFill,
    onSecondary: c.onSolid,
    secondaryContainer: c.successTint,
    onSecondaryContainer: c.successOnTint,
    tertiary: c.restFill,
    onTertiary: c.onSolid,
    error: c.missedFill,
    onError: c.onSolid,
    errorContainer: c.missedTint,
    onErrorContainer: c.missedOnTint,
    surface: c.surface,
    onSurface: c.textPrimary,
    onSurfaceVariant: c.textSecondary,
    outline: c.border,
    outlineVariant: c.divider,
  );

  // Every slot is set so stock Material widgets also get the wght axis.
  final textTheme = TextTheme(
    displayLarge: t.statXl,
    displayMedium: t.statXl,
    displaySmall: t.statXl,
    headlineLarge: t.title,
    headlineMedium: t.title,
    headlineSmall: t.heading,
    titleLarge: t.heading,
    titleMedium: t.button,
    titleSmall: t.labelStrong,
    labelLarge: t.button,
    labelMedium: t.labelStrong,
    labelSmall: t.overline,
    bodyLarge: t.body,
    bodyMedium: t.body,
    bodySmall: t.label,
  ).apply(bodyColor: c.textPrimary, displayColor: c.textPrimary);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    canvasColor: c.bg,
    dividerColor: c.divider,
    fontFamily: RfFonts.text,
    textTheme: textTheme,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      foregroundColor: c.textPrimary,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: t.heading.copyWith(color: c.textPrimary),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.navBar,
      indicatorColor: c.actionTint,
      surfaceTintColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected)
              ? c.actionOnTint
              : c.textSecondary,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => t.labelStrong.copyWith(
          color: s.contains(WidgetState.selected)
              ? c.textPrimary
              : c.textSecondary,
        ),
      ),
    ),
    extensions: [c, t],
  );
}
