import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/clock.dart';
import '../../../data/local/database_provider.dart';
import '../domain/cycle.dart';
import '../domain/cycle_repository.dart';
import '../domain/day_record.dart';
import '../domain/day_record_repository.dart';
import '../domain/rolling.dart';
import 'drift_cycle_repository.dart';
import 'drift_day_record_repository.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
CycleRepository cycleRepository(Ref ref) =>
    DriftCycleRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
DayRecordRepository dayRecordRepository(Ref ref) =>
    DriftDayRecordRepository(ref.watch(appDatabaseProvider));

@riverpod
Stream<List<Cycle>> cycles(Ref ref) =>
    ref.watch(cycleRepositoryProvider).watchAll();

@riverpod
Stream<Cycle?> activeCycle(Ref ref) =>
    ref.watch(cycleRepositoryProvider).watchActive();

@riverpod
Stream<List<DayRecord>> dayRecords(Ref ref, String cycleId, DateTime from) =>
    ref.watch(dayRecordRepositoryProvider).watchSince(cycleId, from);

// SCH-05: every cycle's records over a calendar grid.
@riverpod
Stream<List<DayRecord>> rangeRecords(Ref ref, DateTime from, DateTime to) =>
    ref.watch(dayRecordRepositoryProvider).watchRange(from, to);

@riverpod
Stream<DateTime?> latestDaySeen(Ref ref) =>
    ref.watch(dayRecordRepositoryProvider).watchLatestDay();

typedef ActiveToday = ({
  Cycle cycle,
  CycleToday today,
  DateTime date,
  List<DayRecord> records,
});

// Where the active cycle has rolled to today (AC1–AC12); data(null) when no
// cycle is active.
@riverpod
AsyncValue<ActiveToday?> cycleToday(Ref ref) {
  final active = ref.watch(activeCycleProvider);
  final cycle = active.value;
  if (cycle == null) return active.whenData((_) => null);
  final date = ref.watch(todayProvider);
  final latest = ref.watch(latestDaySeenProvider);
  if (!latest.hasValue) return latest.whenData((_) => null);
  return ref
      .watch(dayRecordsProvider(cycle.id, cycle.startDate))
      .whenData(
        (r) => (
          cycle: cycle,
          today: rollForward(cycle, r, date, latestSeen: latest.value),
          date: date,
          records: r,
        ),
      );
}

// Records missed / rest for passed dates (AC6, AC7). Re-runs whenever the day
// or the records change; its own write leaves nothing more to settle.
@riverpod
Future<void> cycleSettler(Ref ref) async {
  final t = ref.watch(cycleTodayProvider).value;
  if (t == null) return;
  final repo = ref.read(dayRecordRepositoryProvider);
  final pending = toSettle(t.cycle, t.records, t.date);
  try {
    await repo.seeDay(t.date);
    if (pending.isNotEmpty) await repo.writeSettled(pending);
  } on Object {
    // Retried on the next trigger; today's display does not depend on it.
  }
}
