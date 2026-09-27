import 'sync_cursor.dart';
import 'sync_outbox_entry.dart';

abstract interface class SyncRemoteRepository {
  Future<void> upsert(
    SyncOutboxEntry entry, {
    required String userId,
  });

  Future<void> delete(
    SyncOutboxEntry entry, {
    required String userId,
  });

  Future<List<Map<String, dynamic>>> fetchSince(
    SyncEntityType entityType,
    SyncCursor? cursor,
  );
}