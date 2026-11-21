import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/generated/app_localizations.dart';
import 'router.dart';
import 'theme/rf_theme.dart';
import 'theme/theme_mode.dart';

class RepForgeApp extends ConsumerWidget {
  const RepForgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // AC5: English only until si/ta are translated (their ARB files stay empty).
      supportedLocales: const [Locale('en')],
      theme: rfTheme(Brightness.light),
      darkTheme: rfTheme(Brightness.dark),
      themeMode: ref.watch(appThemeModeProvider),
    );
  }
}
