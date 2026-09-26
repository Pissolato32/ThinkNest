import 'conversation_message.dart';

abstract interface class ConversationRepository {
  Stream<List<ConversationMessage>> watchMessages(String projectId);

  Future<void> addMessage(ConversationMessage message);

  Future<void> updateMessage(ConversationMessage message);
}
