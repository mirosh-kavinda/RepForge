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
              updatedAt: now,
              deletedAt: const Value(null),
            ),
          ),
    );
  }

  @override
  Future<void> markDone({
    required String cycleId,
    required DateTime date,
    required String dayId,
    required int dayIndex,
  }) => _db.transaction(() async {
    final existing = await _row(cycleId, date);
    if (existing != null &&
        existing.deletedAt == null &&
        existing.status != DayStatus.done.name) {
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
      ),
      existing,
    );
  });

  @override
  Future<void> undo({required String cycleId, required DateTime date}) =>
      _db.transaction(() async {
        final existing = await _row(cycleId, date);
        if (existing == null ||
            existing.deletedAt != null ||
            existing.status != DayStatus.done.name) {
          return;
        }
        await _writer.softDelete(
          table: _table,
          entity: _entity,
          id: existing.id,
        );
      });

  @override
  Future<void> writeSettled(List<DayRecord> records) =>
      _db.transaction(() async {
        for (final d in records) {
          final existing = await _row(d.cycleId, d.date);
          if (existing != null && existing.deletedAt == null) continue;
          await _put(d, existing);
        }
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
