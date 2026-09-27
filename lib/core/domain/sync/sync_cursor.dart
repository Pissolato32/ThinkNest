class SyncCursor {
  const SyncCursor({
    required this.entityType,
    this.lastTimestamp,
    this.lastEntityId,
  });

  final String entityType;
  final DateTime? lastTimestamp;
  final String? lastEntityId;
}
