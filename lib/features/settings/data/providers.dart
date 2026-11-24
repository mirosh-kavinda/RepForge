import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/l10n/app_locale.dart';
import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router.dart';
import '../../../core/clock.dart';
import '../../../data/local/database_provider.dart';
import '../../schedule/data/providers.dart';
import '../../workout/data/providers.dart';
import '../domain/reminder_rules.dart';
import '../domain/settings.dart';
import '../domain/settings_repository.dart';
import '../domain/workout_reminder.dart';
import 'drift_settings_repository.dart';
import 'local_workout_reminder.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) =>
    DriftSettingsRepository(ref.watch(appDatabaseProvider));

// SET-01 AC2, AC4, AC5.
@Riverpod(keepAlive: true)
Stream<TrainingSettings> trainingSettings(Ref ref) =>
    ref.watch(settingsRepositoryProvider).watch();

// SET-01 AC8.
@riverpod
Stream<ReminderPref> reminderPref(Ref ref) =>
    ref.watch(settingsRepositoryProvider).watchReminder();

@Riverpod(keepAlive: true)
WorkoutReminder workoutReminder(Ref ref) => LocalWorkoutReminder();

// AC8: the next planned training days at the reminder time, still to come.
List<ScheduledReminder> buildReminders({
  required List<ReminderDay> days,
  required int minutes,
  required DateTime now,
  required Map<String, String> workoutNames,
  required AppLocalizations l10n,
}) => [
  for (final d in days)
    if (DateTime(
          d.date.year,
          d.date.month,
          d.date.day,
          minutes ~/ 60,
          minutes % 60,
        )
        case final at when at.isAfter(now))
      (
        at: at,
        title: l10n.reminderTitle(
          workoutNames[d.workoutId] ?? l10n.reminderWorkout,
        ),
        body: l10n.reminderBody,
      ),
];

// Counts app resumes: the phone's time zone may have changed meanwhile, and
// reminders are fixed instants (AC8).
@Riverpod(keepAlive: true)
class ResumeTick extends _$ResumeTick {
  @override
  int build() {
    final listener = AppLifecycleListener(onResume: () => state++);
    ref.onDispose(listener.dispose);
    return 0;
  }
}

// AC8, edges: keeps the scheduled reminders in step with the cycle, the day
// records, the templates and the reminder setting. Re-runs on any change;
// replacing them all is idempotent.
@riverpod
Future<void> reminderScheduler(Ref ref) async {
  final reminder = ref.read(workoutReminderProvider);
  ref.watch(resumeTickProvider);
  final pref = await ref.watch(reminderPrefProvider.future);
  final active = ref.watch(cycleTodayProvider);
  if (!active.hasValue) return;
  final t = active.value;
  try {
    if (!pref.on || t == null) {
      await reminder.replaceAll(const []);
      return;
    }
    final templates = await ref.watch(templatesProvider.future);
    // A newer run has started: its list is the one that counts.
    if (!ref.mounted) return;
    await reminder.replaceAll(
      buildReminders(
        days: reminderDays(
          active: t.cycle,
          rolled: t.today,
          records: t.records,
          today: t.date,
        ),
        minutes: pref.minutes,
        now: ref.read(clockProvider)(),
        workoutNames: {for (final w in templates) w.id: w.name},
        l10n: lookupAppLocalizations(appLocales.first),
      ),
    );
  } on Object {
    // Retried on the next change.
  }
}

// AC9: a reminder's tap opens Home.
void openFromNotification(String? payload, void Function(String) go) {
  if (payload == reminderPayload) go(Routes.home);
}
