import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/clock.dart';
import '../../../core/metrics/adherence.dart' as m;
import '../../../data/local/database_provider.dart';
import '../../body/data/providers.dart';
import '../../library/data/providers.dart';
import '../../logger/data/providers.dart';
import '../../schedule/data/providers.dart';
import '../domain/adherence_rules.dart';
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

// Fixed bounds: a new day must not open a new stream (and flash a loading
// state); [dayHistory] drops records after today.
final _epoch = DateTime.utc(2000);
final _end = DateTime.utc(9999);

// PRG-02: every date's status up to today, from every cycle. Streams from
// the day records, so it changes as soon as one is written (AC9).
@riverpod
AsyncValue<List<DatedStatus>> statusHistory(Ref ref) {
  final today = ref.watch(todayProvider);
  final records = ref.watch(rangeRecordsProvider(_epoch, _end));
  final cycles = ref.watch(cyclesProvider);
  final t = ref.watch(cycleTodayProvider);
  for (final a in <AsyncValue<Object?>>[records, cycles, t]) {
    if (a case AsyncError(:final error, :final stackTrace)) {
      return AsyncError(error, stackTrace);
    }
  }
  if (!records.hasValue || !cycles.hasValue || !t.hasValue) {
    return const AsyncLoading();
  }
  final active = t.value;
  final row = active?.cycle.days[active.today.index];
  return AsyncData(
    dayHistory(
      records: records.value!,
      activeCycleId: active?.cycle.id,
      cycles: {for (final c in cycles.value!) c.id: c},
      today: today,
      todayRow: row == null
          ? null
          : (isRest: row.isRest, workoutId: row.workoutId),
    ),
  );
}

// PRG-02 AC1, AC2; null with no schedule history at all.
@riverpod
AsyncValue<int?> streak(Ref ref) => ref
    .watch(statusHistoryProvider)
    .whenData(
      (h) => h.isEmpty ? null : m.cycleStreak([for (final x in h) x.status]),
    );

// PRG-02 AC3–AC7, on the PRG-01 range.
@riverpod
AsyncValue<AdherenceSummary> adherence(Ref ref) => ref
    .watch(statusHistoryProvider)
    .whenData(
      (h) => adherenceSummary(
        h,
        from: _from(ref),
        today: ref.watch(todayProvider),
      ),
    );
