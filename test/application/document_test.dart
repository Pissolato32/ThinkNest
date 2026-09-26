import 'package:flutter_test/flutter_test.dart';
import 'package:thinknest/core/application/document/change_document_status.dart';
import 'package:thinknest/core/application/document/document_lifecycle.dart';
import 'package:thinknest/core/application/document/generate_document.dart';
import 'package:thinknest/core/domain/document/document.dart';
import 'package:thinknest/core/domain/document/document_repository.dart';
import 'package:thinknest/core/domain/project/project.dart';
import 'package:thinknest/core/domain/project/project_dna.dart';
import 'package:thinknest/core/domain/project/project_repository.dart';
import 'package:thinknest/core/domain/project/project_snapshot.dart';

class _ProjectRepository implements ProjectRepository {
  _ProjectRepository(this.project, this.dna);

  Project project;
  ProjectDna dna;

  @override
  Future<Project?> getById(String id) async =>
      project.id == id ? project : null;

  @override
  Stream<List<Project>> watchAll() => Stream.value([project]);

  @override
  Future<void> create(Project project, {ProjectDna? dna}) async {}

  @override
  Future<void> update(Project project) async => this.project = project;

  @override
  Future<void> delete(String id) async {}

  @override
  Future<ProjectDna?> getDna(String projectId) async =>
      dna.projectId == projectId ? dna : null;

  @override
  Future<void> saveDna(ProjectDna dna) async => this.dna = dna;

  @override
  Future<void> createSnapshot(ProjectSnapshot snapshot) async {}
}

class _DocumentRepository implements DocumentRepository {
  final List<Document> documents = [];

  @override
  Future<void> create(Document document) async => documents.add(document);

  @override
  Future<Document?> getById(String id) async {
    for (final document in documents) {
      if (document.id == id) return document;
    }
    return null;
  }

  @override
  Stream<List<Document>> watchByProject(String projectId) => Stream.value(
        documents.where((item) => item.projectId == projectId).toList(),
      );

  @override
  Future<List<Document>> getVersions(
    String projectId,
    DocumentType type,
  ) async =>
      documents
          .where((item) => item.projectId == projectId && item.type == type)
          .toList()
        ..sort((a, b) => b.version.compareTo(a.version));

  @override
  Future<void> updateStatus(
    String id,
    DocumentStatus status,
    DateTime updatedAt,
  ) async {
    final index = documents.indexWhere((item) => item.id == id);
    documents[index] = Document(
      id: documents[index].id,
      projectId: documents[index].projectId,
      type: documents[index].type,
      version: documents[index].version,
      status: status,
      title: documents[index].title,
      content: documents[index].content,
      dnaVersion: documents[index].dnaVersion,
      createdAt: documents[index].createdAt,
      updatedAt: updatedAt,
    );
  }
}

void main() {
  final now = DateTime.utc(2026, 1, 1);

  test('generates a PRD from the exact DNA version', () async {
    final project = Project(
      id: 'p1',
      title: 'Minha ideia',
      createdAt: now,
      updatedAt: now,
    );
    final dna = ProjectDna(
      projectId: 'p1',
      version: 4,
      updatedAt: now,
      identity: {'one_liner': 'Uma ideia estruturada'},
      corePillars: {'problem_statement': 'Resolver algo'},
      openUncertainties: ['Modelo de preço'],
    );
    final documents = _DocumentRepository();

    final document = await GenerateDocument(
      _ProjectRepository(project, dna),
      documents,
    )(
      projectId: 'p1',
      type: DocumentType.prd,
    );

    expect(document.version, 1);
    expect(document.status, DocumentStatus.generated);
    expect(document.dnaVersion, 4);
    expect(document.content, contains('DNA version: 4'));
    expect(document.content, contains('Modelo de preço'));
  });

  test('enforces the deterministic lifecycle', () {
    expect(
      DocumentLifecycle.canTransition(
        DocumentStatus.generated,
        DocumentStatus.userReviewed,
      ),
      isTrue,
    );
    expect(
      DocumentLifecycle.canTransition(
        DocumentStatus.generated,
        DocumentStatus.approved,
      ),
      isFalse,
    );
    expect(
      DocumentLifecycle.canTransition(
        DocumentStatus.archived,
        DocumentStatus.generated,
      ),
      isFalse,
    );
  });

  test('changes status only through valid lifecycle transition', () async {
    final documents = _DocumentRepository();
    final document = Document(
      id: 'd1',
      projectId: 'p1',
      type: DocumentType.prd,
      version: 1,
      status: DocumentStatus.generated,
      title: 'PRD',
      content: 'content',
      dnaVersion: 1,
      createdAt: now,
      updatedAt: now,
    );
    await documents.create(document);

    await ChangeDocumentStatus(documents)(
      documentId: 'd1',
      nextStatus: DocumentStatus.userReviewed,
    );

    expect(
      (await documents.getById('d1'))?.status,
      DocumentStatus.userReviewed,
    );

    expect(
      () => ChangeDocumentStatus(documents)(
        documentId: 'd1',
        nextStatus: DocumentStatus.approved,
      ),
      throwsStateError,
    );
  });
}
