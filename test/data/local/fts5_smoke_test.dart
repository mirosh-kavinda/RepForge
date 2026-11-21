import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FND-03 SQLite in tests supports FTS5 prefix queries', () async {
    final db = NativeDatabase.memory();
    final executor = db;
    await executor.ensureOpen(_NoUser());
    await executor.runCustom(
      "CREATE VIRTUAL TABLE t USING fts5(name, tokenize='unicode61 remove_diacritics 2')",
    );
    await executor.runInsert(
      "INSERT INTO t(name) VALUES ('Barbell Bench Press')",
      [],
    );
    final rows = await executor.runSelect(
      'SELECT name FROM t WHERE t MATCH ?',
      ['"bench"* AND "pr"*'],
    );
    expect(rows.single['name'], 'Barbell Bench Press');
    await executor.close();
  });
}

class _NoUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}
