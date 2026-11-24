import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/clock.dart';
import '../../../data/local/database_provider.dart';
import '../../body/data/providers.dart';
import '../../library/data/providers.dart';
import '../../logger/data/providers.dart';
import '../domain/progress_rules.dart';

part 'providers.g.dart';

// Remembers the chosen exercise on the phone (spec: Data touched).
abstract interface class ProgressPrefs {
  Future<String?> exercise();
  Future<void> setExercise(String id);
}

class _MetaPrefs implements ProgressPrefs {
  _MetaPrefs(this._ref);

  final Ref _ref;
  static const _key = 'progress.exercise';

  @override
  Future<String?> exercise() => _ref.read(appDatabaseProvider).readMeta(_key);

  @override
  Future<void> setExercise(String id) =>
      _ref.read(appDatabaseProvider).writeMeta(_key, id);
}

@Riverpod(keepAlive: true)
ProgressPrefs progressPrefs(Ref ref) => _MetaPrefs(ref);

// AC1.
@riverpod
class SelectedRange extends _$SelectedRange {
  @override
  ProgressRange build() => ProgressRange.months3;

  void set(ProgressRange r) => state = r;
}

DateTime? _from(Ref ref) =>
    rangeStart(ref.watch(selectedRangeProvider), ref.watch(todayProvider));

// AC2: the remembered exercise, else the one with most finished sets.
@riverpod
class ChosenExercise extends _$ChosenExercise {
  @override
  Future<String?> build() async {
    // A finished workout changes the counts.
    ref.watch(activeSessionProvider);
    final saved = await ref.read(progressPrefsProvider).exercise();
    final counts = await ref
        .read(sessionRepositoryProvider)
        .exerciseSetCounts();
    if (saved != null && counts.containsKey(saved)) return saved;
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }

  Future<void> choose(String id) async {
    await ref.read(progressPrefsProvider).setExercise(id);
    state = AsyncData(id);
  }
}

// AC2: exercises I have logged, A–Z by name.
@riverpod
Future<List<({String id, String name})>> loggedExercises(Ref ref) async {
  ref.watch(activeSessionProvider);
  final counts = await ref.read(sessionRepositoryProvider).exerciseSetCounts();
  final catalog = await ref.watch(exerciseCatalogProvider.future);
  final ids = counts.keys.toList();
  final found = await Future.wait(ids.map(catalog.byId));
  return [
    for (final (i, id) in ids.indexed)
      (id: id, name: found[i]?.name ?? id.replaceAll('_', ' ')),
  ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}

// The section watches only this, not chosenExerciseProvider as well:
// two paused watchers of one notifier trip a Riverpod assertion.
@riverpod
Future<({String id, StrengthSeries series})?> strengthProgress(Ref ref) async {
  ref.watch(activeSessionProvider);
  final id = await ref.watch(chosenExerciseProvider.future);
  if (id == null) return null;
  final from = _from(ref);
  final log = await ref
      .read(sessionRepositoryProvider)
      .exerciseLog(id, limit: null, since: from);
  return (id: id, series: strengthSeries(log, from));
}

// AC3.
@riverpod
Future<List<ChartPoint>> volumeProgress(Ref ref) async {
  ref.watch(activeSessionProvider);
  final from = _from(ref);
  final sets = await ref
      .read(sessionRepositoryProvider)
      .finishedSetsSince(from);
  return weeklyVolume(sets, from, ref.watch(todayProvider));
}

// AC4.
@riverpod
Future<BodyTrends> bodyProgress(Ref ref) async =>
    bodyTrends(await ref.watch(bodySnapshotsProvider.future), _from(ref));
