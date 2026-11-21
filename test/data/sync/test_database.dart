import 'package:drift/drift.dart';
import 'package:repforge/core/ids.dart';
import 'package:repforge/data/local/base_columns.dart';
import 'package:repforge/data/sync/outbox_table.dart';
import 'package:repforge/data/sync/sync_state.dart';

part 'test_database.g.dart';

class Notes extends Table with SyncedTable {
  TextColumn get body => text()();
}

@DriftDatabase(tables: [Notes, Outbox])
class TestDatabase extends _$TestDatabase {
  TestDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        "CREATE TRIGGER outbox_boom BEFORE INSERT ON outbox WHEN NEW.entity = 'boom' "
        "BEGIN SELECT RAISE(ABORT, 'outbox failure'); END",
      );
    },
  );
}
