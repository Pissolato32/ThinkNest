import 'package:flutter_test/flutter_test.dart';
import 'package:thinknest/core/application/dna/apply_dna_proposal.dart';
import 'package:thinknest/core/domain/project/dna/dna_inference.dart';
import 'package:thinknest/core/domain/project/project.dart';
import 'package:thinknest/core/domain/project/project_dna.dart';
import 'package:thinknest/core/domain/project/project_repository.dart';
import 'package:thinknest/core/domain/project/project_snapshot.dart';

class FakeProjectRepository implements ProjectRepository {
  FakeProjectRepository(this.project, this.dna);

  Project? project;
  ProjectDna? dna;
  final List<ProjectSnapshot> snapshots = [];

  @override
  Future<Project?> getById(String id) async =>
      project?.id == id ? project : null;

  @override
  Stream<List<Project>> watchAll() =>
      Stream.value([if (project != null) project!]);

  @override
  Future<void> create(Project project, {ProjectDna? dna}) async {
    this.project = project;
    this.dna = dna;
  }

  @override
  Future<void> update(Project project) async => this.project = project;

  @override
  Future<void> delete(String id) async => project = null;

  @override
  Future<ProjectDna?> getDna(String projectId) async => dna;

  @override
  Future<void> saveDna(ProjectDna dna) async => this.dna = dna;

  @override
  Future<void> createSnapshot(ProjectSnapshot snapshot) async =>
      snapshots.add(snapshot);
}

void main() {
  final now = DateTime.utc(2026, 1, 1);

  FakeProjectRepository repository() =>
      FakeProjectRepository(
        Project(id: 'p1', title: 'Idea', createdAt: now, updatedAt: now),
        ProjectDna(projectId: 'p1', version: 1, updatedAt: now),
      );

  test('auto-applies high-confidence inference and creates snapshot', () async {
    final fake = repository();
    final result = await ApplyDnaProposal(fake)(
      projectId: 'p1',
      inferences: const [
        DnaInference(
          type: DnaInferenceType.technicalConstraint,
          key: 'offline_first',
          value: true,
          confidence: 0.99,
        ),
      ],
    );

    expect(result.action, DnaConfidenceAction.autoApply);
    expect(fake.dna?.version, 2);
    expect(fake.dna?.technicalConstraints['offline_first'], true);
    expect(fake.snapshots, hasLength(1));
    expect(fake.snapshots.single.projectVersion, 2);
  });

  test('holds medium-confidence inference for human approval', () async {
    final fake = repository();
    final result = await ApplyDnaProposal(fake)(
      projectId: 'p1',
      inferences: const [
        DnaInference(
          type: DnaInferenceType.decision,
          key: 'stack',
          value: 'Flutter',
          confidence: 0.90,
        ),
      ],
    );

    expect(result.action, DnaConfidenceAction.suggestApproval);
    expect(result.pendingSuggestions, hasLength(1));
    expect(fake.dna?.version, 1);
    expect(fake.snapshots, isEmpty);
  });

  test('requires clarification below confidence threshold', () async {
    final fake = repository();
    final result = await ApplyDnaProposal(fake)(
      projectId: 'p1',
      inferences: const [
        DnaInference(
          type: DnaInferenceType.risk,
          key: 'risk',
          value: 'Dependência externa',
          confidence: 0.70,
        ),
      ],
    );

    expect(result.action, DnaConfidenceAction.requestClarification);
    expect(result.clarifications, hasLength(1));
    expect(fake.dna?.version, 1);
  });

  test('approved suggestion mutates DNA', () async {
    final fake = repository();
    final result = await ApplyDnaProposal(fake)(
      projectId: 'p1',
      approveSuggestions: true,
      inferences: const [
        DnaInference(
          type: DnaInferenceType.uncertainty,
          key: 'pricing',
          value: 'Pricing ainda não definida',
          confidence: 0.85,
        ),
      ],
    );

    expect(result.appliedInferences, hasLength(1));
    expect(fake.dna?.openUncertainties, ['Pricing ainda não definida']);
    expect(fake.dna?.version, 2);
  });
}
