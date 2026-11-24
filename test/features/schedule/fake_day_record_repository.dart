import 'dart:async';

import 'package:repforge/features/schedule/domain/day_record.dart';
import 'package:repforge/features/schedule/domain/day_record_repository.dart';

class FakeDayRecordRepository implements DayRecordRepository {
  FakeDayRecordRepository([List<DayRecord> initial = const []]) {
    for (final r in initial) {
      _all[(r.cycleId, r.date)] = r;
      _written[(r.cycleId, r.date)] = ++_clock;
    }
  }

  final _all = <(String, DateTime), DayRecord>{};
  // Write order per key, standing in for Drift's updatedAt (SCH-05).
  final _written = <(String, DateTime), int>{};
  var _clock = 0;
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
  Stream<List<DayRecord>> watchRange(DateTime from, DateTime to) async* {
    int order(DayRecord r) => _written[(r.cycleId, r.date)] ?? 0;
    List<DayRecord> read() =>
        [
          for (final r in all)
            if (!r.date.isBefore(from) && !r.date.isAfter(to)) r,
        ]..sort((a, b) {
          final d = a.date.compareTo(b.date);
          return d != 0 ? d : order(a).compareTo(order(b));
        });
    yield read();
    await for (final _ in _changes.stream) {
      yield read();
    }
  }

  void _stamp() {
    for (final k in _all.keys) {
      _written.putIfAbsent(k, () => ++_clock);
    }
  }

  // Mirrors DriftDayRecordRepository's rules (SCH-02, SCH-04).
  @override
  Future<void> markDone({
    required String cycleId,
    required DateTime date,
    required String dayId,
    required int dayIndex,
    bool fromWorkout = false,
  }) async {
    if (failWith case final e?) throw e;
    final existing = _onRow(_all[(cycleId, date)], dayId);
    if (existing != null &&
        existing.status != DayStatus.done &&
        existing.status != DayStatus.planned &&
        !(fromWorkout &&
            (existing.status == DayStatus.missed ||
                existing.status == DayStatus.rest))) {
      return;
    }
    _all[(cycleId, date)] = DayRecord(
      id: existing?.id ?? 'done-${date.toIso8601String()}',
      cycleId: cycleId,
      date: date,
      dayId: dayId,
      dayIndex: dayIndex,
      status: DayStatus.done,
      workoutId: existing?.workoutId,
      linkedDate: existing?.linkedDate,
    );
    _stamp();
    _changes.add(null);
  }

  @override
  Future<void> undo({required String cycleId, required DateTime date}) async {
    if (failWith case final e?) throw e;
    final r = _all[(cycleId, date)];
    if (r == null) return;
    switch (r.status) {
      case DayStatus.done when r.workoutId != null:
        _all[(cycleId, date)] = r.copyWith(status: DayStatus.planned);
      case DayStatus.planned when r.linkedDate != null:
        return;
      case DayStatus.moved:
        if (_all[(cycleId, r.linkedDate!)]?.linkedDate == date) {
          _all.remove((cycleId, r.linkedDate!));
        }
        _all.remove((cycleId, date));
      case DayStatus.missed || DayStatus.rest:
        return;
      case _:
        _all.remove((cycleId, date));
    }
    _stamp();
    _changes.add(null);
  }

  static DayRecord? _onRow(DayRecord? r, String dayId) =>
      r == null ||
          (r.dayId != dayId &&
              r.status != DayStatus.missed &&
              r.status != DayStatus.rest)
      ? null
      : r;

  bool _open(String cycleId, DateTime date, String dayId) {
    final r = _onRow(_all[(cycleId, date)], dayId);
    return r == null || (r.status == DayStatus.planned && r.linkedDate == null);
  }

  Future<void> _act(DayRecord r) async {
    if (failWith case final e?) throw e;
    if (!_open(r.cycleId, r.date, r.dayId)) return;
    _all[(r.cycleId, r.date)] = r;
    _stamp();
    _changes.add(null);
  }

  @override
  Future<void> plan({
    required String cycleId,
    required DateTime date,
    required String dayId,
    required int dayIndex,
    required String workoutId,
  }) => _act(
    DayRecord(
      id: 'plan-${date.toIso8601String()}',
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
    DayRecord(
      id: 'skip-${date.toIso8601String()}',
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
    DayRecord(
      id: 'rest-${date.toIso8601String()}',
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
  }) async {
    if (failWith case final e?) throw e;
    if (!_open(cycleId, date, dayId) || _all.containsKey((cycleId, to))) {
      return;
    }
    _all[(cycleId, date)] = DayRecord(
      id: 'moved-${date.toIso8601String()}',
      cycleId: cycleId,
      date: date,
      dayId: dayId,
      dayIndex: dayIndex,
      status: DayStatus.moved,
      workoutId: workoutId,
      linkedDate: to,
    );
    _all[(cycleId, to)] = DayRecord(
      id: 'in-${to.toIso8601String()}',
      cycleId: cycleId,
      date: to,
      dayId: toDayId,
      dayIndex: toDayIndex,
      status: DayStatus.planned,
      workoutId: workoutId,
      linkedDate: date,
    );
    _stamp();
    _changes.add(null);
  }

  @override
  Future<void> writeSettled(List<DayRecord> records) async {
    if (failSettleWith case final e?) throw e;
    final fresh = [
      for (final r in records)
        if (_all[(r.cycleId, r.date)]?.status case null || DayStatus.planned) r,
    ];
    if (fresh.isEmpty) return;
    for (final r in fresh) {
      _all[(r.cycleId, r.date)] = r;
    }
    settled.addAll(fresh);
    _stamp();
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
    _stamp();
    _changes.add(null);
  }
}
