import 'package:drift/drift.dart';

import '../../domain/sync/sync_outbox_entry.dart';
import '../../domain/sync/sync_outbox_repository.dart';
import '../database/thinknest_database.dart' as db;

class DriftSyncOutboxRepository implements SyncOutboxRepository {
  DriftSyncOutboxRepository(this._database);

  final db.ThinkNestDatabase _database;

  @override
  Stream<List<SyncOutboxEntry>> watchPending() =>
      (_database.select(_database.syncOutboxEntries)
            ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
          .watch()
          .map((rows) => rows.map(_fromRow).toList());

  @override
  Future<void> enqueue(SyncOutboxEntry entry) =>
      _database.into(_database.syncOutboxEntries).insertOnConflictUpdate(
            db.SyncOutboxEntriesCompanion.insert(
              id: entry.id,
              entityType: entry.entityType.name,
              entityId: entry.entityId,
              operation: entry.operation.name,
              payloadJson: entry.payloadJson,
              createdAt: entry.createdAt,
              attempts: Value(entry.attempts),
              lastError: Value(entry.lastError),
            ),
          );

  @override
  Future<void> markAttempt(String id, {String? error}) async {
    final row = await (_database.select(_database.syncOutboxEntries)
          ..where((item) => item.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return;

    await (_database.update(_database.syncOutboxEntries)
          ..where((item) => item.id.equals(id)))
        .write(
      db.SyncOutboxEntriesCompanion(
        attempts: Value(row.attempts + 1),
        lastError: Value(error),
      ),
    );
  }

  @override
  Future<void> remove(String id) =>
      (_database.delete(_database.syncOutboxEntries)
            ..where((row) => row.id.equals(id)))
          .go();

  @override
  Future<void> removeForEntity(
    SyncEntityType entityType,
    String entityId,
  ) =>
      (_database.delete(_database.syncOutboxEntries)
            ..where(
              (row) =>
                  row.entityType.equals(entityType.name) &
                  row.entityId.equals(entityId),
            ))
          .go();

  SyncOutboxEntry _fromRow(db.SyncOutboxEntry row) => SyncOutboxEntry(
        id: row.id,
        entityType: SyncEntityType.values.firstWhere(
          (value) => value.name == row.entityType,
        ),
        entityId: row.entityId,
        operation: SyncOperation.values.firstWhere(
          (value) => value.name == row.operation,
        ),
        payloadJson: row.payloadJson,
        createdAt: row.createdAt,
        attempts: row.attempts,
        lastError: row.lastError,
      );
}
