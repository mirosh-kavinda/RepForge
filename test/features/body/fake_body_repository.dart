import 'dart:async';

import 'package:repforge/features/body/domain/body_repository.dart';
import 'package:repforge/features/body/domain/body_snapshot.dart';

class FakeBodyRepository implements BodyRepository {
  FakeBodyRepository({
    this.profile = const BodyProfile(),
    List<BodySnapshot> snapshots = const [],
    DateTime? today,
  }) : today = today ?? DateTime.utc(2026, 11, 24) {
    for (final s in snapshots) {
      _all[s.id] = s;
    }
  }

  BodyProfile profile;
  final DateTime today;
  final _all = <String, BodySnapshot>{};
  final deleted = <String>{};
  final saves = <BodyInput>[];
  Object? failWith;
  var _n = 0;
  final _changes = StreamController<void>.broadcast();

  List<BodySnapshot> get active => [
    for (final s in _all.values)
      if (!deleted.contains(s.id)) s,
  ]..sort((a, b) => b.date.compareTo(a.date));

  @override
  Stream<BodyProfile> watchProfile() async* {
    yield profile;
    await for (final _ in _changes.stream) {
      yield profile;
    }
  }

  @override
  Stream<List<BodySnapshot>> watchAll() async* {
    yield active;
    await for (final _ in _changes.stream) {
      yield active;
    }
  }

  @override
  Future<BodySnapshot?> byId(String id) async => _all[id];

  @override
  Future<String> saveToday(BodyInput i, BodyResults results) async {
    if (failWith case final e?) throw e;
    final same = active.where((s) => s.date == today).firstOrNull;
    final id = same?.id ?? 'b${_n++}';
    _all[id] = BodySnapshot(
      id: id,
      date: today,
      weightKg: i.weightKg,
      waistCm: i.waistCm,
      neckCm: i.neckCm,
      hipCm: i.hipCm,
      scaleBodyFatPct: i.scaleBodyFatPct,
      activity: i.activity,
      results: results,
    );
    saves.add(i);
    profile = BodyProfile(
      sex: profile.sex,
      birthYear: profile.birthYear,
      heightCm: profile.heightCm,
      activity: i.activity,
    );
    _changes.add(null);
    return id;
  }

  @override
  Future<void> delete(String id) async {
    if (failWith case final e?) throw e;
    deleted.add(id);
    _changes.add(null);
  }

  @override
  Future<void> restore(String id) async {
    deleted.remove(id);
    _changes.add(null);
  }
}
