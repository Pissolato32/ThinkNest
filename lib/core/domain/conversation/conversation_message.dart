enum ConversationMessageRole { system, user, assistant }

class ConversationMessage {
  const ConversationMessage({
    required this.id,
    required this.projectId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.providerId,
    this.model,
    this.isPending = false,
  });

  final String id;
  final String projectId;
  final ConversationMessageRole role;
  final String content;
  final DateTime createdAt;
  final String? providerId;
  final String? model;
  final bool isPending;
}
