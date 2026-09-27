import 'ai_task.dart';

abstract interface class AiTaskRepository {
  Future<void> enqueue(AiTask task, {required String payloadJson});

  Future<List<AiTask>> listPending();

  Future<String?> payloadFor(String id);

  Future<void> markRunning(String id);

  Future<void> markCompleted(String id);

  Future<void> markPending(String id, {String? error});

  Future<void> markFailed(String id, {required String error});
}
