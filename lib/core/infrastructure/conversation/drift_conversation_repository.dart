import 'package:drift/drift.dart';

import '../../domain/conversation/conversation_message.dart';
import '../../domain/conversation/conversation_repository.dart';
import '../database/thinknest_database.dart' as db;

class DriftConversationRepository implements ConversationRepository {
  DriftConversationRepository(this._database);

  final db.ThinkNestDatabase _database;

  @override
  Stream<List<ConversationMessage>> watchMessages(String projectId) =>
      (_database.select(_database.conversationMessages)
            ..where((row) => row.projectId.equals(projectId))
            ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
          .watch()
          .map((rows) => rows.map(_fromRow).toList());

  @override
  Future<void> addMessage(ConversationMessage message) =>
      _database.into(_database.conversationMessages).insert(
            db.ConversationMessagesCompanion.insert(
              id: message.id,
              projectId: message.projectId,
              role: message.role.name,
              content: message.content,
              createdAt: message.createdAt,
              providerId: Value(message.providerId),
              model: Value(message.model),
              isPending: Value(message.isPending),
            ),
          );

  @override
  Future<void> updateMessage(ConversationMessage message) =>
      (_database.update(_database.conversationMessages)
            ..where((row) => row.id.equals(message.id)))
          .write(
            db.ConversationMessagesCompanion(
              content: Value(message.content),
              providerId: Value(message.providerId),
              model: Value(message.model),
              isPending: Value(message.isPending),
            ),
          );

  ConversationMessage _fromRow(db.ConversationMessage row) =>
      ConversationMessage(
        id: row.id,
        projectId: row.projectId,
        role: ConversationMessageRole.values.firstWhere(
          (value) => value.name == row.role,
          orElse: () => ConversationMessageRole.user,
        ),
        content: row.content,
        createdAt: row.createdAt,
        providerId: row.providerId,
        model: row.model,
        isPending: row.isPending,
      );
}
