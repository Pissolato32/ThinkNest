import 'sync_outbox_entry.dart';

abstract interface class SyncOutboxRepository {
  Stream<List<SyncOutboxEntry>> watchPending();

  Future<void> enqueue(SyncOutboxEntry entry);

  Future<void> markAttempt(String id, {String? error});

  Future<void> remove(String id);

  Future<void> removeForEntity(
    SyncEntityType entityType,
    String entityId,
  );
}
