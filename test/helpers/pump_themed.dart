import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/l10n/generated/app_localizations.dart';
import 'package:repforge/app/theme/rf_theme.dart';

Future<void> pumpThemed(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
  double textScale = 1,
  Size size = const Size(360, 800),
  bool settle = true,
  // Wraps the whole app, so sheets and dialogs see them too.
  List<Override>? overrides,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = size;
  addTearDown(tester.view.reset);
  final app = MaterialApp(
    theme: rfTheme(brightness),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    builder: (context, app) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: app!,
    ),
    home: Scaffold(
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  );
  await tester.pumpWidget(
    overrides == null ? app : ProviderScope(overrides: overrides, child: app),
  );
  settle ? await tester.pumpAndSettle() : await tester.pump();
}
