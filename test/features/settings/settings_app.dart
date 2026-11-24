import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/core/clock.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';

import '../../helpers/app_overrides.dart';
import '../library/library_fakes.dart';
import '../schedule/fake_cycle_repository.dart';
import 'fake_settings_repository.dart';
import 'fake_workout_reminder.dart';

late FakeSettingsRepository settings;
late FakeWorkoutReminder reminder;

Future<void> pumpProfile(
  WidgetTester tester, {
  FakeSettingsRepository? repo,
  FakeWorkoutReminder? alarm,
  List<Cycle> cycles = const [],
  double textScale = 1,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  settings = repo ?? FakeSettingsRepository();
  reminder = alarm ?? FakeWorkoutReminder();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...signedInOverrides(
          settings: settings,
          reminder: reminder,
          cycles: FakeCycleRepository(cycles),
        ),
        exerciseCatalogProvider.overrideWith((ref) async => LibraryCatalog()),
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 24, 8)),
      ],
      child: MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: const RepForgeApp(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Profile'),
    ),
  );
  await tester.pumpAndSettle();
}

// The page's vertical list: at 200 % text a segmented control may scroll
// sideways and come first.
Future<void> scrollTo(WidgetTester tester, Finder f) =>
    tester.scrollUntilVisible(
      f,
      200,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
