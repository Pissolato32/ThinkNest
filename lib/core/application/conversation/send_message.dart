import 'package:uuid/uuid.dart';

import '../../domain/ai/ai_provider.dart';
import '../../domain/conversation/conversation_message.dart';
import '../../domain/conversation/conversation_repository.dart';
import '../../domain/project/project_repository.dart';

class SendMessage {
  SendMessage(
    this._conversationRepository,
    this._projectRepository,
    this._provider, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final ConversationRepository _conversationRepository;
  final ProjectRepository _projectRepository;
  final AiProvider _provider;
  final Uuid _uuid;

  Future<ConversationMessage> call({
    required String projectId,
    required String content,
  }) async {
    final normalized = content.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(content, 'content', 'A mensagem não pode estar vazia.');
    }
    final dna = await _projectRepository.getDna(projectId);
    if (dna == null) throw StateError('Project DNA não encontrado.');

    final userMessage = ConversationMessage(
      id: _uuid.v4(),
      projectId: projectId,
      role: ConversationMessageRole.user,
      content: normalized,
      createdAt: DateTime.now().toUtc(),
    );
    await _conversationRepository.addMessage(userMessage);

    final messages = await _conversationRepository.watchMessages(projectId).first;
    final response = await _provider.complete(
      AiRequest(projectId: projectId, dna: dna, messages: messages),
    );
    final assistantMessage = ConversationMessage(
      id: _uuid.v4(),
      projectId: projectId,
      role: ConversationMessageRole.assistant,
      content: response.content,
      createdAt: DateTime.now().toUtc(),
      providerId: response.providerId,
      model: response.model,
    );
    await _conversationRepository.addMessage(assistantMessage);
    return assistantMessage;
  }
}
