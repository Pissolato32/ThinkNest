import 'package:drift/drift.dart';

import '../../domain/ai/ai_task.dart';
import '../../domain/ai/ai_task_repository.dart';
import '../database/thinknest_database.dart' as db;

class DriftAiTaskRepository implements AiTaskRepository {
  DriftAiTaskRepository(this._database);

  final db.ThinkNestDatabase _database;

  @override
  Future<void> enqueue(AiTask task, {required String payloadJson}) =>
      _database.into(_database.aiTasks).insertOnConflictUpdate(
            db.AiTasksCompanion.insert(
              id: task.id,
              projectId: task.projectId,
              status: Value(task.status.name.toUpperCase()),
              attempts: Value(task.attempts),
              lastError: Value(task.lastError),
              createdAt: task.createdAt,
              payloadJson: payloadJson,
            ),
          );

  @override
  Future<void> markCompleted(String id) =>
      (_database.update(_database.aiTasks)..where((row) => row.id.equals(id)))
          .write(const db.AiTasksCompanion(status: Value('COMPLETED')));

  @override
  Future<void> markPending(String id, {String? error}) =>
      (_database.update(_database.aiTasks)..where((row) => row.id.equals(id)))
          .write(
        db.AiTasksCompanion(
          status: const Value('PENDING'),
          lastError: Value(error),
          attempts: const Value(1),
        ),
      );
}
