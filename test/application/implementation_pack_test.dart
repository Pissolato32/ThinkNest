import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thinknest/core/application/export/build_implementation_pack.dart';
import 'package:thinknest/core/domain/document/document.dart';
import 'package:thinknest/core/domain/document/document_repository.dart';
import 'package:thinknest/core/domain/export/implementation_pack.dart';
import 'package:thinknest/core/domain/project/project.dart';
import 'package:thinknest/core/domain/project/project_dna.dart';
import 'package:thinknest/core/domain/project/project_repository.dart';
import 'package:thinknest/core/domain/project/project_snapshot.dart';

void main() {
  final now = DateTime.utc(2026, 1, 1);

  test(
    'builds a hashed zip implementation pack from approved artifacts',
    () async {
      final project = Project(
        id: 'p1',
        title: 'ThinkNest Demo',
        createdAt: now,
        updatedAt: now,
      );
      final dna = ProjectDna(
        projectId: 'p1',
        version: 4,
        updatedAt: now,
        identity: const {'title': 'ThinkNest Demo'},
        corePillars: const {
          'problem_statement': 'Ideas need structure.',
          'target_audience': ['Creators'],
          'value_proposition': 'Turn ideas into specifications.',
        },
        technicalConstraints: const {
          'preferred_stack': ['Flutter', 'Dart'],
        },
        keyDecisions: const [
          {'topic': 'Architecture', 'decision': 'Use DDD.'},
        ],
      );
      final prd = _document(now, DocumentType.prd, '# PRD');
      final architecture = _document(
        now,
        DocumentType.architecture,
        '# Architecture',
      );

      final builder = BuildImplementationPack(
        _FakeProjectRepository(project, dna),
        _FakeDocumentRepository([prd, architecture]),
        clock: () => now,
      );

      final pack =
          await builder(projectId: 'p1', profile: ExportProfile.cursor);

      expect(pack.exportId, isNotEmpty);
      expect(pack.version, 1);
      expect(pack.profile, ExportProfile.cursor);
      expect(pack.files.map((file) => file.path), contains('PROJECT_DNA.json'));
      expect(pack.files.map((file) => file.path), contains('.cursorrules'));
      expect(pack.files.map((file) => file.path), contains('DECISIONS.json'));

      for (final file in pack.files) {
        expect(
          file.sha256,
          sha256.convert(utf8.encode(file.content)).toString(),
        );
      }

      final manifest = jsonDecode(pack.manifest) as Map<String, dynamic>;
      expect(manifest['export_id'], pack.exportId);
      expect(manifest['source']['dna_version'], 4);

      final archive = ZipDecoder().decodeBytes(pack.zipBytes);
      final names = archive.files.map((file) => file.name).toSet();
      expect(names, contains('MANIFEST.json'));
      expect(names, contains('PROJECT_DNA.json'));
      expect(names, contains('docs/PRD.md'));
      expect(names, contains('docs/ARCHITECTURE.md'));
    },
  );

  test('rejects export until both required documents are approved', () async {
    final project = Project(
      id: 'p1',
      title: 'ThinkNest Demo',
      createdAt: now,
      updatedAt: now,
    );
    final dna = ProjectDna(
      projectId: 'p1',
      version: 1,
      updatedAt: now,
    );
    final generatedPrd = _document(
      now,
      DocumentType.prd,
      '# PRD',
      status: DocumentStatus.generated,
    );
    final approvedArchitecture = _document(
      now,
      DocumentType.architecture,
      '# Architecture',
    );

    final builder = BuildImplementationPack(
      _FakeProjectRepository(project, dna),
      _FakeDocumentRepository([generatedPrd, approvedArchitecture]),
      clock: () => now,
    );

    await expectLater(
      builder(projectId: 'p1'),
      throwsStateError,
    );
  });
}

Document _document(
  DateTime now,
  DocumentType type,
  String content, {
  DocumentStatus status = DocumentStatus.approved,
}) {
  return Document(
    id: type.name + '-1',
    projectId: 'p1',
    type: type,
    version: 1,
    status: status,
    title: type == DocumentType.prd ? 'PRD' : 'Architecture',
    content: content,
    dnaVersion: 4,
    createdAt: now,
    updatedAt: now,
  );
}

class _FakeProjectRepository implements ProjectRepository {
  _FakeProjectRepository(this.project, this.dna);

  final Project project;
  final ProjectDna dna;

  @override
  Future<Project?> getById(String id) async =>
      id == project.id ? project : null;

  @override
  Stream<List<Project>> watchAll() => Stream.value([project]);

  @override
  Future<void> create(Project project, {ProjectDna? dna}) async {}

  @override
  Future<void> update(Project project) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<ProjectDna?> getDna(String projectId) async =>
      projectId == dna.projectId ? dna : null;

  @override
  Future<void> saveDna(ProjectDna dna) async {}

  @override
  Future<void> createSnapshot(ProjectSnapshot snapshot) async {}
}

class _FakeDocumentRepository implements DocumentRepository {
  _FakeDocumentRepository(this.documents);

  final List<Document> documents;

  @override
  Future<void> create(Document document) async {}

  @override
  Future<Document?> getById(String id) async {
    for (final document in documents) {
      if (document.id == id) return document;
    }
    return null;
  }

  @override
  Stream<List<Document>> watchByProject(String projectId) =>
      Stream.value(documents);

  @override
  Future<List<Document>> getVersions(
    String projectId,
    DocumentType type,
  ) async {
    return documents.where((document) => document.type == type).toList()
      ..sort((a, b) => b.version.compareTo(a.version));
  }

  @override
  Future<void> updateStatus(
    String id,
    DocumentStatus status,
    DateTime updatedAt,
  ) async {}
}
