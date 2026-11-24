import 'dart:async';

import 'package:repforge/features/library/domain/custom_exercise_repository.dart';
import 'package:repforge/features/library/domain/custom_rules.dart';
import 'package:repforge/features/library/domain/exercise.dart';

class FakeCustomExerciseRepository implements CustomExerciseRepository {
  FakeCustomExerciseRepository([
    List<Exercise> initial = const [],
    this.catalogNames = const {},
  ]) {
    for (final e in initial) {
      _all[e.id] = e;
    }
  }

  final _all = <String, Exercise>{};
  final deleted = <String>{};
  final Set<String> catalogNames;
  final saved = <Exercise>[];
  Object? failWith;
  final _changes = StreamController<void>.broadcast();

  List<Exercise> get active => [
    for (final e in _all.values)
      if (!deleted.contains(e.id)) e,
  ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  @override
  Stream<List<Exercise>> watchAll() async* {
    yield active;
    await for (final _ in _changes.stream) {
      yield active;
    }
  }

  @override
  Future<Exercise?> byId(String id) async => _all[id];

  @override
  Future<void> save(Exercise e) async {
    if (failWith case final f?) throw f;
    final saved_ = e.copyWith(custom: true, name: cleanExerciseName(e.name)!);
    _all[e.id] = saved_;
    deleted.remove(e.id);
    saved.add(saved_);
    _changes.add(null);
  }

  @override
  Future<void> delete(String id) async {
    if (failWith case final f?) throw f;
    deleted.add(id);
    _changes.add(null);
  }

  @override
  Future<void> restore(String id) async {
    deleted.remove(id);
    _changes.add(null);
  }

  @override
  Future<NameClash> nameClash(String name, {String? exceptId}) async {
    final key = nameKey(name);
    if (active.any((e) => e.id != exceptId && nameKey(e.name) == key)) {
      return NameClash.custom;
    }
    return catalogNames.map(nameKey).contains(key)
        ? NameClash.catalog
        : NameClash.none;
  }
}
