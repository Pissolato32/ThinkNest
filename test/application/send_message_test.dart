import 'package:flutter_test/flutter_test.dart';

import 'package:thinknest/core/application/conversation/send_message.dart';
import 'package:thinknest/core/domain/ai/ai_provider.dart';
import 'package:thinknest/core/domain/ai/ai_task.dart';
import 'package:thinknest/core/domain/ai/ai_task_repository.dart';
import 'package:thinknest/core/domain/conversation/conversation_message.dart';
import 'package:thinknest/core/domain/conversation/conversation_repository.dart';
import 'package:thinknest/core/domain/project/project.dart';
import 'package:thinknest/core/domain/project/project_dna.dart';
import 'package:thinknest/core/domain/project/project_repository.dart';

class FakeConversationRepository implements ConversationRepository {
  final List<ConversationMessage> messages = [];

  @override
  Future<void> addMessage(ConversationMessage message) async =>
      messages.add(message);

  @override
  Future<void> updateMessage(ConversationMessage message) async {}

  @override
  Stream<List<ConversationMessage>> watchMessages(String projectId) async* {
    yield messages.where((message) => message.projectId == projectId).toList();
  }
}

class FakeProjectRepository implements ProjectRepository {
  final ProjectDna dna;

  FakeProjectRepository(this.dna);

  @override
  Future<Project?> getById(String id) async => null;

  @override
  Stream<List<Project>> watchAll() => const Stream.empty();

  @override
  Future<void> create(Project project, {ProjectDna? dna}) async {}

  @override
  Future<void> update(Project project) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<ProjectDna?> getDna(String projectId) async => dna;

  @override
  Future<void> saveDna(ProjectDna dna) async {}
}

class FakeTaskRepository implements AiTaskRepository {
  final List<AiTask> tasks = [];
  final List<String> completed = [];
  final List<String> pending = [];

  @override
  Future<void> enqueue(AiTask task, {required String payloadJson}) async =>
      tasks.add(task);

  @override
  Future<void> markCompleted(String id) async => completed.add(id);

  @override
  Future<void> markPending(String id, {String? error}) async => pending.add(id);
}

class FakeProvider implements AiProvider {
  @override
  String get id => 'fake';

  @override
  Future<AiResponse> complete(AiRequest request) async => const AiResponse(
        content: 'Resposta de teste.',
        providerId: 'fake',
        model: 'test',
      );

  @override
  Stream<String> stream(AiRequest request) =>
      Stream.value('Resposta de teste.');
}

void main() {
  test(
    'SendMessage persists user and assistant messages and completes task',
    () async {
      final conversation = FakeConversationRepository();
      final tasks = FakeTaskRepository();
      final dna = ProjectDna(
        projectId: 'project-1',
        version: 1,
        updatedAt: DateTime.utc(2026),
      );

      final result = await SendMessage(
        conversation,
        FakeProjectRepository(dna),
        FakeProvider(),
        tasks,
      )(projectId: 'project-1', content: 'Quero criar um app.');

      expect(result.role, ConversationMessageRole.assistant);
      expect(conversation.messages, hasLength(2));
      expect(tasks.tasks, hasLength(1));
      expect(tasks.completed, contains(tasks.tasks.single.id));
    },
  );

  test('AiProvider exposes a streaming contract', () async {
    final chunks = await FakeProvider()
        .stream(
          AiRequest(
            projectId: 'project-1',
            dna: ProjectDna(
              projectId: 'project-1',
              version: 1,
              updatedAt: DateTime.utc(2026),
            ),
            messages: [],
          ),
        )
        .toList();

    expect(chunks, ['Resposta de teste.']);
  });
}
