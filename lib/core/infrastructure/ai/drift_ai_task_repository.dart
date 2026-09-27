import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/ai/ai_task.dart';
import '../../domain/ai/ai_task_repository.dart';
import '../../domain/sync/sync_outbox_entry.dart';
import '../../domain/sync/sync_outbox_repository.dart';
import '../database/thinknest_database.dart' as db;

class DriftAiTaskRepository implements AiTaskRepository {
  DriftAiTaskRepository(this._database, {SyncOutboxRepository? outbox})
      : _outbox = outbox;

  final db.ThinkNestDatabase _database;
  final SyncOutboxRepository? _outbox;
  static const _uuid = Uuid();

  @override
  Future<void> enqueue(AiTask task, {required String payloadJson}) async {
    await _database.transaction(() async {
      await _database.into(_database.aiTasks).insertOnConflictUpdate(
            db.AiTasksCompanion.insert(
              id: task.id,
              projectId: task.projectId,
              status: Value(task.status.name.toUpperCase()),
              attempts: Value(task.attempts),
              lastError: Value(task.lastError),
              createdAt: task.createdAt,
              payloadJson: Value(payloadJson),
              updatedAt: task.createdAt,
            ),
          );
      await _record(task, payloadJson);
    });
  }

  @override
  Future<void> markCompleted(String id) async {
    final row = await _find(id);
    if (row == null) return;
    final task = _fromRow(row, status: AiTaskStatus.completed);
    await _update(task);
  }

  @override
  Future<void> markPending(
    String id, {
    String? error,
  }) async {
    final row = await _find(id);
    if (row == null) return;
    final task = _fromRow(
      row,
      status: AiTaskStatus.pending,
      lastError: error,
      attempts: 1,
    );
    await _update(task);
  }

  Future<db.AiTask?> _find(String id) =>
      (_database.select(_database.aiTasks)..where((row) => row.id.equals(id)))
          .getSingleOrNull();

  Future<void> _update(AiTask task) async {
    final row = await _find(task.id);
    if (row == null) return;
    await _database.transaction(() async {
      await (_database.update(_database.aiTasks)
            ..where((row) => row.id.equals(task.id)))
          .write(
        db.AiTasksCompanion(
          status: Value(task.status.name.toUpperCase()),
          attempts: Value(task.attempts),
          lastError: Value(task.lastError),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      await _record(task, row.payloadJson);
    });
  }

  Future<void> _record(AiTask task, String payloadJson) async {
    await _outbox?.enqueue(
      SyncOutboxEntry(
        id: _uuid.v4(),
        entityType: SyncEntityType.aiTask,
        entityId: task.id,
        operation: SyncOperation.upsert,
        payloadJson: jsonEncode({
          'id': task.id,
          'project_id': task.projectId,
          'status': task.status.name.toUpperCase(),
          'attempts': task.attempts,
          'last_error': task.lastError,
          'created_at': task.createdAt.toIso8601String(),
          'payload_json': jsonDecode(payloadJson),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }),
        createdAt: task.createdAt,
      ),
    );
  }

  AiTask _fromRow(
    db.AiTask row, {
    required AiTaskStatus status,
    int? attempts,
    String? lastError,
  }) =>
      AiTask(
        id: row.id,
        projectId: row.projectId,
        createdAt: row.createdAt,
        status: status,
        attempts: attempts ?? row.attempts,
        lastError: lastError ?? row.lastError,
      );
}
