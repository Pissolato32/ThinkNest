import 'package:flutter_test/flutter_test.dart';
import 'package:thinknest/core/application/readiness/evaluate_readiness.dart';
import 'package:thinknest/core/domain/document/document.dart';
import 'package:thinknest/core/domain/project/project_dna.dart';
import 'package:thinknest/core/domain/readiness/readiness.dart';

void main() {
  final now = DateTime.utc(2026, 1, 1);

  Document document({
    required DocumentType type,
    DocumentStatus status = DocumentStatus.approved,
  }) {
    return Document(
      id: type == DocumentType.prd ? 'd-prd' : 'd-architecture',
      projectId: 'p1',
      type: type,
      version: 1,
      status: status,
      title: type == DocumentType.prd ? 'PRD' : 'Architecture',
      content: 'content',
      dnaVersion: 3,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('blocks readiness when critical structure is missing', () {
    final dna = ProjectDna(
      projectId: 'p1',
      version: 1,
      updatedAt: now,
    );

    final report = ReadinessEvaluator.evaluate(
      dna,
      prdDocuments: const [],
      architectureDocuments: const [],
    );

    expect(report.status, ReadinessStatus.notReady);
    expect(
      report.blockers.map((item) => item.code),
      contains('problem_statement'),
    );
    expect(
      report.blockers.map((item) => item.code),
      contains('target_audience'),
    );
    expect(
      report.blockers.map((item) => item.code),
      contains('tech_stack'),
    );
    expect(report.blockers.map((item) => item.code), contains('prd'));
    expect(
      report.blockers.map((item) => item.code),
      contains('architecture'),
    );
  });

  test('returns ready with warnings when required structure exists', () {
    final dna = ProjectDna(
      projectId: 'p1',
      version: 3,
      updatedAt: now,
      corePillars: {
        'problem_statement': 'People need this.',
        'target_audience': ['Users'],
        'value_proposition': 'A useful result.',
      },
      technicalConstraints: {
        'preferred_stack': ['Flutter', 'Dart'],
      },
    );

    final report = ReadinessEvaluator.evaluate(
      dna,
      prdDocuments: [document(type: DocumentType.prd)],
      architectureDocuments: [document(type: DocumentType.architecture)],
    );

    expect(report.status, ReadinessStatus.readyWithWarnings);
    expect(report.blockers, isEmpty);
    expect(
      report.warnings.map((item) => item.code),
      contains('key_decisions'),
    );
    expect(
      report.warnings.map((item) => item.code),
      isNot(contains('scope_constraints')),
    );
  });

  test('returns ready when dimensions are complete and documents are approved',
      () {
    final dna = ProjectDna(
      projectId: 'p1',
      version: 3,
      updatedAt: now,
      corePillars: {
        'problem_statement': 'People need this.',
        'target_audience': ['Users'],
        'value_proposition': 'A useful result.',
      },
      technicalConstraints: {
        'preferred_stack': ['Flutter', 'Dart'],
        'platforms': ['Android', 'Web'],
      },
      keyDecisions: const [
        {'topic': 'Scope', 'decision': 'Keep the MVP focused.'},
      ],
    );

    final report = ReadinessEvaluator.evaluate(
      dna,
      prdDocuments: [document(type: DocumentType.prd)],
      architectureDocuments: [document(type: DocumentType.architecture)],
    );

    expect(report.status, ReadinessStatus.ready);
    expect(report.isReady, isTrue);
    expect(report.recommendations, isEmpty);
  });

  test('warns when generated documents still need human approval', () {
    final dna = ProjectDna(
      projectId: 'p1',
      version: 3,
      updatedAt: now,
      corePillars: {
        'problem_statement': 'People need this.',
        'target_audience': ['Users'],
        'value_proposition': 'A useful result.',
      },
      technicalConstraints: {
        'preferred_stack': ['Flutter', 'Dart'],
      },
      keyDecisions: const [
        {'topic': 'Scope', 'decision': 'Keep the MVP focused.'},
      ],
    );

    final report = ReadinessEvaluator.evaluate(
      dna,
      prdDocuments: [
        document(
          type: DocumentType.prd,
          status: DocumentStatus.generated,
        ),
      ],
      architectureDocuments: [
        document(
          type: DocumentType.architecture,
          status: DocumentStatus.approved,
        ),
      ],
    );

    expect(report.status, ReadinessStatus.readyWithWarnings);
    expect(
      report.warnings.map((item) => item.code),
      contains('document_not_approved_prd'),
    );
  });
}
