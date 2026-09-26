import 'package:flutter_test/flutter_test.dart';
import 'package:thinknest/core/application/project/create_project.dart';
import 'package:thinknest/core/domain/project/project.dart';
import 'package:thinknest/core/domain/project/project_dna.dart';
import 'package:thinknest/core/domain/project/project_repository.dart';

class _FakeProjectRepository implements ProjectRepository {
  Project? project;
  ProjectDna? dna;

  @override
  Future<void> create(Project project, {ProjectDna? dna}) async {
    this.project = project;
    this.dna = dna;
  }

  @override
  Future<Project?> getById(String id) async => project;

  @override
  Stream<List<Project>> watchAll() =>
      Stream.value(project == null ? [] : [project!]);

  @override
  Future<void> update(Project project) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<ProjectDna?> getDna(String projectId) async => dna;

  @override
  Future<void> saveDna(ProjectDna dna) async {
    this.dna = dna;
  }
}

void main() {
  test('creates a captured project and initial DNA', () async {
    final repository = _FakeProjectRepository();
    final create = CreateProject(repository);

    final project = await create(title: '  Minha ideia  ');

    expect(project.title, 'Minha ideia');
    expect(project.maturity, ProjectMaturity.captured);
    expect(repository.project?.id, project.id);
    expect(repository.dna?.projectId, project.id);
    expect(repository.dna?.identity['title'], 'Minha ideia');
  });

  test('rejects an empty idea before persistence', () async {
    final repository = _FakeProjectRepository();
    final create = CreateProject(repository);

    expect(
      () => create(title: '   '),
      throwsA(isA<ArgumentError>()),
    );
    expect(repository.project, isNull);
  });
}
