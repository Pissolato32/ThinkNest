import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/sync/sync_cursor.dart';
import '../../domain/sync/sync_outbox_entry.dart';
import '../../domain/sync/sync_outbox_repository.dart';
import '../database/thinknest_database.dart' as db;

class DriftSyncApplier {
  DriftSyncApplier(this._database, this._outbox);

  final db.ThinkNestDatabase _database;
  final SyncOutboxRepository _outbox;

  Future<void> apply(
    SyncEntityType entityType,
    Map<String, dynamic> row,
  ) async {
    switch (entityType) {
      case SyncEntityType.project:
        await _applyProject(row);
      case SyncEntityType.projectDna:
        await _applyDna(row);
      case SyncEntityType.projectSnapshot:
        await _applySnapshot(row);
      case SyncEntityType.document:
        await _applyDocument(row);
      case SyncEntityType.conversationMessage:
        await _applyMessage(row);
      case SyncEntityType.aiTask:
        await _applyAiTask(row);
    }
  }

  SyncCursor cursorFor(
    SyncEntityType entityType,
    Map<String, dynamic> row,
  ) =>
      SyncCursor(
        entityType: entityType.name,
        lastTimestamp: DateTime.parse(
          row[_timestampColumn(entityType)] as String,
        ).toUtc(),
        lastEntityId: (row['id'] ?? row['project_id']) as String,
      );

  Future<void> _applyProject(Map<String, dynamic> row) async {
    final id = row['id'] as String;
    final remoteUpdated = DateTime.parse(row['updated_at'] as String).toUtc();
    final local = await (_database.select(_database.projects)
          ..where((item) => item.id.equals(id)))
        .getSingleOrNull();
    if (local != null && !remoteUpdated.isAfter(local.updatedAt)) return;
    if (local != null) {
      await _outbox.removeForEntity(SyncEntityType.project, id);
    }

    await _database.upsertProject(
      db.ProjectsCompanion.insert(
        id: id,
        userId: Value(row['user_id'] as String?),
        title: row['title'] as String,
        category: Value(row['category'] as String?),
        maturityLevel: Value(row['maturity_level'] as String),
        isPinned: Value(row['is_pinned'] as bool),
        isArchived: Value(row['is_archived'] as bool),
        createdAt: DateTime.parse(row['created_at'] as String).toUtc(),
        updatedAt: remoteUpdated,
      ),
    );
  }

  Future<void> _applyDna(Map<String, dynamic> row) async {
    final projectId = row['project_id'] as String;
    final remoteUpdated = DateTime.parse(row['updated_at'] as String).toUtc();
    final local = await (_database.select(_database.projectDnaRows)
          ..where((item) => item.projectId.equals(projectId)))
        .getSingleOrNull();
    if (local != null && !remoteUpdated.isAfter(local.updatedAt)) return;
    if (local != null) {
      await _outbox.removeForEntity(SyncEntityType.projectDna, projectId);
    }
    await _database.upsertDna(
      db.ProjectDnaRowsCompanion.insert(
        projectId: projectId,
        version: Value(row['version'] as int),
        dnaJson: jsonEncode(row['dna_json']),
        updatedAt: remoteUpdated,
      ),
    );
  }

  Future<void> _applySnapshot(Map<String, dynamic> row) async {
    final id = row['id'] as String;
    final exists = await (_database.select(_database.projectSnapshots)
          ..where((item) => item.id.equals(id)))
        .getSingleOrNull();
    if (exists != null) return;
    await _database.insertSnapshot(
      db.ProjectSnapshotsCompanion.insert(
        id: id,
        projectId: row['project_id'] as String,
        projectVersion: row['project_version'] as int,
        createdAt: DateTime.parse(row['created_at'] as String).toUtc(),
        reason: row['reason'] as String,
        projectJson: jsonEncode(row['project_json']),
        dnaJson: jsonEncode(row['dna_json']),
      ),
    );
  }

  Future<void> _applyDocument(Map<String, dynamic> row) async {
    final id = row['id'] as String;
    final remoteUpdated = DateTime.parse(row['updated_at'] as String).toUtc();
    final local = await (_database.select(_database.documents)
          ..where((item) => item.id.equals(id)))
        .getSingleOrNull();
    if (local != null && !remoteUpdated.isAfter(local.updatedAt)) return;
    if (local != null) {
      await _outbox.removeForEntity(SyncEntityType.document, id);
    }
    await _database.insertDocument(
      db.DocumentsCompanion.insert(
        id: id,
        projectId: row['project_id'] as String,
        type: row['type'] as String,
        version: row['version'] as int,
        status: row['status'] as String,
        title: row['title'] as String,
        content: row['content'] as String,
        dnaVersion: row['dna_version'] as int,
        createdAt: DateTime.parse(row['created_at'] as String).toUtc(),
        updatedAt: remoteUpdated,
      ),
    );
  }

  Future<void> _applyMessage(Map<String, dynamic> row) async {
    final id = row['id'] as String;
    final remoteUpdated = DateTime.parse(row['updated_at'] as String).toUtc();
    final local = await (_database.select(_database.conversationMessages)
          ..where((item) => item.id.equals(id)))
        .getSingleOrNull();
    if (local != null && !remoteUpdated.isAfter(local.updatedAt)) return;
    if (local != null) {
      await _outbox.removeForEntity(SyncEntityType.conversationMessage, id);
    }
    final companion = db.ConversationMessagesCompanion.insert(
      id: id,
      projectId: row['project_id'] as String,
      role: row['role'] as String,
      content: row['content'] as String,
      createdAt: DateTime.parse(row['created_at'] as String).toUtc(),
      providerId: Value(row['provider_id'] as String?),
      model: Value(row['model'] as String?),
      isPending: Value(row['is_pending'] as bool),
      updatedAt: remoteUpdated,
    );
    await _database
        .into(_database.conversationMessages)
        .insertOnConflictUpdate(companion);
  }

  Future<void> _applyAiTask(Map<String, dynamic> row) async {
    final id = row['id'] as String;
    final remoteUpdated = DateTime.parse(row['updated_at'] as String).toUtc();
    final local = await (_database.select(_database.aiTasks)
          ..where((item) => item.id.equals(id)))
        .getSingleOrNull();
    if (local != null && !remoteUpdated.isAfter(local.updatedAt)) return;
    if (local != null) {
      await _outbox.removeForEntity(SyncEntityType.aiTask, id);
    }
    await _database.into(_database.aiTasks).insertOnConflictUpdate(
          db.AiTasksCompanion.insert(
            id: id,
            projectId: row['project_id'] as String,
            status: Value(row['status'] as String),
            payloadJson: Value(jsonEncode(row['payload_json'])),
            attempts: Value(row['attempts'] as int),
            lastError: Value(row['last_error'] as String?),
            createdAt: DateTime.parse(row['created_at'] as String).toUtc(),
            updatedAt: remoteUpdated,
          ),
        );
  }

  String _timestampColumn(SyncEntityType type) => switch (type) {
        SyncEntityType.project => 'updated_at',
        SyncEntityType.projectDna => 'updated_at',
        SyncEntityType.projectSnapshot => 'created_at',
        SyncEntityType.document => 'updated_at',
        SyncEntityType.conversationMessage => 'updated_at',
        SyncEntityType.aiTask => 'updated_at',
      };
}
