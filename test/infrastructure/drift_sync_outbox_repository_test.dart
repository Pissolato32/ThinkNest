import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thinknest/core/domain/sync/sync_outbox_entry.dart';
import 'package:thinknest/core/infrastructure/database/thinknest_database.dart';
import 'package:thinknest/core/infrastructure/sync/drift_sync_outbox_repository.dart';

void main() {
  late ThinkNestDatabase database;
  late DriftSyncOutboxRepository repository;

  setUp(() {
    database = ThinkNestDatabase(NativeDatabase.memory());
    repository = DriftSyncOutboxRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('persists and watches pending entries in creation order', () async {
    final first = SyncOutboxEntry(
      id: 'outbox-1',
      entityType: SyncEntityType.project,
      entityId: 'project-1',
      operation: SyncOperation.upsert,
      payloadJson: '{"id":"project-1"}',
      createdAt: DateTime.utc(2026, 1, 1),
    );
    final second = SyncOutboxEntry(
      id: 'outbox-2',
      entityType: SyncEntityType.document,
      entityId: 'document-1',
      operation: SyncOperation.upsert,
      payloadJson: '{"id":"document-1"}',
      createdAt: DateTime.utc(2026, 1, 2),
    );

    await repository.enqueue(second);
    await repository.enqueue(first);

    final entries = await repository.watchPending().first;

    expect(entries.map((entry) => entry.id), ['outbox-1', 'outbox-2']);
  });

  test('records an attempt and removes a completed entry', () async {
    await repository.enqueue(
      SyncOutboxEntry(
        id: 'outbox-1',
        entityType: SyncEntityType.project,
        entityId: 'project-1',
        operation: SyncOperation.upsert,
        payloadJson: '{}',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    );

    await repository.markAttempt('outbox-1', error: 'offline');

    final attempted = await repository.watchPending().first;
    expect(attempted.single.attempts, 1);
    expect(attempted.single.lastError, 'offline');

    await repository.remove('outbox-1');

    expect(await repository.watchPending().first, isEmpty);
  });
}
