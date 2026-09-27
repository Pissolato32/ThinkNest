import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thinknest/core/domain/project/project.dart';
import 'package:thinknest/core/domain/project/project_dna.dart';
import 'package:thinknest/core/domain/project/project_snapshot.dart';
import 'package:thinknest/core/infrastructure/database/thinknest_database.dart'
    hide Project, ProjectSnapshot;
import 'package:thinknest/core/infrastructure/project/drift_project_repository.dart';
import 'package:thinknest/core/infrastructure/sync/drift_sync_outbox_repository.dart';

void main() {
  late ThinkNestDatabase database;
  late DriftProjectRepository repository;
  late DriftSyncOutboxRepository outbox;

  setUp(() {
    database = ThinkNestDatabase(NativeDatabase.memory());
    outbox = DriftSyncOutboxRepository(database);
    repository = DriftProjectRepository(database, outbox: outbox);
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

    final pending = await outbox.watchPending().first;
    expect(pending.map((entry) => entry.entityId), contains(project.id));
    expect(pending.map((entry) => entry.entityType.name), contains('project'));
  });

  test('persists immutable project snapshots', () async {
    final now = DateTime.utc(2026, 1, 1);
    await repository.create(
      Project(id: 'p1', title: 'Ideia', createdAt: now, updatedAt: now),
    );

    final snapshot = ProjectSnapshot(
      id: 's1',
      projectId: 'p1',
      projectVersion: 2,
      createdAt: now,
      reason: 'DNA updated',
      projectJson: '{}',
      dnaJson: '{}',
    );

    await repository.createSnapshot(snapshot);

    final rows = await database.select(database.projectSnapshots).get();
    expect(rows, hasLength(1));
    expect(rows.single.id, 's1');
    expect(rows.single.projectVersion, 2);
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
