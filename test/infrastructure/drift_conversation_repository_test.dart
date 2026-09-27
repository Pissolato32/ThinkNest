import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thinknest/core/domain/conversation/conversation_message.dart';
import 'package:thinknest/core/domain/sync/sync_outbox_entry.dart';
import 'package:thinknest/core/infrastructure/conversation/drift_conversation_repository.dart';
import 'package:thinknest/core/infrastructure/database/thinknest_database.dart';
import 'package:thinknest/core/infrastructure/sync/drift_sync_outbox_repository.dart';

void main() {
  late ThinkNestDatabase database;
  late DriftConversationRepository repository;
  late DriftSyncOutboxRepository outbox;

  setUp(() {
    database = ThinkNestDatabase(NativeDatabase.memory());
    outbox = DriftSyncOutboxRepository(database);
    repository = DriftConversationRepository(database, outbox: outbox);
  });

  tearDown(() async {
    await database.close();
  });

  test('records added conversation messages in the sync outbox', () async {
    final now = DateTime.utc(2026, 1, 1);
    await database.into(database.projects).insert(
          ProjectsCompanion.insert(
            id: 'p1',
            title: 'Projeto',
            createdAt: now,
            updatedAt: now,
          ),
        );

    final message = ConversationMessage(
      id: 'm1',
      projectId: 'p1',
      role: ConversationMessageRole.user,
      content: 'Olá',
      createdAt: now,
    );

    await repository.addMessage(message);
    final entries = await outbox.watchPending().first;

    expect(entries, hasLength(1));
    expect(entries.single.entityType, SyncEntityType.conversationMessage);
    expect(entries.single.entityId, 'm1');
    expect(entries.single.operation, SyncOperation.upsert);
  });
}
