import 'package:drift/drift.dart';

import 'sync_state.dart';

class Outbox extends Table {
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get op => textEnum<OutboxOp>()();
  DateTimeColumn get createdAt => dateTime()();
}
