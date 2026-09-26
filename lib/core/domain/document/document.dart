enum DocumentType { prd, architecture }

enum DocumentStatus { draft, generated, userReviewed, approved, archived }

class Document {
  const Document({
    required this.id,
    required this.projectId,
    required this.type,
    required this.version,
    required this.status,
    required this.title,
    required this.content,
    required this.dnaVersion,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String projectId;
  final DocumentType type;
  final int version;
  final DocumentStatus status;
  final String title;
  final String content;
  final int dnaVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
}
