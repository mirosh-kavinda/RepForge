import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../sync/sync_state.dart';

// Every user-owned table mixes this in (CLAUDE.md: id, updatedAt, deletedAt, syncState).
// A file declaring such a table must import core/ids.dart: generated code calls newId.
mixin SyncedTable on Table {
  TextColumn get id => text().clientDefault(newId)();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncState =>
      textEnum<SyncState>().withDefault(Constant(SyncState.pending.name))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

extension ActiveRows on SyncedTable {
  Expression<bool> get isActive => deletedAt.isNull();
}

// Default read path for user-owned tables, so soft-deleted rows never leak by omission.
extension ActiveSelect on DatabaseConnectionUser {
  SimpleSelectStatement<T, R> selectActive<T extends SyncedTable, R>(
    TableInfo<T, R> table,
  ) => select(table)..where((t) => t.isActive);
}
