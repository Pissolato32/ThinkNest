import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thinknest/core/domain/project/project.dart';
import 'package:thinknest/core/domain/project/project_dna.dart';
import 'package:thinknest/core/infrastructure/database/thinknest_database.dart' hide Project;
import 'package:thinknest/core/infrastructure/project/drift_project_repository.dart';

void main() {
  late ThinkNestDatabase database;
  late DriftProjectRepository repository;

  setUp(() {
    database = ThinkNestDatabase(NativeDatabase.memory());
    repository = DriftProjectRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('persists project and DNA locally', () async {
    final now = DateTime.utc(2026, 1, 1);
    final project = Project(
      id: 'p1',
      title: 'Ideia local',
      createdAt: now,
      updatedAt: now,
    );
    final dna = ProjectDna(
      projectId: project.id,
      version: 1,
      updatedAt: now,
      identity: {'title': project.title},
    );

    await repository.create(project, dna: dna);

    final restored = await repository.getById(project.id);
    final restoredDna = await repository.getDna(project.id);

    expect(restored?.title, project.title);
    expect(restored?.maturity, ProjectMaturity.captured);
    expect(restoredDna?.identity['title'], project.title);
  });

  test('watchAll excludes archived projects', () async {
    final now = DateTime.utc(2026, 1, 1);
    await repository.create(
      Project(
        id: 'p1',
        title: 'Visível',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await repository.create(
      Project(
        id: 'p2',
        title: 'Arquivado',
        isArchived: true,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final projects = await repository.watchAll().first;

    expect(projects.map((item) => item.id), ['p1']);
  });
}
