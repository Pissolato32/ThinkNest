import 'sync_cursor.dart';

abstract interface class SyncCursorRepository {
  Future<SyncCursor?> get(String entityType);
  Future<void> save(SyncCursor cursor);
}
