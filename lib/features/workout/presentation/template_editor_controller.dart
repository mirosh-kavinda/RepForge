import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/ids.dart';
import '../../library/data/providers.dart';
import '../../library/domain/exercise.dart';
import '../data/providers.dart';
import '../domain/template_rules.dart' as rules;
import '../domain/workout_template.dart';

part 'template_editor_controller.freezed.dart';
part 'template_editor_controller.g.dart';

@freezed
abstract class EditorState with _$EditorState {
  const EditorState._();

  const factory EditorState({
    required String id,
    required bool isNew,
    required String name,
    required List<TemplateExercise> exercises,
    // What Save would leave unchanged; null for an unsaved copy (AC10).
    required WorkoutTemplate? baseline,
    required Map<String, Exercise> catalog,
    @Default(false) bool selecting,
    @Default(<int>{}) Set<int> selection,
  }) = _EditorState;

  bool get dirty =>
      baseline == null ||
      name != baseline!.name ||
      !listEquals(exercises, baseline!.exercises);

  bool get canSave => rules.canSave(name, exercises);

  bool get canLinkSelection => rules.canLink(exercises, selection);
}

// The draft lives here until Save (AC9); nothing is written before.
@riverpod
class TemplateEditor extends _$TemplateEditor {
  @override
  Future<EditorState> build({String? id, String? copyOf}) async {
    final repo = ref.read(templateRepositoryProvider);
    if (id != null) {
      final t = await repo.byId(id);
      if (t == null) throw StateError('No workout $id');
      return EditorState(
        id: t.id,
        isNew: false,
        name: t.name,
        exercises: t.exercises,
        baseline: t,
        catalog: await _lookup(t.exercises.map((e) => e.exerciseId)),
      );
    }
    if (copyOf != null) {
      final t = await repo.byId(copyOf);
      if (t == null) throw StateError('No workout $copyOf');
      return EditorState(
        id: newId(),
        isNew: true,
        name: rules.copyName(t.name),
        exercises: [for (final e in t.exercises) e.copyWith(id: newId())],
        baseline: null,
        catalog: await _lookup(t.exercises.map((e) => e.exerciseId)),
      );
    }
    final id0 = newId();
    return EditorState(
      id: id0,
      isNew: true,
      name: '',
      exercises: const [],
      baseline: WorkoutTemplate(id: id0, name: '', exercises: const []),
      catalog: const {},
    );
  }

  Future<Map<String, Exercise>> _lookup(Iterable<String> ids) async {
    final catalog = await ref.read(exerciseCatalogProvider.future);
    final found = <String, Exercise>{};
    for (final id in ids.toSet()) {
      if (await catalog.byId(id) case final e?) found[id] = e;
    }
    return found;
  }

  EditorState get _s => state.requireValue;

  void _set(EditorState next) => state = AsyncData(next);

  void _edit(List<TemplateExercise> Function(List<TemplateExercise>) f) => _set(
    _s.copyWith(exercises: f(_s.exercises), selecting: false, selection: {}),
  );

  void setName(String name) => _set(_s.copyWith(name: name));

  Future<void> add(List<String> exerciseIds) async {
    final missing = exerciseIds.where((i) => !_s.catalog.containsKey(i));
    final found = await _lookup(missing);
    _set(
      _s.copyWith(
        exercises: rules.append(_s.exercises, exerciseIds),
        catalog: {..._s.catalog, ...found},
      ),
    );
  }

  void replace(String rowId, TemplateExercise Function(TemplateExercise) f) {
    final i = _s.exercises.indexWhere((e) => e.id == rowId);
    if (i < 0) return;
    _set(
      _s.copyWith(
        exercises: rules.replaceAt(_s.exercises, i, f(_s.exercises[i])),
      ),
    );
  }

  void move(int from, int to) => _edit((l) => rules.move(l, from, to));

  void remove(int index) => _edit((l) => rules.removeAt(l, index));

  void unlink(int index) => _edit((l) => rules.unlink(l, index));

  void startSelecting(int index) =>
      _set(_s.copyWith(selecting: true, selection: {index}));

  void toggleSelected(int index) {
    final next = {..._s.selection};
    if (!next.remove(index)) next.add(index);
    _set(_s.copyWith(selection: next));
  }

  void cancelSelecting() => _set(_s.copyWith(selecting: false, selection: {}));

  void linkSelection() => _edit((l) => rules.link(l, _s.selection));

  // Throws when the write fails; the draft stays as it was.
  Future<void> save() async {
    final t = rules.forSave(id: _s.id, name: _s.name, exercises: _s.exercises);
    await ref.read(templateRepositoryProvider).save(t);
    _set(
      _s.copyWith(
        name: t.name,
        exercises: t.exercises,
        baseline: t,
        isNew: false,
      ),
    );
  }
}
