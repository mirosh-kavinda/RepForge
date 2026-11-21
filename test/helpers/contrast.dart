import 'dart:math' as math;

import 'package:flutter/painting.dart';

double relativeLuminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

double contrastRatio(Color foreground, Color background) {
  final fg = Color.alphaBlend(foreground, background);
  final a = relativeLuminance(fg);
  final b = relativeLuminance(background);
  final hi = math.max(a, b);
  final lo = math.min(a, b);
  return (hi + 0.05) / (lo + 0.05);
}
