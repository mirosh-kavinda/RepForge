import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';
import 'package:repforge/features/settings/domain/settings.dart';
import 'package:repforge/features/settings/presentation/profile_screen.dart';
import 'package:repforge/features/settings/presentation/reminder_screen.dart';

import '../fake_settings_repository.dart';
import '../fake_workout_reminder.dart';
import '../settings_app.dart';

final cycle = Cycle(
  id: 'c',
  name: 'Two',
  days: const [
    CycleDay(id: 'a', workoutId: 'push'),
    CycleDay(id: 'off'),
  ],
  isActive: true,
  startDate: DateTime.utc(2026, 11, 24),
  startDayIndex: 0,
);

Future<void> openReminder(
  WidgetTester tester, {
  FakeSettingsRepository? repo,
  FakeWorkoutReminder? alarm,
  List<Cycle>? cycles,
}) async {
  await pumpProfile(
    tester,
    repo: repo,
    alarm: alarm,
    cycles: cycles ?? [cycle],
  );
  await scrollTo(tester, find.byKey(ProfileScreen.reminderKey));
  await tester.tap(find.byKey(ProfileScreen.reminderKey));
  await tester.pumpAndSettle();
}

void main() {
  group('SET-01 reminder screen', () {
    testWidgets('AC8 turning it on saves it; the row shows the time', (
      tester,
    ) async {
      await openReminder(tester);
      await tester.tap(find.byKey(ReminderScreen.switchKey));
      await tester.pumpAndSettle();
      expect(settings.reminder.on, isTrue);
      expect(find.text('6:00 PM'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await scrollTo(tester, find.byKey(ProfileScreen.reminderKey));
      expect(find.text('On, 6:00 PM'), findsOneWidget);
    });

    testWidgets('AC10 notifications off: asks once, then says so', (
      tester,
    ) async {
      final alarm = FakeWorkoutReminder(enabled: false, grant: false);
      await openReminder(tester, alarm: alarm);
      await tester.tap(find.byKey(ReminderScreen.switchKey));
      await tester.pumpAndSettle();
      expect(alarm.requests, 1);
      expect(settings.reminder.on, isTrue);
      expect(
        find.text('Reminders need notifications turned on for RepForge.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(ReminderScreen.openSettingsKey));
      expect(alarm.settingsOpened, 1);
    });

    testWidgets('AC8 the time picker saves a new time', (tester) async {
      await openReminder(
        tester,
        repo: FakeSettingsRepository(
          reminder: const ReminderPref(on: true, minutes: 7 * 60),
        ),
      );
      expect(find.text('7:00 AM'), findsOneWidget);
      await tester.tap(find.byKey(ReminderScreen.timeKey));
      await tester.pumpAndSettle();
      // Type it: switch the picker to text input.
      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '9');
      await tester.enterText(find.byType(TextField).last, '30');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(settings.reminder.minutes, 9 * 60 + 30);
      expect(find.text('9:30 AM'), findsOneWidget);
    });

    testWidgets('edge no cycle yet says nothing will fire', (tester) async {
      await openReminder(
        tester,
        cycles: const [],
        repo: FakeSettingsRepository(reminder: const ReminderPref(on: true)),
      );
      expect(find.text('No cycle yet'), findsOneWidget);
    });

    testWidgets('NFR-06 fits at 200 % text', (tester) async {
      await pumpProfile(tester, textScale: 2, cycles: [cycle]);
      await scrollTo(tester, find.byKey(ProfileScreen.reminderKey));
      await tester.ensureVisible(find.byKey(ProfileScreen.reminderKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ProfileScreen.reminderKey));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(ReminderScreen.timeKey)).height,
        greaterThanOrEqualTo(48),
      );
    });
  });
}
