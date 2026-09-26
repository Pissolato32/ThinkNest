import 'package:uuid/uuid.dart';

import '../../domain/document/document.dart';
import '../../domain/project/project_dna.dart';
import '../../domain/project/project_repository.dart';

class GenerateDocument {
  GenerateDocument(
    this._projectRepository,
    this._documentRepository, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final ProjectRepository _projectRepository;
  final DocumentRepository _documentRepository;
  final Uuid _uuid;

  Future<Document> call({
    required String projectId,
    required DocumentType type,
  }) async {
    final project = await _projectRepository.getById(projectId);
    if (project == null) {
      throw StateError('Projeto não encontrado: $projectId');
    }

    final dna = await _projectRepository.getDna(projectId);
    if (dna == null) {
      throw StateError('Project DNA não encontrado: $projectId');
    }

    final versions = await _documentRepository.getVersions(projectId, type);
    final version = versions.isEmpty ? 1 : versions.first.version + 1;
    final now = DateTime.now().toUtc();
    final title = type == DocumentType.prd
        ? 'Product Requirements Document'
        : 'Architecture Specification';

    final document = Document(
      id: _uuid.v4(),
      projectId: projectId,
      type: type,
      version: version,
      status: DocumentStatus.generated,
      title: title,
      content: _render(type, project.title, dna),
      dnaVersion: dna.version,
      createdAt: now,
      updatedAt: now,
    );

    await _documentRepository.create(document);
    return document;
  }

  String _render(DocumentType type, String title, ProjectDna dna) {
    return switch (type) {
      DocumentType.prd => _renderPrd(title, dna),
      DocumentType.architecture => _renderArchitecture(title, dna),
    };
  }

  String _renderPrd(String title, ProjectDna dna) {
    final identity = _lines(dna.identity);
    final pillars = _lines(dna.corePillars);
    final uncertainties = _bullets(dna.openUncertainties);
    final risks = _bullets(dna.knownRisks);

    return '''# $title

## Project DNA
DNA version: ${dna.version}

## Identity
$identity

## Core pillars
$pillars

## Open uncertainties
$uncertainties

## Known risks
$risks
''';
  }

  String _renderArchitecture(String title, ProjectDna dna) {
    final constraints = _lines(dna.technicalConstraints);
    final decisions = dna.keyDecisions
        .map(
          (item) => '- ${item['topic'] ?? 'Decision'}: '
              '${item['decision'] ?? item['value'] ?? ''}',
        )
        .join('\n');

    return '''# $title

## Project DNA
DNA version: ${dna.version}

## Technical constraints
$constraints

## Key decisions
${decisions.isEmpty ? '- None recorded.' : decisions}

## Architectural boundary
Project DNA remains the canonical project state. This document is an immutable
versioned artifact derived from that DNA version.
''';
  }

  String _lines(Map<String, Object?> values) {
    if (values.isEmpty) return '- None recorded.';
    return values.entries
        .map((item) => '- **${item.key}:** ${item.value}')
        .join('\n');
  }

  String _bullets(List<String> values) {
    if (values.isEmpty) return '- None recorded.';
    return values.map((item) => '- $item').join('\n');
  }
}
