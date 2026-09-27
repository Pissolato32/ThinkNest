import '../../domain/sync/sync_cursor.dart';
import '../../domain/sync/sync_cursor_repository.dart';
import '../database/thinknest_database.dart' as db;
import 'package:drift/drift.dart';

class DriftSyncCursorRepository implements SyncCursorRepository {
  DriftSyncCursorRepository(this._database);

  final db.ThinkNestDatabase _database;

  @override
  Future<SyncCursor?> get(String entityType) async {
    final row = await (_database.select(_database.syncCursors)
          ..where((item) => item.entityType.equals(entityType)))
        .getSingleOrNull();
    if (row == null) return null;
    return SyncCursor(
      entityType: row.entityType,
      lastTimestamp: row.lastTimestamp,
      lastEntityId: row.lastEntityId,
    );
  }

  @override
  Future<void> save(SyncCursor cursor) =>
      _database.into(_database.syncCursors).insertOnConflictUpdate(
            db.SyncCursorsCompanion.insert(
              entityType: cursor.entityType,
              lastTimestamp: Value(cursor.lastTimestamp),
              lastEntityId: Value(cursor.lastEntityId),
            ),
          );
}
