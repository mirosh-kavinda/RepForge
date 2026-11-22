import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/data/local/local_data_wiper.dart';
import 'package:repforge/data/sync/sync_state.dart';
import 'package:repforge/features/schedule/data/drift_day_record_repository.dart';
import 'package:repforge/features/schedule/domain/day_record.dart';

final sat = DateTime.utc(2026, 11, 21);
final sun = DateTime.utc(2026, 11, 22);
final mon = DateTime.utc(2026, 11, 23);

DayRecord settled(DateTime date, DayStatus status, {String id = 's'}) =>
    DayRecord(
      id: '$id${date.day}',
      cycleId: 'c1',
      date: date,
      dayId: 'd1',
      dayIndex: 0,
      status: status,
    );

void main() {
  late AppDatabase db;
  late DriftDayRecordRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftDayRecordRepository(db);
  });
  tearDown(() => db.close());

  Future<List<(String, OutboxOp)>> outbox() async => [
    for (final r in await db.select(db.outbox).get()) (r.entity, r.op),
  ];

  Future<List<(DateTime, String, DayStatus)>> live([
    String cycle = 'c1',
  ]) async => [
    for (final r in await repo.watchSince(cycle, sat).first)
      (r.date, r.dayId, r.status),
  ];

  Future<void> done(
    DateTime date, {
    String dayId = 'd1',
    String cycle = 'c1',
  }) => repo.markDone(cycleId: cycle, date: date, dayId: dayId, dayIndex: 0);

  group('SCH-02 day records', () {
    test('AC13 mark done stores the record and queues it at once', () async {
      await done(sat);
      expect(await live(), [(sat, 'd1', DayStatus.done)]);
      expect(await outbox(), [('scheduleDay', OutboxOp.create)]);
      final row = await db.select(db.scheduleDays).getSingle();
      expect(row.syncState, SyncState.pending);
    });

    test('AC3 AC13 undo removes today\'s done and queues a delete', () async {
      await done(sat);
      await repo.undo(cycleId: 'c1', date: sat);
      expect(await live(), isEmpty);
      expect((await outbox()).last, ('scheduleDay', OutboxOp.delete));
    });

    test('AC3 marking again after undo restores the same record', () async {
      await done(sat);
      final id = (await db.select(db.scheduleDays).getSingle()).id;
      await repo.undo(cycleId: 'c1', date: sat);
      await done(sat, dayId: 'd2');
      final rows = await db.select(db.scheduleDays).get();
      expect(rows.map((r) => (r.id, r.dayId, r.deletedAt)), [(id, 'd2', null)]);
      expect((await outbox()).last, ('scheduleDay', OutboxOp.update));
    });

    test('AC6 AC7 AC13 settle writes each missing date once, queued', () async {
      await repo.writeSettled([
        settled(sat, DayStatus.missed),
        settled(sun, DayStatus.rest),
      ]);
      await repo.writeSettled([settled(sat, DayStatus.missed, id: 'again')]);
      expect(await live(), [
        (sat, 'd1', DayStatus.missed),
        (sun, 'd1', DayStatus.rest),
      ]);
      expect(await outbox(), [
        ('scheduleDay', OutboxOp.create),
        ('scheduleDay', OutboxOp.create),
      ]);
    });

    test('edge settle never replaces a done day', () async {
      await done(sat);
      await repo.writeSettled([settled(sat, DayStatus.missed)]);
      expect(await live(), [(sat, 'd1', DayStatus.done)]);
    });

    test('AC6 an undone day that passed is settled as missed', () async {
      await done(sat);
      await repo.undo(cycleId: 'c1', date: sat);
      await repo.writeSettled([settled(sat, DayStatus.missed)]);
      expect(await live(), [(sat, 'd1', DayStatus.missed)]);
      expect(await db.select(db.scheduleDays).get(), hasLength(1));
    });

    test('edge the clock moving back never un-misses a date', () async {
      await repo.writeSettled([settled(sat, DayStatus.missed)]);
      await done(sat);
      await repo.undo(cycleId: 'c1', date: sat);
      expect(await live(), [(sat, 'd1', DayStatus.missed)]);
    });

    test('AC11 watch reads one cycle from a date on', () async {
      await done(sat);
      await done(mon);
      await done(sun, cycle: 'c2');
      expect(await live('c2'), [(sun, 'd1', DayStatus.done)]);
      final fromSun = await repo.watchSince('c1', sun).first;
      expect(fromSun.map((r) => r.date), [mon]);
    });

    test('edge the latest day seen only moves forward', () async {
      expect(await repo.watchLatestDay().first, isNull);
      await repo.seeDay(sun);
      await repo.seeDay(sat);
      expect(await repo.watchLatestDay().first, sun);
      await repo.seeDay(mon);
      expect(await repo.watchLatestDay().first, mon);
    });

    test('sign-out wipes day records', () async {
      await done(sat);
      await LocalDataWiper(db).wipeUserData();
      expect(await db.select(db.scheduleDays).get(), isEmpty);
    });
  });
}
