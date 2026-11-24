import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/ids.dart';
import '../../../core/metrics/body.dart';
import '../../../core/metrics/energy.dart';
import '../../../core/metrics/estimate.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/base_columns.dart';
import '../../../data/sync/sync_state.dart';
import '../../../data/sync/synced_writer.dart';
import '../domain/body_repository.dart';
import '../domain/body_snapshot.dart';

class DriftBodyRepository implements BodyRepository {
  DriftBodyRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now,
      _writer = SyncedWriter(_db, now: now);

  static const _table = 'body_snapshots';
  static const _entity = 'bodySnapshot';

  final AppDatabase _db;
  final DateTime Function() _now;
  final SyncedWriter _writer;

  static String encodeResults(BodyResults r) => jsonEncode({
    for (final MapEntry(:key, :value) in r.entries)
      key.name: switch (value) {
        Estimated(:final value, :final approximate) => {
          'v': value,
          'a': approximate,
        },
        NotEstimable(:final reason, :final field) => {
          'r': reason.name,
          'f': ?field?.name,
        },
      },
  });

  static BodyResults decodeResults(String json) => {
    for (final MapEntry(:key, :value)
        in (jsonDecode(json) as Map<String, Object?>).entries)
      BodyMetric.values.byName(key): switch (value! as Map<String, Object?>) {
        {'v': final num v} && final m => Estimated<double>(
          v.toDouble(),
          approximate: m['a'] == true,
        ),
        final m => NotEstimable<double>(
          EstimateReason.values.byName(m['r']! as String),
          switch (m['f']) {
            final String f => Measure.values.byName(f),
            _ => null,
          },
        ),
      },
  };

  static T? _enum<T extends Enum>(List<T> values, String? name) =>
      name == null ? null : values.asNameMap()[name];

  static BodySnapshot _fromRow(BodySnapshotRow r) => BodySnapshot(
    id: r.id,
    date: r.date,
    weightKg: r.weightKg,
    waistCm: r.waistCm,
    neckCm: r.neckCm,
    hipCm: r.hipCm,
    scaleBodyFatPct: r.scaleBodyFatPct,
    activity: _enum(ActivityLevel.values, r.activity),
    results: r.results == null ? null : decodeResults(r.results!),
  );

  SimpleSelectStatement<$UserProfilesTable, UserProfile> _profile() =>
      _db.selectActive(_db.userProfiles)
        ..orderBy([(p) => OrderingTerm.desc(p.updatedAt)])
        ..limit(1);

  @override
  Stream<BodyProfile> watchProfile() => _profile().watchSingleOrNull().map(
    (p) => p == null
        ? const BodyProfile()
        : BodyProfile(
            sex: _enum(Sex.values, p.sex),
            birthYear: p.birthYear,
            heightCm: p.heightCm,
            activity: _enum(ActivityLevel.values, p.activityLevel),
          ),
  );

  @override
  Stream<List<BodySnapshot>> watchAll() =>
      (_db.selectActive(_db.bodySnapshots)..orderBy([
            (s) => OrderingTerm.desc(s.date),
            (s) => OrderingTerm.desc(s.updatedAt),
          ]))
          .watch()
          .map((rows) => rows.map(_fromRow).toList());

  @override
  Future<BodySnapshot?> byId(String id) async {
    final r = await (_db.select(
      _db.bodySnapshots,
    )..where((s) => s.id.equals(id))).getSingleOrNull();
    return r == null ? null : _fromRow(r);
  }

  @override
  Future<String> saveToday(BodyInput i, BodyResults results) =>
      _db.transaction(() async {
        final local = _now();
        // The phone's calendar day, stored as UTC midnight (as ONB-01).
        final date = DateTime.utc(local.year, local.month, local.day);
        final existing =
            await (_db.selectActive(_db.bodySnapshots)
                  ..where((s) => s.date.equals(date))
                  ..limit(1))
                .getSingleOrNull();
        final id = existing?.id ?? newId();
        await _writer.run(
          table: _table,
          entity: _entity,
          id: id,
          op: existing == null ? OutboxOp.create : OutboxOp.update,
          write: (now) => _db
              .into(_db.bodySnapshots)
              .insertOnConflictUpdate(
                BodySnapshotsCompanion.insert(
                  id: Value(id),
                  date: date,
                  weightKg: Value(i.weightKg),
                  waistCm: Value(i.waistCm),
                  neckCm: Value(i.neckCm),
                  hipCm: Value(i.hipCm),
                  scaleBodyFatPct: Value(i.scaleBodyFatPct),
                  activity: Value(i.activity.name),
                  results: Value(encodeResults(results)),
                  updatedAt: now,
                ),
              ),
        );
        if (await _profile().getSingleOrNull() case final p?) {
          await _writer.run(
            table: 'user_profiles',
            entity: 'userProfile',
            id: p.id,
            op: OutboxOp.update,
            write: (_) =>
                (_db.update(
                  _db.userProfiles,
                )..where((r) => r.id.equals(p.id))).write(
                  UserProfilesCompanion(activityLevel: Value(i.activity.name)),
                ),
          );
        }
        return id;
      });

  @override
  Future<void> delete(String id) =>
      _writer.softDelete(table: _table, entity: _entity, id: id);

  // AC6: one per day still holds if that day was saved again meanwhile.
  @override
  Future<void> restore(String id) => _db.transaction(() async {
    final row = await byId(id);
    if (row == null) return;
    final others = await (_db.selectActive(
      _db.bodySnapshots,
    )..where((s) => s.date.equals(row.date) & s.id.equals(id).not())).get();
    for (final o in others) {
      await _writer.softDelete(table: _table, entity: _entity, id: o.id);
    }
    await _writer.run(
      table: _table,
      entity: _entity,
      id: id,
      op: OutboxOp.update,
      write: (_) =>
          (_db.update(_db.bodySnapshots)..where((s) => s.id.equals(id))).write(
            const BodySnapshotsCompanion(deletedAt: Value(null)),
          ),
    );
  });
}
