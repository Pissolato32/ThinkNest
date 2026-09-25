class ProjectSnapshot {
  const ProjectSnapshot({
    required this.id,
    required this.projectId,
    required this.projectVersion,
    required this.createdAt,
    required this.reason,
    required this.projectJson,
    required this.dnaJson,
  });

  final String id;
  final String projectId;
  final int projectVersion;
  final DateTime createdAt;
  final String reason;
  final String projectJson;
  final String dnaJson;
}
