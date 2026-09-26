enum AiTaskStatus { pending, running, completed, failed }

class AiTask {
  const AiTask({
    required this.id,
    required this.projectId,
    required this.createdAt,
    this.status = AiTaskStatus.pending,
    this.attempts = 0,
    this.lastError,
  });

  final String id;
  final String projectId;
  final DateTime createdAt;
  final AiTaskStatus status;
  final int attempts;
  final String? lastError;
}
