import 'package:flutter_riverpod/misc.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/data/sync/providers.dart';
import 'package:repforge/data/sync/remote_store.dart';
import 'package:repforge/data/sync/restore.dart';
import 'package:repforge/data/sync/sync_engine.dart';
import 'package:repforge/features/auth/data/providers.dart';
import 'package:repforge/features/auth/domain/auth_user.dart';
import 'package:repforge/features/body/data/providers.dart';
import 'package:repforge/features/goals/data/providers.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/logger/data/providers.dart';
import 'package:repforge/features/onboarding/data/providers.dart';
import 'package:repforge/features/progress/data/providers.dart';
import 'package:repforge/features/schedule/data/providers.dart';
import 'package:repforge/features/settings/data/providers.dart';
import 'package:repforge/features/workout/data/providers.dart';

import '../features/auth/fake_auth_repository.dart';
import '../features/body/fake_body_repository.dart';
import '../features/goals/fake_goal_repository.dart';
import '../features/library/fake_custom_exercise_repository.dart';
import '../features/logger/fake_rest_alarm.dart';
import '../features/logger/fake_session_repository.dart';
import '../features/logger/fake_summary_share.dart';
import '../features/onboarding/fake_onboarding_repository.dart';
import '../features/progress/fake_progress_prefs.dart';
import '../features/schedule/fake_cycle_repository.dart';
import '../features/schedule/fake_day_record_repository.dart';
import '../features/settings/fake_settings_repository.dart';
import '../features/settings/fake_workout_reminder.dart';
import '../features/workout/fakes.dart';

// App-level tests start past the AUTH-01 and ONB-01 gates, as a signed-in,
// onboarded Google user with no workouts or cycles unless given.
List<Override> signedInOverrides({
  FakeAuthRepository? auth,
  FakeTemplateRepository? templates,
  FakeCycleRepository? cycles,
  FakeDayRecordRepository? days,
  FakeSessionRepository? sessions,
  FakeRestAlarm? alarm,
  FakeSummaryShare? share,
  FakeCustomExerciseRepository? custom,
  FakeBodyRepository? body,
  FakeProgressPrefs? prefs,
  FakeGoalRepository? goals,
  FakeSettingsRepository? settings,
  FakeWorkoutReminder? reminder,
  SyncStatus? sync,
  RestoreProgress? restoring,
  BackupSummary? backup,
  UnitSystem units = UnitSystem.metric,
}) => [
  authChoiceMadeProvider.overrideWith((ref) => Stream.value(true)),
  onboardingRepositoryProvider.overrideWithValue(
    FakeOnboardingRepository(done: true, units: units),
  ),
  authRepositoryProvider.overrideWithValue(
    auth ??
        FakeAuthRepository(
          user: const AuthUser(
            uid: 'u1',
            kind: AuthKind.account,
            providers: {SignInProvider.google},
          ),
        ),
  ),
  templateRepositoryProvider.overrideWithValue(
    templates ?? FakeTemplateRepository(),
  ),
  cycleRepositoryProvider.overrideWithValue(cycles ?? FakeCycleRepository()),
  dayRecordRepositoryProvider.overrideWithValue(
    days ?? FakeDayRecordRepository(),
  ),
  sessionRepositoryProvider.overrideWithValue(
    sessions ?? FakeSessionRepository(days: days),
  ),
  restAlarmProvider.overrideWithValue(alarm ?? FakeRestAlarm()),
  summaryShareProvider.overrideWithValue(share ?? FakeSummaryShare()),
  customExerciseRepositoryProvider.overrideWithValue(
    custom ?? FakeCustomExerciseRepository(),
  ),
  bodyRepositoryProvider.overrideWithValue(body ?? FakeBodyRepository()),
  progressPrefsProvider.overrideWithValue(prefs ?? FakeProgressPrefs()),
  goalRepositoryProvider.overrideWithValue(goals ?? FakeGoalRepository()),
  settingsRepositoryProvider.overrideWithValue(
    settings ?? FakeSettingsRepository(),
  ),
  workoutReminderProvider.overrideWithValue(reminder ?? FakeWorkoutReminder()),
  restoreProgressProvider.overrideWith((ref) => Stream.value(restoring)),
  backupSummaryProvider.overrideWith((ref) async => backup),
  syncStatusProvider.overrideWith(
    (ref) => Stream.value(sync ?? (backedUpAt: null, waiting: 0, error: null)),
  ),
];
