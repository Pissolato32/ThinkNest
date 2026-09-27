enum SyncEntityType {
  project,
  projectDna,
  projectSnapshot,
  document,
  conversationMessage,
  aiTask,
}

enum SyncOperation {
  upsert,
  delete,
}

class SyncOutboxEntry {
  const SyncOutboxEntry({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payloadJson,
    required this.createdAt,
    this.attempts = 0,
    this.lastError,
  });

  final String id;
  final SyncEntityType entityType;
  final String entityId;
  final SyncOperation operation;
  final String payloadJson;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;

  SyncOutboxEntry copyWith({
    int? attempts,
    String? lastError,
  }) {
    return SyncOutboxEntry(
      id: id,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payloadJson: payloadJson,
      createdAt: createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
    );
  }
}
