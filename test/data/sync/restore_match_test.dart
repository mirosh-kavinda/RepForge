import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/adherence.dart' as m;
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/data/sync/restore.dart';
import 'package:repforge/data/sync/sync_engine.dart';
import 'package:repforge/features/goals/data/drift_goal_repository.dart';
import 'package:repforge/features/goals/domain/goal.dart';
import 'package:repforge/features/logger/data/drift_session_repository.dart';
import 'package:repforge/features/logger/domain/workout_session.dart';
import 'package:repforge/features/progress/domain/adherence_rules.dart';
import 'package:repforge/features/progress/domain/progress_rules.dart';
import 'package:repforge/features/schedule/data/drift_cycle_repository.dart';
import 'package:repforge/features/schedule/data/drift_day_record_repository.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';
import 'package:repforge/features/schedule/domain/day_record.dart';

import 'fake_remote_store.dart';

const uid = 'u1';
final today = DateTime.utc(2026, 11, 24);
final start = DateTime.utc(2026, 9, 1);

final cycle = Cycle(
  id: 'c',
  name: 'Two on',
  days: const [
    CycleDay(id: 'a', workoutId: 'w-a'),
    CycleDay(id: 'b', workoutId: 'w-b'),
    CycleDay(id: 'off'),
  ],
  isActive: true,
  startDate: start,
  startDayIndex: 0,
);

// What the Progress screen and Home streak are built from (PRG-01, PRG-02).
Future<Object> stats(AppDatabase db) async {
  final days = DriftDayRecordRepository(db);
  final sessions = DriftSessionRepository(db, days);
  final records = await days
      .watchRange(DateTime.utc(2000), DateTime.utc(9999))
      .first;
  final cycles = await DriftCycleRepository(db).watchAll().first;
  final history = dayHistory(
    records: records,
    activeCycleId: 'c',
    cycles: {for (final c in cycles) c.id: c},
    today: today,
    todayRow: null,
  );
  final a = adherenceSummary(history, from: null, today: today);
  final log = await sessions.exerciseLog('bench', limit: null);
  return [
    history,
    m.cycleStreak([for (final x in history) x.status]),
    a.percent.valueOrNull,
    a.done,
    a.planned,
    a.streak,
    a.bestStreak,
    a.missed,
    a.weeks.length,
    await sessions.exerciseSetCounts(),
    strengthSeries(log, null).points,
    weeklyVolume(await sessions.finishedSetsSince(null), null, today),
  ].toString();
}

// Every cloud document as text, so later writes can't change a copy.
Map<String, String> cloud(FakeRemoteStore remote) => {
  for (final c in allCollections)
    for (final e in remote.all(uid, c).entries) '$c/${e.key}': '${e.value}',
};

void main() {
  late AppDatabase oldPhone;
  late AppDatabase newPhone;
  late FakeRemoteStore remote;

  // Two phones on purpose.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  setUp(() {
    oldPhone = AppDatabase(NativeDatabase.memory());
    newPhone = AppDatabase(NativeDatabase.memory());
    remote = FakeRemoteStore();
  });
  tearDown(() async {
    await oldPhone.close();
    await newPhone.close();
  });

  // Three months on the old phone: train, train, rest; every 10th day
  // skipped, every 7th missed; a workout with rising weights on each done day.
  Future<void> trainOnOldPhone() async {
    await DriftCycleRepository(oldPhone).save(cycle);
    final days = DriftDayRecordRepository(oldPhone);
    final records = <DayRecord>[];
    var n = 0;
    for (var d = start; d.isBefore(today); d = d.add(const Duration(days: 1))) {
      final i = n % 3;
      final status = i == 2
          ? DayStatus.rest
          : n % 10 == 0
          ? DayStatus.skipped
          : n % 7 == 0
          ? DayStatus.missed
          : DayStatus.done;
      records.add(
        DayRecord(
          id: 'r$n',
          cycleId: 'c',
          date: d,
          dayId: cycle.days[i].id,
          dayIndex: i,
          status: status,
        ),
      );
      if (status == DayStatus.done) {
        final at = d.add(const Duration(hours: 9));
        final sessions = DriftSessionRepository(oldPhone, days, now: () => at);
        final id = await sessions.start(
          WorkoutSession(
            id: 's$n',
            name: 'Push',
            templateId: cycle.days[i].workoutId,
            exercises: const [
              SessionExercise(id: 'r1', exerciseId: 'bench', name: 'Bench'),
            ],
            date: d,
            startedAt: at,
            cycleId: 'c',
            dayId: cycle.days[i].id,
            dayIndex: i,
          ),
        );
        for (var s = 1; s <= 3; s++) {
          await sessions.logSet(
            id,
            LoggedSet(
              id: 's$n-$s',
              rowId: 'r1',
              exerciseId: 'bench',
              setNo: s,
              kg: 50.0 + n / 4,
              reps: 6 + s,
            ),
          );
        }
        await sessions.finish(id);
      }
      n++;
    }
    await days.writeSettled(records);
    final engine = SyncEngine(oldPhone, remote, now: () => today);
    await engine.pull(uid);
    await engine.push(uid, withBody: true);
  }

  test(
    'SYN-02 AC9 stats, PRs, streaks and progress match the old phone',
    () async {
      await trainOnOldPhone();
      final engine = SyncEngine(newPhone, remote, now: () => today);
      await engine.pull(uid);
      await engine.beginRestore(uid);
      await engine.pull(uid);

      final before = await stats(oldPhone);
      expect(before, contains('bench'), reason: 'the old phone has history');
      expect(await stats(newPhone), before);
    },
  );

  test(
    'SYN-02 AC6 after Start fresh this phone backs up beside the backup',
    () async {
      await trainOnOldPhone();
      final backup = cloud(remote);
      final engine = SyncEngine(newPhone, remote, now: () => today);
      await engine.pull(uid);
      await engine.startFresh(uid);
      expect(await RestoreStore(newPhone).read(uid), RestoreState.fresh);

      await DriftGoalRepository(newPhone, now: () => today).save(
        Goal(
          id: 'mine',
          type: GoalType.bodyWeight,
          startValue: 80,
          target: 75,
          createdAt: today,
        ),
      );
      await engine.push(uid, withBody: true);
      await engine.pull(uid);

      expect(remote.doc(uid, 'goals', 'mine'), isNotNull);
      final after = cloud(remote)..remove('goals/mine');
      expect(after, backup, reason: 'the old backup is untouched');
      expect(await newPhone.select(newPhone.workoutSessions).get(), isEmpty);
    },
  );
}
