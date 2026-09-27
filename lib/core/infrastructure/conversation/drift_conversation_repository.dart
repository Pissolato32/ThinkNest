import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/conversation/conversation_message.dart';
import '../../domain/conversation/conversation_repository.dart';
import '../../domain/sync/sync_outbox_entry.dart';
import '../../domain/sync/sync_outbox_repository.dart';
import '../database/thinknest_database.dart' as db;

class DriftConversationRepository implements ConversationRepository {
  DriftConversationRepository(this._database, {SyncOutboxRepository? outbox})
      : _outbox = outbox;

  final db.ThinkNestDatabase _database;
  final SyncOutboxRepository? _outbox;
  static const _uuid = Uuid();

  @override
  Stream<List<ConversationMessage>> watchMessages(String projectId) =>
      (_database.select(_database.conversationMessages)
            ..where((row) => row.projectId.equals(projectId))
            ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
          .watch()
          .map((rows) => rows.map(_fromRow).toList());

  @override
  Future<void> addMessage(ConversationMessage message) async {
    await _database.transaction(() async {
      await _database.into(_database.conversationMessages).insert(
            _toCompanion(message),
          );
      await _record(message);
    });
  }

  @override
  Future<void> updateMessage(ConversationMessage message) async {
    await _database.transaction(() async {
      await (_database.update(_database.conversationMessages)
            ..where((row) => row.id.equals(message.id)))
          .write(
        db.ConversationMessagesCompanion(
          content: Value(message.content),
          providerId: Value(message.providerId),
          model: Value(message.model),
          isPending: Value(message.isPending),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      await _record(message);
    });
  }

  db.ConversationMessagesCompanion _toCompanion(
    ConversationMessage message,
  ) =>
      db.ConversationMessagesCompanion.insert(
        id: message.id,
        projectId: message.projectId,
        role: message.role.name,
        content: message.content,
        createdAt: message.createdAt,
        providerId: Value(message.providerId),
        model: Value(message.model),
        isPending: Value(message.isPending),
        updatedAt: message.createdAt,
      );

  Future<void> _record(ConversationMessage message) async {
    await _outbox?.enqueue(
      SyncOutboxEntry(
        id: _uuid.v4(),
        entityType: SyncEntityType.conversationMessage,
        entityId: message.id,
        operation: SyncOperation.upsert,
        payloadJson: jsonEncode({
          'id': message.id,
          'project_id': message.projectId,
          'role': message.role.name,
          'content': message.content,
          'created_at': message.createdAt.toIso8601String(),
          'provider_id': message.providerId,
          'model': message.model,
          'is_pending': message.isPending,
        }),
        createdAt: message.createdAt,
      ),
    );
  }

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
