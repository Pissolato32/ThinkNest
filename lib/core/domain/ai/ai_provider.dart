import '../conversation/conversation_message.dart';
import '../project/project_dna.dart';

class AiRequest {
  const AiRequest({
    required this.projectId,
    required this.dna,
    required this.messages,
    this.model,
    this.temperature = 0.2,
  });

  final String projectId;
  final ProjectDna dna;
  final List<ConversationMessage> messages;
  final String? model;
  final double temperature;
}

class AiResponse {
  const AiResponse({
    required this.content,
    required this.providerId,
    this.model,
    this.inputTokens,
    this.outputTokens,
  });

  final String content;
  final String providerId;
  final String? model;
  final int? inputTokens;
  final int? outputTokens;
}

abstract interface class AiProvider {
  String get id;

  Future<AiResponse> complete(AiRequest request);

  Stream<String> stream(AiRequest request);
}
