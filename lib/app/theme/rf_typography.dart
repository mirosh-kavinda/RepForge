import 'package:flutter/material.dart';

abstract final class RfFonts {
  static const display = 'SpaceGrotesk';
  static const text = 'Inter';
}

// Variable fonts: Flutter does not map fontWeight onto the wght axis, so each
// style sets both.
TextStyle _style(String family, int weight, double size) => TextStyle(
  fontFamily: family,
  fontSize: size,
  fontWeight: FontWeight.values[weight ~/ 100 - 1],
  fontVariations: [FontVariation('wght', weight.toDouble())],
  fontFeatures: const [FontFeature.tabularFigures()],
);

@immutable
class RfTextStyles extends ThemeExtension<RfTextStyles> {
  const RfTextStyles({
    required this.statXl,
    required this.title,
    required this.heading,
    required this.button,
    required this.body,
    required this.label,
    required this.labelStrong,
    required this.overline,
  });

  static final standard = RfTextStyles(
    statXl: _style(RfFonts.display, 700, 30),
    title: _style(RfFonts.display, 700, 26),
    heading: _style(RfFonts.display, 700, 20),
    button: _style(RfFonts.text, 600, 16),
    body: _style(RfFonts.text, 400, 15),
    label: _style(RfFonts.text, 400, 13),
    labelStrong: _style(RfFonts.text, 500, 13),
    overline: _style(RfFonts.text, 600, 12),
  );

  static RfTextStyles of(BuildContext context) =>
      Theme.of(context).extension<RfTextStyles>()!;

  final TextStyle statXl;
  final TextStyle title;
  final TextStyle heading;
  final TextStyle button;
  final TextStyle body;
  final TextStyle label;
  final TextStyle labelStrong;
  final TextStyle overline;

  @override
  RfTextStyles copyWith({
    TextStyle? statXl,
    TextStyle? title,
    TextStyle? heading,
    TextStyle? button,
    TextStyle? body,
    TextStyle? label,
    TextStyle? labelStrong,
    TextStyle? overline,
  }) => RfTextStyles(
    statXl: statXl ?? this.statXl,
    title: title ?? this.title,
    heading: heading ?? this.heading,
    button: button ?? this.button,
    body: body ?? this.body,
    label: label ?? this.label,
    labelStrong: labelStrong ?? this.labelStrong,
    overline: overline ?? this.overline,
  );

  @override
  RfTextStyles lerp(RfTextStyles? other, double t) {
    if (other == null) return this;
    return RfTextStyles(
      statXl: TextStyle.lerp(statXl, other.statXl, t)!,
      title: TextStyle.lerp(title, other.title, t)!,
      heading: TextStyle.lerp(heading, other.heading, t)!,
      button: TextStyle.lerp(button, other.button, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      labelStrong: TextStyle.lerp(labelStrong, other.labelStrong, t)!,
      overline: TextStyle.lerp(overline, other.overline, t)!,
    );
  }
}
