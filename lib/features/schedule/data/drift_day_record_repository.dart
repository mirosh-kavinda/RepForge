import 'package:drift/drift.dart';

import '../../../core/ids.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/base_columns.dart';
import '../../../data/sync/sync_state.dart';
import '../../../data/sync/synced_writer.dart';
import '../domain/day_record.dart';
import '../domain/day_record_repository.dart';

class DriftDayRecordRepository implements DayRecordRepository {
  DriftDayRecordRepository(this._db, {DateTime Function()? now})
    : _writer = SyncedWriter(_db, now: now);

  static const _table = 'schedule_days';
  static const _entity = 'scheduleDay';

  final AppDatabase _db;
  final SyncedWriter _writer;

  static DayRecord _fromRow(ScheduleDayRow r) => DayRecord(
    id: r.id,
    cycleId: r.cycleId,
    date: r.date,
    dayId: r.dayId,
    dayIndex: r.dayIndex,
    status: DayStatus.values.byName(r.status),
    workoutId: r.workoutId,
    linkedDate: r.linkedDate,
  );

  @override
  Stream<List<DayRecord>> watchSince(String cycleId, DateTime from) =>
      (_db.selectActive(_db.scheduleDays)
            ..where(
              (r) =>
                  r.cycleId.equals(cycleId) & r.date.isBiggerOrEqualValue(from),
            )
            ..orderBy([(r) => OrderingTerm(expression: r.date)]))
          .watch()
          .map((rows) => rows.map(_fromRow).toList());

  @override
  Stream<List<DayRecord>> watchRange(DateTime from, DateTime to) =>
      (_db.selectActive(_db.scheduleDays)
            ..where((r) => r.date.isBetweenValues(from, to))
            ..orderBy([
              (r) => OrderingTerm(expression: r.date),
              (r) => OrderingTerm(expression: r.updatedAt),
            ]))
          .watch()
          .map((rows) => rows.map(_fromRow).toList());

  // Includes a soft-deleted row: the (cycle, date) key is unique.
  Future<ScheduleDayRow?> _row(String cycleId, DateTime date) =>
      (_db.select(_db.scheduleDays)
            ..where((r) => r.cycleId.equals(cycleId) & r.date.equals(date)))
          .getSingleOrNull();

  Future<void> _put(DayRecord d, ScheduleDayRow? existing) {
    final id = existing?.id ?? d.id;
    return _writer.run(
      table: _table,
      entity: _entity,
      id: id,
      op: existing == null ? OutboxOp.create : OutboxOp.update,
      write: (now) => _db
          .into(_db.scheduleDays)
          .insertOnConflictUpdate(
            ScheduleDaysCompanion.insert(
              id: Value(id),
              cycleId: d.cycleId,
              date: d.date,
              dayId: d.dayId,
              dayIndex: d.dayIndex,
              status: d.status.name,
              workoutId: Value(d.workoutId),
              linkedDate: Value(d.linkedDate),
              updatedAt: now,
              deletedAt: const Value(null),
            ),
          ),
    );
  }

  static DayRecord? _live(ScheduleDayRow? r) =>
      r == null || r.deletedAt != null ? null : _fromRow(r);

  // A record left on a row that was since removed or moved away no longer
  // speaks for today (SCH-04 edge: cycle edit); missed / rest still lock it.
  static DayRecord? _onRow(DayRecord? r, String dayId) =>
      r == null ||
          (r.dayId != dayId &&
              r.status != DayStatus.missed &&
              r.status != DayStatus.rest)
      ? null
      : r;

  // No record, or a swap / Train today not done yet.
  static bool _open(DayRecord? r) =>
      r == null || (r.status == DayStatus.planned && r.linkedDate == null);

  Future<void> _remove(ScheduleDayRow r) =>
      _writer.softDelete(table: _table, entity: _entity, id: r.id);

  @override
  Future<void> markDone({
    required String cycleId,
    required DateTime date,
    required String dayId,
    required int dayIndex,
  }) => _db.transaction(() async {
    final existing = await _row(cycleId, date);
    final live = _onRow(_live(existing), dayId);
    if (live != null &&
        live.status != DayStatus.done &&
        live.status != DayStatus.planned) {
      return;
    }
    await _put(
      DayRecord(
        id: newId(),
        cycleId: cycleId,
        date: date,
        dayId: dayId,
        dayIndex: dayIndex,
        status: DayStatus.done,
        workoutId: live?.workoutId,
        linkedDate: live?.linkedDate,
      ),
      existing,
    );
  });

  @override
  Future<void> undo({required String cycleId, required DateTime date}) =>
      _db.transaction(() async {
        final existing = await _row(cycleId, date);
        final live = _live(existing);
        if (existing == null || live == null) return;
        switch (live.status) {
          case DayStatus.done when live.workoutId != null:
            await _put(live.copyWith(status: DayStatus.planned), existing);
          case DayStatus.planned when live.linkedDate != null:
            return;
          case DayStatus.moved:
            final target = await _row(cycleId, live.linkedDate!);
            final t = _live(target);
            if (target != null &&
                t?.status == DayStatus.planned &&
                t?.linkedDate == date) {
              await _remove(target);
            }
            await _remove(existing);
          case DayStatus.done ||
              DayStatus.planned ||
              DayStatus.skipped ||
              DayStatus.unplannedRest:
            await _remove(existing);
          case DayStatus.missed || DayStatus.rest:
            return;
        }
      });

  @override
  Future<void> writeSettled(List<DayRecord> records) =>
      _db.transaction(() async {
        for (final d in records) {
          final existing = await _row(d.cycleId, d.date);
          final live = _live(existing);
          if (live != null && live.status != DayStatus.planned) continue;
          await _put(d, existing);
        }
      });

  Future<void> _act(
    String cycleId,
    DateTime date,
    String dayId,
    DayRecord Function(String id) record,
  ) => _db.transaction(() async {
    final existing = await _row(cycleId, date);
    if (!_open(_onRow(_live(existing), dayId))) return;
    await _put(record(newId()), existing);
  });

  @override
  Future<void> plan({
    required String cycleId,
    required DateTime date,
    required String dayId,
    required int dayIndex,
    required String workoutId,
  }) => _act(
    cycleId,
    date,
    dayId,
    (id) => DayRecord(
      id: id,
      cycleId: cycleId,
      date: date,
      dayId: dayId,
      dayIndex: dayIndex,
      status: DayStatus.planned,
      workoutId: workoutId,
    ),
  );

  @override
  Future<void> skip({
    required String cycleId,
    required DateTime date,
    required String dayId,
    required int dayIndex,
  }) => _act(
    cycleId,
    date,
    dayId,
    (id) => DayRecord(
      id: id,
      cycleId: cycleId,
      date: date,
      dayId: dayId,
      dayIndex: dayIndex,
      status: DayStatus.skipped,
    ),
  );

  @override
  Future<void> restToday({
    required String cycleId,
    required DateTime date,
    required String dayId,
    required int dayIndex,
  }) => _act(
    cycleId,
    date,
    dayId,
    (id) => DayRecord(
      id: id,
      cycleId: cycleId,
      date: date,
      dayId: dayId,
      dayIndex: dayIndex,
      status: DayStatus.unplannedRest,
    ),
  );

  @override
  Future<void> move({
    required String cycleId,
    required DateTime date,
    required String dayId,
    required int dayIndex,
    required String workoutId,
    required DateTime to,
    required String toDayId,
    required int toDayIndex,
  }) => _db.transaction(() async {
    final existing = await _row(cycleId, date);
    final target = await _row(cycleId, to);
    if (!_open(_onRow(_live(existing), dayId)) || _live(target) != null) {
      return;
    }
    await _put(
      DayRecord(
        id: newId(),
        cycleId: cycleId,
        date: date,
        dayId: dayId,
        dayIndex: dayIndex,
        status: DayStatus.moved,
        workoutId: workoutId,
        linkedDate: to,
      ),
      existing,
    );
    await _put(
      DayRecord(
        id: newId(),
        cycleId: cycleId,
        date: to,
        dayId: toDayId,
        dayIndex: toDayIndex,
        status: DayStatus.planned,
        workoutId: workoutId,
        linkedDate: date,
      ),
      target,
    );
  });

  // Device-local, not synced: another phone's clock says nothing about this one.
  static const _latestKey = 'schedule.latestDay';

  @override
  Stream<DateTime?> watchLatestDay() => _db
      .watchMeta(_latestKey)
      .map((v) => v == null ? null : DateTime.parse(v));

  @override
  Future<void> seeDay(DateTime date) => _db.transaction(() async {
    final v = await _db.readMeta(_latestKey);
    if (v != null && !DateTime.parse(v).isBefore(date)) return;
    await _db.writeMeta(_latestKey, date.toUtc().toIso8601String());
  });
}
