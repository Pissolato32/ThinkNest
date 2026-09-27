import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../ai/ai_task_worker.dart';
import '../../domain/ai/ai_task.dart';
import '../../domain/ai/ai_task_repository.dart';
import '../../domain/conversation/conversation_message.dart';
import '../../domain/conversation/conversation_repository.dart';

class SendMessage {
  SendMessage(
    this._conversationRepository,
    this._projectRepository,
    this._taskRepository,
    this._worker, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final ConversationRepository _conversationRepository;
  final AiTaskWorker _worker;
  final AiTaskRepository _taskRepository;
  final Uuid _uuid;

  Future<ConversationMessage> call({
    required String projectId,
    required String content,
  }) async {
    final normalized = content.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(
        content,
        'content',
        'A mensagem não pode estar vazia.',
      );
    }
    final userMessage = ConversationMessage(
      id: _uuid.v4(),
      projectId: projectId,
      role: ConversationMessageRole.user,
      content: normalized,
      createdAt: DateTime.now().toUtc(),
    );
    await _conversationRepository.addMessage(userMessage);

    final task = AiTask(
      id: _uuid.v4(),
      projectId: projectId,
      createdAt: DateTime.now().toUtc(),
    );
    await _taskRepository.enqueue(
      task,
      payloadJson: jsonEncode({
        'project_id': projectId,
        'message_id': userMessage.id,
      }),
    );

    final assistantMessage = await _worker.run(task);
    if (assistantMessage == null) {
      throw StateError('A AI Task não pôde ser executada.');
    }
    return assistantMessage;
  }
}
