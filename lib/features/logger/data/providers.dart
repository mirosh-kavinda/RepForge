import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/local/database_provider.dart';
import '../../schedule/data/providers.dart';
import '../domain/rest_alarm.dart';
import '../domain/session_repository.dart';
import '../domain/workout_session.dart';
import 'drift_session_repository.dart';
import 'local_rest_alarm.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
SessionRepository sessionRepository(Ref ref) => DriftSessionRepository(
  ref.watch(appDatabaseProvider),
  ref.watch(dayRecordRepositoryProvider),
);

// LOG-03: the phone's "rest over" alert.
@Riverpod(keepAlive: true)
RestAlarm restAlarm(Ref ref) => LocalRestAlarm();

// The workout in progress, if any (WKT-02 AC8).
@riverpod
Stream<WorkoutSession?> activeSession(Ref ref) =>
    ref.watch(sessionRepositoryProvider).watchActive();

// LOG-02 AC6: every finished set of one exercise, for PRs.
@riverpod
Future<List<LoggedSet>> exerciseHistory(Ref ref, String exerciseId) =>
    ref.watch(sessionRepositoryProvider).history(exerciseId);

// LOG-01 AC2: last finished session's sets of one exercise.
@riverpod
Future<Map<int, LoggedSet>> lastSets(Ref ref, String exerciseId) =>
    ref.watch(sessionRepositoryProvider).lastSets(exerciseId);
