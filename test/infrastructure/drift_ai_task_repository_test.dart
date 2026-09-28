import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thinknest/core/domain/ai/ai_task.dart';
import 'package:thinknest/core/domain/sync/sync_outbox_entry.dart';
import 'package:thinknest/core/infrastructure/ai/drift_ai_task_repository.dart';
import 'package:thinknest/core/infrastructure/database/thinknest_database.dart'
    hide AiTask;
import 'package:thinknest/core/infrastructure/sync/drift_sync_outbox_repository.dart';

void main() {
  late ThinkNestDatabase database;
  late DriftAiTaskRepository repository;
  late DriftSyncOutboxRepository outbox;

  setUp(() {
    database = ThinkNestDatabase(NativeDatabase.memory());
    outbox = DriftSyncOutboxRepository(database);
    repository = DriftAiTaskRepository(database, outbox: outbox);
  });

  tearDown(() async {
    await database.close();
  });

  test('increments attempts when a task is returned to pending', () async {
    final now = DateTime.utc(2026, 1, 1);
    await database.into(database.projects).insert(
          ProjectsCompanion.insert(
            id: 'p1',
            title: 'Projeto',
            createdAt: now,
            updatedAt: now,
          ),
        );

    final task = AiTask(
      id: 't2',
      projectId: 'p1',
      createdAt: now,
      attempts: 2,
    );

    await repository.enqueue(task, payloadJson: '{"kind":"retry"}');
    await repository.markRunning(task.id);
    await repository.markPending(task.id, error: 'temporary failure');

    final row = await (database.select(database.aiTasks)
          ..where((item) => item.id.equals(task.id)))
        .getSingle();

    expect(row.attempts, 3);
    expect(row.status, 'PENDING');
    expect(row.lastError, 'temporary failure');
  });

  test('records AI task enqueue and completion in the sync outbox', () async {
    final now = DateTime.utc(2026, 1, 1);
    await database.into(database.projects).insert(
          ProjectsCompanion.insert(
            id: 'p1',
            title: 'Projeto',
            createdAt: now,
            updatedAt: now,
          ),
        );

    final task = AiTask(
      id: 't1',
      projectId: 'p1',
      createdAt: DateTime.utc(2026, 1, 1),
    );

    await repository.enqueue(task, payloadJson: '{"kind":"test"}');
    await repository.markCompleted(task.id);

    final entries = await outbox.watchPending().first;
    expect(entries, hasLength(2));
    expect(entries.every((entry) => entry.entityType == SyncEntityType.aiTask),
        isTrue);
    expect(entries.every((entry) => entry.entityId == 't1'), isTrue);
    expect(entries.every((entry) => entry.operation == SyncOperation.upsert),
        isTrue);
  });
}
