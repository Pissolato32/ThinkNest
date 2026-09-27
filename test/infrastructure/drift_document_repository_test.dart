import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thinknest/core/domain/document/document.dart';
import 'package:thinknest/core/infrastructure/database/thinknest_database.dart'
    hide Document;
import 'package:thinknest/core/domain/sync/sync_outbox_entry.dart';
import 'package:thinknest/core/infrastructure/document/drift_document_repository.dart';
import 'package:thinknest/core/infrastructure/sync/drift_sync_outbox_repository.dart';

void main() {
  late ThinkNestDatabase database;
  late DriftDocumentRepository repository;
  late DriftSyncOutboxRepository outbox;

  setUp(() {
    database = ThinkNestDatabase(NativeDatabase.memory());
    outbox = DriftSyncOutboxRepository(database);
    repository = DriftDocumentRepository(database, outbox: outbox);
  });

  tearDown(() async {
    await database.close();
  });

  test('persists document content and DNA version', () async {
    final now = DateTime.utc(2026, 1, 1);
    await database.into(database.projects).insert(
          ProjectsCompanion.insert(
            id: 'p1',
            title: 'Projeto',
            createdAt: now,
            updatedAt: now,
          ),
        );

    final document = Document(
      id: 'd1',
      projectId: 'p1',
      type: DocumentType.prd,
      version: 1,
      status: DocumentStatus.generated,
      title: 'PRD',
      content: '# PRD',
      dnaVersion: 7,
      createdAt: now,
      updatedAt: now,
    );

    await repository.create(document);
    final restored = await repository.getById('d1');

    expect(restored?.content, '# PRD');
    expect(restored?.dnaVersion, 7);
    expect(restored?.status, DocumentStatus.generated);
  });

  test('keeps document versions immutable by creating a new row', () async {
    final now = DateTime.utc(2026, 1, 1);
    await database.into(database.projects).insert(
          ProjectsCompanion.insert(
            id: 'p1',
            title: 'Projeto',
            createdAt: now,
            updatedAt: now,
          ),
        );

    final first = Document(
      id: 'd1',
      projectId: 'p1',
      type: DocumentType.prd,
      version: 1,
      status: DocumentStatus.generated,
      title: 'PRD',
      content: 'v1',
      dnaVersion: 1,
      createdAt: now,
      updatedAt: now,
    );
    final second = Document(
      id: 'd2',
      projectId: 'p1',
      type: DocumentType.prd,
      version: 2,
      status: DocumentStatus.generated,
      title: 'PRD',
      content: 'v2',
      dnaVersion: 2,
      createdAt: now.add(const Duration(minutes: 1)),
      updatedAt: now.add(const Duration(minutes: 1)),
    );

    await repository.create(first);
    await repository.create(second);

    final versions = await repository.getVersions('p1', DocumentType.prd);
    expect(versions.map((item) => item.version), [2, 1]);
    expect(versions.first.content, 'v2');
    expect(versions.last.content, 'v1');
  });
}


test('records document mutations in the sync outbox', () async {
  final now = DateTime.utc(2026, 1, 1);
  await database.into(database.projects).insert(
        ProjectsCompanion.insert(
          id: 'p1',
          title: 'Projeto',
          createdAt: now,
          updatedAt: now,
        ),
      );

  final document = Document(
    id: 'd1',
    projectId: 'p1',
    type: DocumentType.prd,
    version: 1,
    status: DocumentStatus.generated,
    title: 'PRD',
    content: '# PRD',
    dnaVersion: 1,
    createdAt: now,
    updatedAt: now,
  );

  await repository.create(document);
  final entries = await outbox.watchPending().first;

  expect(entries, hasLength(1));
  expect(entries.single.entityType, SyncEntityType.document);
  expect(entries.single.entityId, 'd1');
  expect(entries.single.operation, SyncOperation.upsert);
});
