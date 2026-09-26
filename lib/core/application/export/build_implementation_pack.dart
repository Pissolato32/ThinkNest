import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../../domain/document/document.dart';
import '../../domain/document/document_repository.dart';
import '../../domain/export/implementation_pack.dart';
import '../../domain/project/project_repository.dart';

class BuildImplementationPack {
  BuildImplementationPack(
    this._projectRepository,
    this._documentRepository, {
    Uuid? uuid,
    DateTime Function()? clock,
  })  : _uuid = uuid ?? const Uuid(),
        _clock = clock ?? (() => DateTime.now().toUtc());

  final ProjectRepository _projectRepository;
  final DocumentRepository _documentRepository;
  final Uuid _uuid;
  final DateTime Function() _clock;

  Future<ImplementationPack> call({
    required String projectId,
    ExportProfile profile = ExportProfile.generic,
  }) async {
    final project = await _projectRepository.getById(projectId);
    if (project == null) {
      throw StateError('Projeto não encontrado: $projectId');
    }

    final dna = await _projectRepository.getDna(projectId);
    if (dna == null) {
      throw StateError('Project DNA não encontrado: $projectId');
    }

    final prd = await _latestApproved(projectId, DocumentType.prd);
    final architecture =
        await _latestApproved(projectId, DocumentType.architecture);
    if (prd == null || architecture == null) {
      throw StateError(
        'Implementation Pack exige PRD e Architecture aprovados.',
      );
    }

    final now = _clock();
    final exportId = _uuid.v4();
    final files = <String, String>{
      'PROJECT_DNA.json': _prettyJson(dna.toJson()),
      'docs/PRD.md': prd.content,
      'docs/ARCHITECTURE.md': architecture.content,
      'DECISIONS.json': _prettyJson({
        'project_id': projectId,
        'dna_version': dna.version,
        'decisions': dna.keyDecisions,
      }),
      'PROMPTS.md': _prompts(project.title),
      '.cursorrules': _cursorRules(),
    };

    final entries = files.entries
        .map(
          (entry) => ImplementationPackFile(
            path: entry.key,
            content: entry.value,
            sha256: _sha256(entry.value),
          ),
        )
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    final manifest = _prettyJson({
      'format': 'thinknest-implementation-pack',
      'format_version': 1,
      'export_id': exportId,
      'version': 1,
      'project_id': projectId,
      'project_title': project.title,
      'profile': profile.name,
      'created_at': now.toIso8601String(),
      'source': {
        'dna_version': dna.version,
        'prd_version': prd.version,
        'architecture_version': architecture.version,
      },
      'files': [
        for (final file in entries)
          {
            'path': file.path,
            'sha256': file.sha256,
          },
      ],
    });

    final archive = Archive()
      ..addFile(ArchiveFile.string('MANIFEST.json', manifest));
    for (final file in entries) {
      archive.addFile(ArchiveFile.string(file.path, file.content));
    }

    return ImplementationPack(
      exportId: exportId,
      version: 1,
      projectId: projectId,
      profile: profile,
      createdAt: now,
      files: entries,
      manifest: manifest,
      zipBytes: ZipEncoder().encode(archive),
    );
  }

  Future<Document?> _latestApproved(
    String projectId,
    DocumentType type,
  ) async {
    final versions = await _documentRepository.getVersions(projectId, type);
    for (final document in versions) {
      if (document.status == DocumentStatus.approved) return document;
    }
    return null;
  }

  String _prettyJson(Object value) {
    return const JsonEncoder.withIndent('  ').convert(value);
  }

  String _sha256(String value) {
    return sha256.convert(utf8.encode(value)).toString();
  }

  String _prompts(String projectTitle) {
    return '''# Implementation Prompts

## Primary handoff

Implement the project described by the attached Project DNA, PRD, and Architecture.
Treat those artifacts as the source of truth. Do not invent requirements that are
not present in the pack. Ask for clarification when a requirement is ambiguous.

## Project

$projectTitle

## Execution rules

1. Read PROJECT_DNA.json before making implementation decisions.
2. Treat approved documents as immutable specifications.
3. Preserve explicit technical constraints and key decisions.
4. Surface conflicts instead of silently resolving them.
5. Keep changes scoped to the approved project.
''';
  }

  String _cursorRules() {
    return '''# ThinkNest Implementation Rules

- PROJECT_DNA.json is the canonical project context.
- Read docs/PRD.md and docs/ARCHITECTURE.md before implementation.
- Do not silently invent requirements.
- Preserve approved technical decisions.
- Ask for clarification when specifications conflict or are incomplete.
- Keep implementation changes traceable to the pack artifacts.
''';
  }
}
