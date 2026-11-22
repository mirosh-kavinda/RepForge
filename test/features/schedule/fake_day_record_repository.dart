import 'dart:async';

import 'package:repforge/features/schedule/domain/day_record.dart';
import 'package:repforge/features/schedule/domain/day_record_repository.dart';

class FakeDayRecordRepository implements DayRecordRepository {
  FakeDayRecordRepository([List<DayRecord> initial = const []]) {
    for (final r in initial) {
      _all[(r.cycleId, r.date)] = r;
    }
  }

  final _all = <(String, DateTime), DayRecord>{};
  final _changes = StreamController<void>.broadcast();
  final settled = <DayRecord>[];
  Object? failWith;
  Object? failSettleWith;

  List<DayRecord> get all =>
      _all.values.toList()..sort((a, b) => a.date.compareTo(b.date));

  @override
  Stream<List<DayRecord>> watchSince(String cycleId, DateTime from) async* {
    List<DayRecord> read() => [
      for (final r in all)
        if (r.cycleId == cycleId && !r.date.isBefore(from)) r,
    ];
    yield read();
    await for (final _ in _changes.stream) {
      yield read();
    }
  }

  @override
  Future<void> markDone({
    required String cycleId,
    required DateTime date,
    required String dayId,
    required int dayIndex,
  }) async {
    if (failWith case final e?) throw e;
    final existing = _all[(cycleId, date)];
    if (existing != null && existing.status != DayStatus.done) return;
    _all[(cycleId, date)] = DayRecord(
      id: existing?.id ?? 'done-${date.toIso8601String()}',
      cycleId: cycleId,
      date: date,
      dayId: dayId,
      dayIndex: dayIndex,
      status: DayStatus.done,
    );
    _changes.add(null);
  }

  @override
  Future<void> undo({required String cycleId, required DateTime date}) async {
    if (failWith case final e?) throw e;
    if (_all[(cycleId, date)]?.status != DayStatus.done) return;
    _all.remove((cycleId, date));
    _changes.add(null);
  }

  @override
  Future<void> writeSettled(List<DayRecord> records) async {
    if (failSettleWith case final e?) throw e;
    final fresh = [
      for (final r in records)
        if (!_all.containsKey((r.cycleId, r.date))) r,
    ];
    if (fresh.isEmpty) return;
    for (final r in fresh) {
      _all[(r.cycleId, r.date)] = r;
    }
    settled.addAll(fresh);
    _changes.add(null);
  }

  DateTime? latestDay;

  @override
  Stream<DateTime?> watchLatestDay() async* {
    yield latestDay;
    await for (final _ in _changes.stream) {
      yield latestDay;
    }
  }

  @override
  Future<void> seeDay(DateTime date) async {
    if (latestDay != null && !latestDay!.isBefore(date)) return;
    latestDay = date;
    _changes.add(null);
  }
}
