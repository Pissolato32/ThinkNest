import '../../domain/document/document.dart';
import '../../domain/document/document_repository.dart';
import 'document_lifecycle.dart';

class ChangeDocumentStatus {
  ChangeDocumentStatus(this._repository);

  final DocumentRepository _repository;

  Future<void> call({
    required String documentId,
    required DocumentStatus nextStatus,
  }) async {
    final document = await _repository.getById(documentId);
    if (document == null) {
      throw StateError('Documento não encontrado: $documentId');
    }

    DocumentLifecycle.validate(document.status, nextStatus);
    await _repository.updateStatus(
      documentId,
      nextStatus,
      DateTime.now().toUtc(),
    );
  }
}
