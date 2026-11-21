import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/data/local/base_columns.dart';
import 'package:repforge/data/sync/sync_state.dart';
import 'package:repforge/data/sync/synced_writer.dart';

import 'test_database.dart';

void main() {
  late TestDatabase db;
  late SyncedWriter writer;
  final t0 = DateTime.utc(2026, 11, 21, 10);
  late DateTime clock;

  setUp(() {
    clock = t0;
    db = TestDatabase(NativeDatabase.memory());
    writer = SyncedWriter(db, now: () => clock);
  });
  tearDown(() => db.close());

  Future<void> createNote(String id, String body, {String entity = 'note'}) =>
      writer.run(
        table: 'notes',
        entity: entity,
        id: id,
        op: OutboxOp.create,
        write: (now) => db
            .into(db.notes)
            .insert(
              NotesCompanion.insert(id: Value(id), body: body, updatedAt: now),
            ),
      );

  group('FND-03 synced writes', () {
    test(
      'AC7 user-owned rows get a v7 id, timestamps and sync state',
      () async {
        await db
            .into(db.notes)
            .insert(NotesCompanion.insert(body: 'x', updatedAt: t0));
        final row = await db.select(db.notes).getSingle();
        expect(row.id, matches(RegExp(r'^[0-9a-f-]{36}$')));
        expect(row.id[14], '7');
        expect(row.updatedAt, t0);
        expect(row.deletedAt, isNull);
        expect(row.syncState, SyncState.pending);
      },
    );

    test('AC8 a write saves its outbox row in the same transaction', () async {
      await createNote('n1', 'hello');
      final outbox = await db.select(db.outbox).get();
      expect(outbox, hasLength(1));
      expect(outbox.single.entity, 'note');
      expect(outbox.single.entityId, 'n1');
      expect(outbox.single.op, OutboxOp.create);
      expect(outbox.single.createdAt, t0);
    });

    test('AC8 if the entity write fails, no outbox row is saved', () async {
      await createNote('n1', 'a');
      await expectLater(createNote('n1', 'duplicate id'), throwsA(anything));
      expect(await db.select(db.outbox).get(), hasLength(1));
      expect((await db.select(db.notes).getSingle()).body, 'a');
    });

    test(
      'AC8 if the outbox write fails, the entity write is rolled back',
      () async {
        await expectLater(
          createNote('n2', 'b', entity: 'boom'),
          throwsA(anything),
        );
        expect(await db.select(db.notes).get(), isEmpty);
        expect(await db.select(db.outbox).get(), isEmpty);
      },
    );

    test(
      'AC7 delete only sets deleted-at; normal reads skip deleted rows',
      () async {
        await createNote('n1', 'keep');
        await createNote('n2', 'drop');
        await writer.softDelete(table: 'notes', entity: 'note', id: 'n2');

        final all = await db.select(db.notes).get();
        expect(all, hasLength(2));
        final dropped = all.firstWhere((n) => n.id == 'n2');
        expect(dropped.deletedAt, t0);
        expect(dropped.syncState, SyncState.pending);

        final active = await db.selectActive(db.notes).get();
        expect(active.map((n) => n.id), ['n1']);
        final ops = await db.select(db.outbox).get();
        expect(ops.map((o) => o.op), [
          OutboxOp.create,
          OutboxOp.create,
          OutboxOp.delete,
        ]);
      },
    );

    test(
      'AC8 an update is stamped and queued even if the caller skips it',
      () async {
        await createNote('n1', 'v1');
        await db
            .update(db.notes)
            .write(const NotesCompanion(syncState: Value(SyncState.synced)));
        clock = t0.add(const Duration(minutes: 5));

        await writer.run(
          table: 'notes',
          entity: 'note',
          id: 'n1',
          op: OutboxOp.update,
          write: (_) => (db.update(db.notes)..where((n) => n.id.equals('n1')))
              .write(const NotesCompanion(body: Value('v2'))),
        );

        final row = await db.select(db.notes).getSingle();
        expect(row.body, 'v2');
        expect(row.updatedAt, clock);
        expect(row.syncState, SyncState.pending);
        final ops = await db.select(db.outbox).get();
        expect(ops.map((o) => o.op), [OutboxOp.create, OutboxOp.update]);
        expect(ops.last.createdAt, clock);
      },
    );
  });
}
