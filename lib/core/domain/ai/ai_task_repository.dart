import 'ai_task.dart';

abstract interface class AiTaskRepository {
  Future<void> enqueue(AiTask task, {required String payloadJson});

  Future<void> markCompleted(String id);

  Future<void> markPending(String id, {String? error});
}
