import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/app/theme/rf_scales.dart';
import 'package:repforge/core/clock.dart';
import 'package:repforge/features/home/presentation/today_card.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/logger/presentation/logger_screen.dart';
import 'package:repforge/features/logger/presentation/rest_bar.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';
import 'package:repforge/features/workout/domain/workout_template.dart';

import '../../../helpers/app_overrides.dart';
import '../../schedule/fake_cycle_repository.dart';
import '../../schedule/fake_day_record_repository.dart';
import '../../workout/fakes.dart';
import '../fake_rest_alarm.dart';
import '../fake_session_repository.dart';

const legs = WorkoutTemplate(
  id: 'legs',
  name: 'Legs',
  exercises: [
    TemplateExercise(id: 't1', exerciseId: 'Barbell_Squat', sets: 2, repMin: 5),
    TemplateExercise(id: 't2', exerciseId: 'Plank', sets: 1, restSec: 60),
  ],
);

// Squat and Leg Press as a superset.
const pair = WorkoutTemplate(
  id: 'legs',
  name: 'Pair',
  exercises: [
    TemplateExercise(
      id: 't1',
      exerciseId: 'Barbell_Squat',
      sets: 2,
      superset: 'A',
      restSec: 30,
    ),
    TemplateExercise(
      id: 't2',
      exerciseId: 'Leg_Press',
      sets: 2,
      superset: 'A',
      restSec: 90,
    ),
  ],
);

final cycle = Cycle(
  id: 'c1',
  name: 'Legs only',
  days: const [CycleDay(id: 'd1', workoutId: 'legs')],
  isActive: true,
  startDate: DateTime.utc(2026, 11, 23),
  startDayIndex: 0,
);

late DateTime now;
late FakeRestAlarm alarm;
late FakeSessionRepository sessions;
var vibrations = 0;

Future<void> open(
  WidgetTester tester, {
  WorkoutTemplate template = legs,
  FakeRestAlarm? withAlarm,
  double textScale = 1,
}) async {
  now = DateTime.utc(2026, 11, 23, 10);
  alarm = withAlarm ?? FakeRestAlarm();
  RestActions.resetAsked();
  vibrations = 0;
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate') vibrations++;
      return null;
    },
  );
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  final days = FakeDayRecordRepository();
  sessions = FakeSessionRepository(days: days);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...signedInOverrides(
          templates: FakeTemplateRepository([template]),
          cycles: FakeCycleRepository([cycle]),
          days: days,
          sessions: sessions,
          alarm: alarm,
        ),
        exerciseCatalogProvider.overrideWith((ref) async => FakeCatalog()),
        clockProvider.overrideWithValue(() => now),
      ],
      child: MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: const RepForgeApp(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(TodayCard.startKey));
  await tester.pumpAndSettle();
}

Future<void> logSet(WidgetTester tester, int n, {int at = 0}) async {
  final f = find.bySemanticsLabel('Log set $n').at(at);
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> wait(WidgetTester tester, int seconds) async {
  now = now.add(Duration(seconds: seconds));
  await tester.pump(const Duration(seconds: 1));
}

Future<void> tapKey(WidgetTester tester, Key key) async {
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}

void main() {
  group('LOG-03 rest timer', () {
    testWidgets('AC1 logging a set starts the rest; the alert is scheduled', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await open(tester);
      expect(find.byType(RestBar), findsOneWidget);
      expect(find.textContaining('Rest '), findsNothing);
      await logSet(tester, 1);
      expect(find.text('Rest 2:00'), findsOneWidget);
      expect(find.text('Next: Barbell Squat, set 2'), findsOneWidget);
      expect(alarm.scheduled?.at, now.add(const Duration(minutes: 2)));
      expect(alarm.scheduled?.title, 'Rest over');
      expect(alarm.scheduled?.body, 'Next: Barbell Squat, set 2');
      await wait(tester, 30);
      expect(find.text('Rest 1:30'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('AC2 the next set restarts it; editing a set does not', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await open(tester);
      await logSet(tester, 1);
      await wait(tester, 50);
      await logSet(tester, 2);
      expect(find.text('Rest 2:00'), findsOneWidget);
      expect(find.text('Next: Plank, set 1'), findsOneWidget);
      final scheduled = alarm.scheduled?.at;
      await wait(tester, 10);
      final row = find.bySemanticsLabel(RegExp('^Barbell Squat, Set 1'));
      await tester.ensureVisible(row);
      await tester.pumpAndSettle();
      await tester.tap(row);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(alarm.scheduled?.at, scheduled);
      expect(find.text('Rest 1:50'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('AC3 a superset rests only after its last exercise', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await open(tester, template: pair);
      await logSet(tester, 1);
      expect(find.textContaining('Rest '), findsNothing);
      expect(alarm.scheduled, isNull);
      await logSet(tester, 1, at: 0);
      expect(find.text('Rest 1:30'), findsOneWidget);
      expect(find.text('Next: Barbell Squat, set 2'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('AC4 ±15 s, pause / resume and skip', (tester) async {
      final handle = tester.ensureSemantics();
      await open(tester);
      await logSet(tester, 1);
      await tapKey(tester, RestBar.plusKey);
      expect(find.text('Rest 2:15'), findsOneWidget);
      await tapKey(tester, RestBar.minusKey);
      await tapKey(tester, RestBar.minusKey);
      expect(find.text('Rest 1:45'), findsOneWidget);
      expect(alarm.scheduled?.at, now.add(const Duration(seconds: 105)));

      await tapKey(tester, RestBar.pauseKey);
      expect(find.text('Paused · 1:45'), findsOneWidget);
      expect(alarm.scheduled, isNull, reason: 'no alert while paused');
      await wait(tester, 300);
      expect(find.text('Paused · 1:45'), findsOneWidget);
      await tapKey(tester, RestBar.pauseKey);
      expect(alarm.scheduled?.at, now.add(const Duration(seconds: 105)));

      await tapKey(tester, RestBar.skipKey);
      expect(find.textContaining('Rest '), findsNothing);
      expect(alarm.scheduled, isNull);
      expect(vibrations, 0, reason: 'skip has no alert');
      handle.dispose();
    });

    testWidgets('AC5 at zero: vibrate and Rest over until dismissed', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await open(tester);
      await logSet(tester, 1);
      await wait(tester, 121);
      await tester.pump();
      expect(find.text('Rest over'), findsOneWidget);
      expect(vibrations, 1);
      await wait(tester, 5);
      expect(vibrations, 1, reason: 'once');
      await tapKey(tester, RestBar.dismissKey);
      expect(find.text('Rest over'), findsNothing);
      handle.dispose();
    });

    testWidgets('AC6 leaving and coming back shows the right time left', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await open(tester);
      await logSet(tester, 1);
      await tester.pageBack();
      await tester.pumpAndSettle();
      now = now.add(const Duration(seconds: 70));
      await tester.tap(find.byKey(TodayCard.startKey));
      await tester.pumpAndSettle();
      expect(find.text('Rest 0:50'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('AC7 notifications off: asked once, then a way to settings', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await open(
        tester,
        withAlarm: FakeRestAlarm(granted: false, allowOnRequest: false),
      );
      expect(alarm.requests, 0, reason: 'not before a rest starts');
      await logSet(tester, 1);
      expect(alarm.requests, 1);
      expect(
        find.text('Turn on notifications to be alerted when locked'),
        findsOneWidget,
      );
      expect(
        find.text('Rest 2:00'),
        findsOneWidget,
        reason: 'timer still runs',
      );
      await tapKey(tester, RestBar.settingsKey);
      expect(alarm.settingsOpened, 1);
      await logSet(tester, 2);
      expect(alarm.requests, 1, reason: 'asked only once');
      handle.dispose();
    });

    testWidgets('AC8 Finish cancels the pending alert', (tester) async {
      final handle = tester.ensureSemantics();
      await open(tester);
      await logSet(tester, 1);
      expect(alarm.scheduled, isNotNull);
      await tester.tap(find.byKey(LoggerScreen.finishKey));
      await tester.pumpAndSettle();
      expect(alarm.scheduled, isNull);
      handle.dispose();
    });

    testWidgets('AC8 Discard cancels the pending alert', (tester) async {
      final handle = tester.ensureSemantics();
      await open(tester);
      await logSet(tester, 1);
      await tester.tap(find.byKey(LoggerScreen.menuKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard workout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(alarm.scheduled, isNull);
      handle.dispose();
    });

    testWidgets('NFR-06 labelled 48 dp controls; fits at 200 % text', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await open(tester, textScale: 2);
      await logSet(tester, 1);
      expect(tester.takeException(), isNull);
      for (final (key, tip) in [
        (RestBar.minusKey, 'Take off 15 seconds'),
        (RestBar.plusKey, 'Add 15 seconds'),
        (RestBar.pauseKey, 'Pause rest'),
        (RestBar.skipKey, 'Skip rest'),
      ]) {
        expect(find.byTooltip(tip), findsOneWidget);
        expect(
          tester.getSize(find.byKey(key)).height,
          greaterThanOrEqualTo(RfSize.minTarget),
        );
      }
      handle.dispose();
    });
  });
}
