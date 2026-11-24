import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/l10n/generated/app_localizations.dart';
import 'package:repforge/app/router.dart';
import 'package:repforge/core/clock.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';
import 'package:repforge/features/settings/data/providers.dart';
import 'package:repforge/features/settings/domain/settings.dart';
import 'package:repforge/features/workout/domain/workout_template.dart';

import '../../../helpers/app_overrides.dart';
import '../../schedule/fake_cycle_repository.dart';
import '../../schedule/fake_day_record_repository.dart';
import '../../workout/fakes.dart';
import '../fake_settings_repository.dart';
import '../fake_workout_reminder.dart';

DateTime d(int day) => DateTime.utc(2026, 11, day);

// Push, Rest from today (Tue Nov 24).
final cycle = Cycle(
  id: 'c',
  name: 'Two',
  days: const [
    CycleDay(id: 'a', workoutId: 'push'),
    CycleDay(id: 'off'),
  ],
  isActive: true,
  startDate: d(24),
  startDayIndex: 0,
);

Future<void> settle() async {
  for (var i = 0; i < 8; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SET-01 reminder scheduler', () {
    late FakeWorkoutReminder reminder;
    late FakeSettingsRepository settings;
    late FakeDayRecordRepository days;
    late FakeCycleRepository cycles;

    ProviderContainer start({int hour = 8, List<Cycle>? list}) {
      reminder = FakeWorkoutReminder();
      settings = FakeSettingsRepository(
        reminder: const ReminderPref(on: true, minutes: 18 * 60),
      );
      days = FakeDayRecordRepository();
      final container = ProviderContainer(
        overrides: [
          ...signedInOverrides(
            cycles: cycles = FakeCycleRepository(list ?? [cycle]),
            days: days,
            templates: FakeTemplateRepository([
              const WorkoutTemplate(id: 'push', name: 'Push', exercises: []),
            ]),
            settings: settings,
            reminder: reminder,
          ),
          clockProvider.overrideWithValue(() => DateTime(2026, 11, 24, hour)),
        ],
      );
      addTearDown(container.dispose);
      container.listen(reminderSchedulerProvider, (_, _) {});
      return container;
    }

    test('AC8 training days at the time, titled by workout', () async {
      start();
      await settle();
      expect(reminder.scheduled, hasLength(7));
      final first = reminder.scheduled.first;
      expect(first.at, DateTime(2026, 11, 24, 18));
      expect(first.title, 'Push day today');
      expect(reminder.scheduled[1].at, DateTime(2026, 11, 26, 18));
    });

    test('AC8 today is skipped once its time has passed', () async {
      start(hour: 19);
      await settle();
      expect(reminder.scheduled.first.at, DateTime(2026, 11, 26, 18));
    });

    test('AC8 finishing today drops today; turning off clears all', () async {
      start();
      await settle();
      await days.markDone(cycleId: 'c', date: d(24), dayId: 'a', dayIndex: 0);
      await settle();
      expect(reminder.scheduled.first.at, DateTime(2026, 11, 26, 18));
      await settings.setReminder(const ReminderPref(minutes: 18 * 60));
      await settle();
      expect(reminder.scheduled, isEmpty);
    });

    test('edge a cycle edit reschedules', () async {
      start();
      await settle();
      final before = reminder.replaced;
      // Every day a training day now.
      await cycles.save(
        cycle.copyWith(
          days: const [CycleDay(id: 'a', workoutId: 'push')],
        ),
      );
      await settle();
      expect(reminder.replaced, greaterThan(before));
      expect(reminder.scheduled, hasLength(14));
    });

    test('edge no cycle: nothing scheduled', () async {
      start(list: const []);
      await settle();
      expect(reminder.scheduled, isEmpty);
    });
  });

  test('SET-01 AC9 a reminder tap goes Home; others are ignored', () {
    final went = <String>[];
    openFromNotification('home', went.add);
    openFromNotification(null, went.add);
    expect(went, [Routes.home]);
  });

  test('SET-01 AC8 an unknown workout still gets a title', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    final r = buildReminders(
      days: [(date: d(25), workoutId: 'gone')],
      minutes: 7 * 60,
      now: DateTime(2026, 11, 24, 8),
      workoutNames: const {},
      l10n: l10n,
    );
    expect(r.single.title, 'Workout day today');
    expect(r.single.at, DateTime(2026, 11, 25, 7));
  });
}
