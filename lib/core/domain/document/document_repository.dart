import 'document.dart';

abstract interface class DocumentRepository {
  Future<void> create(Document document);
  Future<Document?> getById(String id);
  Stream<List<Document>> watchByProject(String projectId);
  Future<List<Document>> getVersions(String projectId, DocumentType type);
  Future<void> updateStatus(
    String id,
    DocumentStatus status,
    DateTime updatedAt,
  );
}
