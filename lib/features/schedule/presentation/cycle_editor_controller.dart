import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/clock.dart';
import '../../../core/ids.dart';
import '../../workout/domain/template_rules.dart' show copyName;
import '../data/providers.dart';
import '../domain/cycle.dart';
import '../domain/cycle_rules.dart' as rules;

part 'cycle_editor_controller.freezed.dart';
part 'cycle_editor_controller.g.dart';

enum CycleOrigin { create, copy, edit }

@freezed
abstract class CycleDraft with _$CycleDraft {
  const CycleDraft._();

  const factory CycleDraft({
    required String id,
    required CycleOrigin origin,
    required String name,
    required List<CycleDay> days,
    // The chosen "Today is day n" (0-based) for a new cycle (AC4).
    @Default(0) int startDay,
    // The saved cycle being edited.
    Cycle? original,
  }) = _CycleDraft;

  bool get dirty => switch (origin) {
    CycleOrigin.copy => true,
    CycleOrigin.create => name.isNotEmpty || days.isNotEmpty,
    CycleOrigin.edit =>
      name != original!.name || !listEquals(days, original!.days),
  };

  rules.SaveProblem? get problem => rules.saveProblem(name, days);

  // Where today lands, for the preview (SCH-01 AC4, SCH-02 AC12).
  // [rolled] is where the saved active cycle has rolled to today.
  int todayIndex(DateTime today, int? rolled) {
    if (days.isEmpty) return 0;
    if (origin == CycleOrigin.create) return startDay;
    final o = original;
    if (o == null || !o.isActive) return 0;
    return rules.reanchor(o, days, _rolled(rolled), today).startDayIndex;
  }

  int _rolled(int? rolled) => rolled != null && rolled < original!.days.length
      ? rolled
      : original!.startDayIndex;

  Cycle toCycle(DateTime today, {int? rolled}) {
    final day = rules.calendarDay(today);
    final clean = name.trim();
    return switch (origin) {
      CycleOrigin.create => Cycle(
        id: id,
        name: clean,
        days: days,
        isActive: true,
        startDate: day,
        startDayIndex: startDay,
      ),
      CycleOrigin.copy => Cycle(
        id: id,
        name: clean,
        days: days,
        isActive: false,
        startDate: day,
        startDayIndex: 0,
      ),
      CycleOrigin.edit when original!.isActive => () {
        final a = rules.reanchor(original!, days, _rolled(rolled), today);
        return original!.copyWith(
          name: clean,
          days: days,
          startDate: a.startDate,
          startDayIndex: a.startDayIndex,
        );
      }(),
      CycleOrigin.edit => original!.copyWith(name: clean, days: days),
    };
  }
}

@riverpod
class CycleEditor extends _$CycleEditor {
  @override
  Future<CycleDraft> build({String? id, String? copyOf}) async {
    final repo = ref.read(cycleRepositoryProvider);
    if (id != null) {
      final c = await repo.byId(id);
      if (c == null) throw StateError('No cycle $id');
      return CycleDraft(
        id: c.id,
        origin: CycleOrigin.edit,
        name: c.name,
        days: c.days,
        original: c,
      );
    }
    if (copyOf != null) {
      final c = await repo.byId(copyOf);
      if (c == null) throw StateError('No cycle $copyOf');
      return CycleDraft(
        id: newId(),
        origin: CycleOrigin.copy,
        name: copyName(c.name),
        days: [for (final d in c.days) d.copyWith(id: newId())],
      );
    }
    return CycleDraft(
      id: newId(),
      origin: CycleOrigin.create,
      name: '',
      days: const [],
    );
  }

  CycleDraft get _d => state.requireValue;

  void _set(CycleDraft d) {
    final max = d.days.isEmpty ? 0 : d.days.length - 1;
    state = AsyncData(d.startDay > max ? d.copyWith(startDay: 0) : d);
  }

  void setName(String v) => _set(_d.copyWith(name: v));

  void addTraining(String workoutId) =>
      _set(_d.copyWith(days: rules.addDay(_d.days, workoutId: workoutId)));

  void addRest() => _set(_d.copyWith(days: rules.addDay(_d.days)));

  void setWorkout(int i, String? workoutId) =>
      _set(_d.copyWith(days: rules.setWorkout(_d.days, i, workoutId)));

  void remove(int i) => _set(_d.copyWith(days: rules.removeDay(_d.days, i)));

  void move(int from, int to) =>
      _set(_d.copyWith(days: rules.moveDay(_d.days, from, to)));

  void setStartDay(int index) => _set(_d.copyWith(startDay: index));

  // Throws when the write fails; the draft stays.
  Future<void> save({int? rolled}) async {
    final c = _d.toCycle(ref.read(todayProvider), rolled: rolled);
    await ref.read(cycleRepositoryProvider).save(c);
    _set(_d.copyWith(origin: CycleOrigin.edit, name: c.name, original: c));
  }
}
