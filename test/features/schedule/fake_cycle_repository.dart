import 'dart:async';

import 'package:repforge/features/schedule/domain/cycle.dart';
import 'package:repforge/features/schedule/domain/cycle_repository.dart';

class FakeCycleRepository implements CycleRepository {
  FakeCycleRepository([List<Cycle> initial = const []]) {
    for (final c in initial) {
      _all[c.id] = c;
    }
  }

  final _all = <String, Cycle>{};
  final _deleted = <String>{};
  final _changes = StreamController<void>.broadcast();
  final saved = <Cycle>[];
  Object? failSaveWith;
  Object? failDeleteWith;
  Object? failRestoreWith;
  // When set, saves wait for it, so a test can tap again mid-save.
  Completer<void>? saveGate;

  List<Cycle> get active => [
    for (final c in _all.values)
      if (!_deleted.contains(c.id)) c,
  ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  Stream<T> _watch<T>(T Function() read) async* {
    yield read();
    await for (final _ in _changes.stream) {
      yield read();
    }
  }

  @override
  Stream<List<Cycle>> watchAll() => _watch(() => active);

  @override
  Stream<Cycle?> watchActive() =>
      _watch(() => active.where((c) => c.isActive).firstOrNull);

  @override
  Future<Cycle?> byId(String id) async =>
      _deleted.contains(id) ? null : _all[id];

  @override
  Future<void> save(Cycle c) async {
    await saveGate?.future;
    if (failSaveWith case final e?) throw e;
    if (c.isActive) {
      for (final o in _all.values.toList()) {
        if (o.id != c.id && o.isActive) {
          _all[o.id] = o.copyWith(isActive: false);
        }
      }
    }
    _all[c.id] = c;
    saved.add(c);
    _changes.add(null);
  }

  @override
  Future<void> delete(String id) async {
    if (failDeleteWith case final e?) throw e;
    if (_all[id]?.isActive ?? false) throw ActiveCycleDeleteError();
    _deleted.add(id);
    _changes.add(null);
  }

  @override
  Future<void> restore(String id) async {
    if (failRestoreWith case final e?) throw e;
    _deleted.remove(id);
    _changes.add(null);
  }
}
