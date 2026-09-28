import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thinknest/core/application/ai/ai_task_worker.dart';
import 'package:thinknest/core/domain/ai/ai_provider.dart';
import 'package:thinknest/core/domain/ai/ai_task.dart';
import 'package:thinknest/core/domain/project/project.dart';
import 'package:thinknest/core/domain/project/project_dna.dart';
import 'package:thinknest/core/domain/conversation/conversation_message.dart';
import 'package:thinknest/core/infrastructure/ai/drift_ai_task_repository.dart';
import 'package:thinknest/core/infrastructure/ai/echo_provider.dart';
import 'package:thinknest/core/infrastructure/conversation/drift_conversation_repository.dart';
import 'package:thinknest/core/infrastructure/database/thinknest_database.dart' show ThinkNestDatabase;
import 'package:thinknest/core/infrastructure/project/drift_project_repository.dart';
import 'package:thinknest/core/infrastructure/sync/drift_sync_outbox_repository.dart';

void main() {
  late ThinkNestDatabase database;
  late DriftAiTaskRepository tasks;
  late DriftConversationRepository conversations;
  late DriftProjectRepository projects;

  setUp(() {
    database = ThinkNestDatabase(NativeDatabase.memory());
    final outbox = DriftSyncOutboxRepository(database);
    tasks = DriftAiTaskRepository(database, outbox: outbox);
    conversations = DriftConversationRepository(database, outbox: outbox);
    projects = DriftProjectRepository(database, outbox: outbox);
  });

  tearDown(() async {
    await database.close();
  });

  test('executes a pending task and persists its assistant response', () async {
    final now = DateTime.utc(2026, 1, 1);
    const projectId = 'p1';
    await projects.create(
      Project(
        id: projectId,
        title: 'Projeto',
        createdAt: now,
        updatedAt: now,
      ),
      dna: ProjectDna(
        projectId: projectId,
        version: 1,
        updatedAt: now,
      ),
    );

    final userMessage = ConversationMessage(
      id: 'm1',
      projectId: projectId,
      role: ConversationMessageRole.user,
      content: 'Mensagem',
      createdAt: now,
    );
    await conversations.addMessage(userMessage);

    final task = AiTask(
      id: 't1',
      projectId: projectId,
      createdAt: now,
    );
    await tasks.enqueue(
      task,
      payloadJson: '{"project_id":"p1","message_id":"m1"}',
    );

    final worker = AiTaskWorker(
      tasks,
      conversations,
      projects,
      const EchoProvider(),
    );

    final response = await worker.run(task);

    expect(response, isNotNull);
    expect(response!.role, ConversationMessageRole.assistant);
    expect(response.id, 'ai-task-t1');
    expect(
      await conversations.watchMessages(projectId).first,
      hasLength(2),
    );

    final row = await (database.select(database.aiTasks)
          ..where((item) => item.id.equals(task.id)))
        .getSingle();
    expect(row.status, 'COMPLETED');
    expect(row.attempts, 1);
  });
}
