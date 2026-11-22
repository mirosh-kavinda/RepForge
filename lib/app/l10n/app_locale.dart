import 'dart:ui';

// FND-01 AC5: English only until si/ta are translated (their ARB files stay
// empty).
const appLocales = [Locale('en')];

// NFR-11, SCH-03: strings stay English, but the phone's region (en_GB, en_US …)
// is kept so dates and the first day of the week follow it.
Locale resolveAppLocale(List<Locale>? device, Iterable<Locale> supported) {
  final languages = {for (final s in supported) s.languageCode};
  for (final l in device ?? const <Locale>[]) {
    if (languages.contains(l.languageCode)) return l;
  }
  return supported.first;
}
