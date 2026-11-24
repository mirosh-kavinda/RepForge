import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/data/local/local_data_wiper.dart';
import 'package:repforge/data/sync/sync_state.dart';
import 'package:repforge/features/schedule/data/drift_day_record_repository.dart';
import 'package:repforge/features/schedule/domain/calendar.dart';
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

    test('SCH-04 AC11 new statuses and fields round-trip', () async {
      final wed = DateTime.utc(2026, 11, 25);
      final records = [
        for (final (i, s) in DayStatus.values.indexed)
          DayRecord(
            id: 'n$i',
            cycleId: 'c1',
            date: sat.add(Duration(days: i)),
            dayId: 'd1',
            dayIndex: 0,
            status: s,
            workoutId: s == DayStatus.planned ? 'pull' : null,
            linkedDate: s == DayStatus.moved ? wed : null,
          ),
      ];
      await repo.writeSettled(records);
      expect(await repo.watchSince('c1', sat).first, records);
    });

    test('sign-out wipes day records', () async {
      await done(sat);
      await LocalDataWiper(db).wipeUserData();
      expect(await db.select(db.scheduleDays).get(), isEmpty);
    });
  });

  group('SCH-04 day actions', () {
    final thu = DateTime.utc(2026, 11, 26);

    Future<List<(DateTime, DayStatus, String?, DateTime?)>> full() async => [
      for (final r in await repo.watchSince('c1', sat).first)
        (r.date, r.status, r.workoutId, r.linkedDate),
    ];

    Future<void> swap(DateTime date, String w) => repo.plan(
      cycleId: 'c1',
      date: date,
      dayId: 'd1',
      dayIndex: 0,
      workoutId: w,
    );

    Future<void> moveMon() => repo.move(
      cycleId: 'c1',
      date: mon,
      dayId: 'd1',
      dayIndex: 0,
      workoutId: 'push',
      to: thu,
      toDayId: 'd4',
      toDayIndex: 3,
    );

    test(
      'AC2 swap plans another workout; swapping again replaces it',
      () async {
        await swap(mon, 'pull');
        await swap(mon, 'legs');
        expect(await full(), [(mon, DayStatus.planned, 'legs', null)]);
        expect(await outbox(), [
          ('scheduleDay', OutboxOp.create),
          ('scheduleDay', OutboxOp.update),
        ]);
      },
    );

    test(
      'AC2 AC9 Mark done keeps the swap; Undo steps back one at a time',
      () async {
        await swap(mon, 'pull');
        await done(mon);
        expect(await full(), [(mon, DayStatus.done, 'pull', null)]);
        await repo.undo(cycleId: 'c1', date: mon);
        expect(await full(), [(mon, DayStatus.planned, 'pull', null)]);
        await repo.undo(cycleId: 'c1', date: mon);
        expect(await full(), isEmpty);
      },
    );

    test(
      'AC4 AC5 AC9 skip and unplanned rest are recorded and undone',
      () async {
        final ref = (cycleId: 'c1', date: mon, dayId: 'd1', dayIndex: 0);
        await repo.skip(
          cycleId: ref.cycleId,
          date: ref.date,
          dayId: ref.dayId,
          dayIndex: ref.dayIndex,
        );
        expect((await full()).single.$2, DayStatus.skipped);
        await repo.undo(cycleId: 'c1', date: mon);
        await repo.restToday(
          cycleId: ref.cycleId,
          date: ref.date,
          dayId: ref.dayId,
          dayIndex: ref.dayIndex,
        );
        expect((await full()).single.$2, DayStatus.unplannedRest);
        await repo.undo(cycleId: 'c1', date: mon);
        expect(await full(), isEmpty);
      },
    );

    test(
      'edge Mark done is not taken over by skip; skip not by Mark done',
      () async {
        await done(mon);
        await repo.skip(cycleId: 'c1', date: mon, dayId: 'd1', dayIndex: 0);
        expect((await full()).single.$2, DayStatus.done);
      },
    );

    test('AC7 AC11 move writes both dates in one step, queued each', () async {
      await moveMon();
      expect(await full(), [
        (mon, DayStatus.moved, 'push', thu),
        (thu, DayStatus.planned, 'push', mon),
      ]);
      final target = (await repo.watchSince('c1', thu).first).single;
      expect((target.dayId, target.dayIndex), ('d4', 3));
      expect(await outbox(), hasLength(2));
    });

    test('edge a date with a move in takes no second move', () async {
      await moveMon();
      await repo.move(
        cycleId: 'c1',
        date: DateTime.utc(2026, 11, 24),
        dayId: 'd2',
        dayIndex: 1,
        workoutId: 'legs',
        to: thu,
        toDayId: 'd4',
        toDayIndex: 3,
      );
      expect((await full()).map((r) => r.$1), [mon, thu]);
    });

    test('AC9 undoing a move clears the target too', () async {
      await moveMon();
      await repo.undo(cycleId: 'c1', date: mon);
      expect(await full(), isEmpty);
    });

    test(
      'edge a moved-in day is marked done and undone back to planned',
      () async {
        await moveMon();
        await repo.markDone(cycleId: 'c1', date: thu, dayId: 'd4', dayIndex: 3);
        expect((await full()).last, (thu, DayStatus.done, 'push', mon));
        await repo.undo(cycleId: 'c1', date: thu);
        await repo.undo(cycleId: 'c1', date: thu);
        expect((await full()).last, (thu, DayStatus.planned, 'push', mon));
      },
    );

    test(
      'edge settle replaces a passed planned record, nothing else',
      () async {
        await swap(sat, 'pull');
        await done(sun);
        final id = (await repo.watchSince('c1', sat).first).first.id;
        await repo.writeSettled([
          settled(sat, DayStatus.missed).copyWith(id: id, workoutId: 'pull'),
          settled(sun, DayStatus.missed),
        ]);
        expect((await full()).map((r) => (r.$1, r.$2, r.$3)), [
          (sat, DayStatus.missed, 'pull'),
          (sun, DayStatus.done, null),
        ]);
      },
    );

    test('edge a record left on a removed row does not block today', () async {
      await repo.skip(cycleId: 'c1', date: mon, dayId: 'gone', dayIndex: 2);
      await done(mon);
      expect((await full()).single.$2, DayStatus.done);
      await repo.undo(cycleId: 'c1', date: mon);
      await repo.restToday(cycleId: 'c1', date: mon, dayId: 'd1', dayIndex: 0);
      expect((await full()).single.$2, DayStatus.unplannedRest);
    });

    test('edge a missed record on another row still locks the date', () async {
      await repo.writeSettled([settled(mon, DayStatus.missed)]);
      await repo.skip(cycleId: 'c1', date: mon, dayId: 'd9', dayIndex: 1);
      expect((await full()).single.$2, DayStatus.missed);
    });

    test('AC11 skip, rest and undo each queue one outbox row', () async {
      await repo.skip(cycleId: 'c1', date: mon, dayId: 'd1', dayIndex: 0);
      await repo.undo(cycleId: 'c1', date: mon);
      await repo.restToday(cycleId: 'c1', date: mon, dayId: 'd1', dayIndex: 0);
      expect(await outbox(), [
        ('scheduleDay', OutboxOp.create),
        ('scheduleDay', OutboxOp.delete),
        ('scheduleDay', OutboxOp.update),
      ]);
    });

    test('SCH-05 range reads every cycle between two dates, by date', () async {
      await done(sat, cycle: 'a');
      await done(sun, cycle: 'b');
      await done(mon, cycle: 'a');
      await done(DateTime.utc(2026, 11, 24), cycle: 'b');
      final r = await repo.watchRange(sun, mon).first;
      expect(r.map((x) => (x.date, x.cycleId)), [(sun, 'b'), (mon, 'a')]);
    });

    test('SCH-05 AC7 a month of 2 years of data reads under 300 ms', () async {
      final start = DateTime.utc(2024, 12, 1);
      await repo.writeSettled([
        for (final c in ['a', 'b', 'c'])
          for (var i = 0; i < 760; i++)
            DayRecord(
              id: '$c$i',
              cycleId: c,
              date: start.add(Duration(days: i)),
              dayId: 'd1',
              dayIndex: 0,
              status: DayStatus.done,
            ),
      ]);
      for (final m in [10, 11]) {
        final sw = Stopwatch()..start();
        final dates = monthDates(DateTime.utc(2026, m), 1);
        final r = await repo.watchRange(dates.first, dates.last).first;
        final days = buildMonth(
          month: DateTime.utc(2026, m),
          firstDay: 1,
          today: DateTime.utc(2026, 11, 23),
          records: r,
          active: null,
          rolled: null,
          cycles: const {},
        );
        sw.stop();
        expect(r.length, dates.length * 3);
        expect(days, hasLength(dates.length));
        expect(sw.elapsedMilliseconds, lessThan(300), reason: 'month $m');
      }
    });
  });
}
