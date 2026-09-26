import '../../domain/document/document.dart';
import '../../domain/document/document_repository.dart';
import '../../domain/project/project_dna.dart';
import '../../domain/project/project_repository.dart';
import '../../domain/readiness/readiness.dart';

class EvaluateReadiness {
  EvaluateReadiness(
    this._projectRepository,
    this._documentRepository,
  );

  final ProjectRepository _projectRepository;
  final DocumentRepository _documentRepository;

  Future<ReadinessReport> call(String projectId) async {
    final dna = await _projectRepository.getDna(projectId);
    if (dna == null) {
      throw StateError('Project DNA não encontrado: $projectId');
    }

    final prdDocuments = await _documentRepository.getVersions(
      projectId,
      DocumentType.prd,
    );
    final architectureDocuments = await _documentRepository.getVersions(
      projectId,
      DocumentType.architecture,
    );

    return ReadinessEvaluator.evaluate(
      dna,
      prdDocuments: prdDocuments,
      architectureDocuments: architectureDocuments,
    );
  }
}

class ReadinessEvaluator {
  const ReadinessEvaluator._();

  static ReadinessReport evaluate(
    ProjectDna dna, {
    required List<Document> prdDocuments,
    required List<Document> architectureDocuments,
  }) {
    final dimensions = <ReadinessDimension>[
      _dimension(
        'problem_statement',
        'Problem Statement',
        _text(dna.corePillars['problem_statement']),
      ),
      _dimension(
        'target_audience',
        'Target Audience',
        _hasCollection(dna.corePillars['target_audience']),
      ),
      _dimension(
        'value_proposition',
        'Value Proposition',
        _text(dna.corePillars['value_proposition']),
      ),
      _dimension(
        'tech_stack',
        'Tech Stack Definition',
        _hasCollection(dna.technicalConstraints['preferred_stack']),
      ),
      _dimension(
        'scope_constraints',
        'Technical Constraints',
        dna.technicalConstraints.isNotEmpty,
      ),
      _dimension(
        'key_decisions',
        'Key Decisions',
        dna.keyDecisions.isNotEmpty,
      ),
      _dimension('prd', 'PRD Document', prdDocuments.isNotEmpty),
      _dimension(
        'architecture',
        'Architecture Document',
        architectureDocuments.isNotEmpty,
      ),
    ];

    final blockers = <ReadinessFinding>[];
    final warnings = <ReadinessFinding>[];

    _addMissingBlocker(
      blockers,
      dimensions,
      'problem_statement',
      'O Problem Statement ainda não está definido.',
      'Defina claramente qual problema o projeto resolve.',
    );
    _addMissingBlocker(
      blockers,
      dimensions,
      'target_audience',
      'O público-alvo ainda não está definido.',
      'Registre quem é o usuário ou público principal.',
    );
    _addMissingBlocker(
      blockers,
      dimensions,
      'tech_stack',
      'A stack técnica preferencial ainda não está definida.',
      'Registre a stack técnica necessária para execução.',
    );
    _addMissingBlocker(
      blockers,
      dimensions,
      'prd',
      'Nenhuma versão de PRD foi gerada.',
      'Gere um PRD a partir do Project DNA.',
    );
    _addMissingBlocker(
      blockers,
      dimensions,
      'architecture',
      'Nenhuma versão de Architecture foi gerada.',
      'Gere a especificação de arquitetura a partir do Project DNA.',
    );

    _addMissingWarning(
      warnings,
      dimensions,
      'value_proposition',
      'A proposta de valor ainda não está explícita.',
      'Defina o resultado de valor esperado para o usuário.',
    );
    _addMissingWarning(
      warnings,
      dimensions,
      'scope_constraints',
      'As restrições técnicas ainda não estão registradas.',
      'Registre plataformas, limites e restrições relevantes.',
    );
    _addMissingWarning(
      warnings,
      dimensions,
      'key_decisions',
      'Nenhuma decisão importante foi registrada.',
      'Registre decisões que já estejam suficientemente definidas.',
    );

    if (dna.openUncertainties.isNotEmpty) {
      warnings.add(
        const ReadinessFinding(
          code: 'open_uncertainties',
          severity: ReadinessFindingSeverity.warning,
          message: 'Existem incertezas ainda abertas.',
          recommendation:
              'Resolva ou aceite explicitamente as incertezas restantes.',
        ),
      );
    }

    if (dna.knownRisks.isNotEmpty) {
      warnings.add(
        const ReadinessFinding(
          code: 'known_risks',
          severity: ReadinessFindingSeverity.warning,
          message: 'Existem riscos conhecidos registrados no Project DNA.',
          recommendation:
              'Revise os riscos e registre mitigação quando aplicável.',
        ),
      );
    }

    _addDocumentLifecycleWarnings(warnings, prdDocuments);
    _addDocumentLifecycleWarnings(warnings, architectureDocuments);

    final recommendations = <String>{
      ...blockers.map((item) => item.recommendation),
      ...warnings.map((item) => item.recommendation),
    }.toList();

    final satisfiedCount =
        dimensions.where((dimension) => dimension.satisfied).length;

    final status = satisfiedCount == 0
        ? ReadinessStatus.notReady
        : blockers.isNotEmpty
            ? ReadinessStatus.blocked
            : warnings.isNotEmpty
                ? ReadinessStatus.readyWithWarnings
                : ReadinessStatus.ready;

    return ReadinessReport(
      status: status,
      dimensions: dimensions,
      blockers: List.unmodifiable(blockers),
      warnings: List.unmodifiable(warnings),
      recommendations: List.unmodifiable(recommendations),
    );
  }

  static ReadinessDimension _dimension(
    String key,
    String label,
    bool satisfied,
  ) =>
      ReadinessDimension(
        key: key,
        label: label,
        satisfied: satisfied,
      );

  static void _addMissingBlocker(
    List<ReadinessFinding> findings,
    List<ReadinessDimension> dimensions,
    String key,
    String message,
    String recommendation,
  ) {
    final dimension = dimensions.firstWhere((item) => item.key == key);
    if (!dimension.satisfied) {
      findings.add(
        ReadinessFinding(
          code: key,
          severity: ReadinessFindingSeverity.blocker,
          message: message,
          recommendation: recommendation,
        ),
      );
    }
  }

  static void _addMissingWarning(
    List<ReadinessFinding> findings,
    List<ReadinessDimension> dimensions,
    String key,
    String message,
    String recommendation,
  ) {
    final dimension = dimensions.firstWhere((item) => item.key == key);
    if (!dimension.satisfied) {
      findings.add(
        ReadinessFinding(
          code: key,
          severity: ReadinessFindingSeverity.warning,
          message: message,
          recommendation: recommendation,
        ),
      );
    }
  }

  static void _addDocumentLifecycleWarnings(
    List<ReadinessFinding> findings,
    List<Document> documents,
  ) {
    if (documents.isEmpty) return;

    final latest = documents.first;
    if (latest.status != DocumentStatus.approved) {
      findings.add(
        ReadinessFinding(
          code: 'document_not_approved_${latest.type.name}',
          severity: ReadinessFindingSeverity.warning,
          message: '${latest.title} ainda não foi aprovado pelo usuário.',
          recommendation:
              'Revise o documento e avance seu lifecycle até Approved.',
        ),
      );
    }
  }

  static bool _text(Object? value) =>
      value is String && value.trim().isNotEmpty;

  static bool _hasCollection(Object? value) {
    if (value is Iterable<Object?>) {
      return value.any((item) => item != null);
    }
    return _text(value);
  }
}
