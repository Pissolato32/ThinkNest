import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../domain/project/dna/dna_inference.dart';
import '../../domain/project/project_repository.dart';
import '../../domain/project/project_snapshot.dart';
import 'dna_merger.dart';

class DnaProcessingResult {
  const DnaProcessingResult({
    required this.action,
    required this.appliedInferences,
    required this.pendingSuggestions,
    required this.clarifications,
    this.snapshot,
  });

  final DnaConfidenceAction action;
  final List<DnaInference> appliedInferences;
  final List<DnaInference> pendingSuggestions;
  final List<DnaInference> clarifications;
  final ProjectSnapshot? snapshot;
}

class ApplyDnaProposal {
  ApplyDnaProposal(
    this._repository, {
    DnaMerger? merger,
    DnaConfidenceGate? gate,
    Uuid? uuid,
  })  : _merger = merger ?? const DnaMerger(),
        _gate = gate ?? const DnaConfidenceGate(),
        _uuid = uuid ?? const Uuid();

  final ProjectRepository _repository;
  final DnaMerger _merger;
  final DnaConfidenceGate _gate;
  final Uuid _uuid;

  Future<DnaProcessingResult> call({
    required String projectId,
    required Iterable<DnaInference> inferences,
    bool approveSuggestions = false,
  }) async {
    final project = await _repository.getById(projectId);
    final dna = await _repository.getDna(projectId);
    if (project == null || dna == null) {
      throw StateError('Projeto ou Project DNA não encontrado.');
    }

    final applied = <DnaInference>[];
    final suggestions = <DnaInference>[];
    final clarifications = <DnaInference>[];

    for (final inference in inferences) {
      switch (_gate.evaluate(inference.confidence)) {
        case DnaConfidenceAction.autoApply:
          applied.add(inference);
        case DnaConfidenceAction.suggestApproval:
          if (approveSuggestions) {
            applied.add(inference);
          } else {
            suggestions.add(inference);
          }
        case DnaConfidenceAction.requestClarification:
          clarifications.add(inference);
      }
    }

    if (applied.isEmpty) {
      final action = clarifications.isNotEmpty
          ? DnaConfidenceAction.requestClarification
          : DnaConfidenceAction.suggestApproval;
      return DnaProcessingResult(
        action: action,
        appliedInferences: const [],
        pendingSuggestions: suggestions,
        clarifications: clarifications,
      );
    }

    final now = DateTime.now().toUtc();
    final merge = _merger.merge(dna, applied, updatedAt: now);
    if (!merge.changed) {
      return DnaProcessingResult(
        action: DnaConfidenceAction.autoApply,
        appliedInferences: const [],
        pendingSuggestions: suggestions,
        clarifications: clarifications,
      );
    }

    final snapshot = ProjectSnapshot(
      id: _uuid.v4(),
      projectId: project.id,
      projectVersion: merge.dna.version,
      createdAt: now,
      reason: 'DNA mutation approved by confidence gate',
      projectJson: jsonEncode({
        'id': project.id,
        'title': project.title,
        'category': project.category,
        'maturity': project.maturity.name,
        'is_pinned': project.isPinned,
        'is_archived': project.isArchived,
        'created_at': project.createdAt.toIso8601String(),
        'updated_at': project.updatedAt.toIso8601String(),
      }),
      dnaJson: jsonEncode(merge.dna.toJson()),
    );

    await _repository.saveDna(merge.dna);
    await _repository.createSnapshot(snapshot);

    return DnaProcessingResult(
      action: DnaConfidenceAction.autoApply,
      appliedInferences: applied,
      pendingSuggestions: suggestions,
      clarifications: clarifications,
      snapshot: snapshot,
    );
  }
}
