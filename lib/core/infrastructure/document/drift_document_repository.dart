import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/document/document.dart';
import '../../domain/document/document_repository.dart';
import '../../domain/sync/sync_outbox_entry.dart';
import '../../domain/sync/sync_outbox_repository.dart';
import '../database/thinknest_database.dart' as db;

class DriftDocumentRepository implements DocumentRepository {
  DriftDocumentRepository(this._database, {SyncOutboxRepository? outbox})
      : _outbox = outbox;

  final db.ThinkNestDatabase _database;
  final SyncOutboxRepository? _outbox;
  static const _uuid = Uuid();

  @override
  Future<void> create(Document document) async {
    await _database.transaction(() async {
      await _database.insertDocument(_toCompanion(document));
      await _record(document);
    });
  }

  @override
  Future<Document?> getById(String id) async {
    final row = await (_database.select(_database.documents)
          ..where((item) => item.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Stream<List<Document>> watchByProject(String projectId) =>
      (_database.select(_database.documents)
            ..where((item) => item.projectId.equals(projectId))
            ..orderBy([
              (item) => OrderingTerm.desc(item.createdAt),
            ]))
          .watch()
          .map((rows) => rows.map(_fromRow).toList());

  @override
  Future<List<Document>> getVersions(
    String projectId,
    DocumentType type,
  ) async {
    final rows = await (_database.select(_database.documents)
          ..where(
            (item) =>
                item.projectId.equals(projectId) &
                item.type.equals(type.name.toUpperCase()),
          )
          ..orderBy([
            (item) => OrderingTerm.desc(item.version),
          ]))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> updateStatus(
    String id,
    DocumentStatus status,
    DateTime updatedAt,
  ) async {
    final document = await getById(id);
    if (document == null) return;

    final updated = Document(
      id: document.id,
      projectId: document.projectId,
      type: document.type,
      version: document.version,
      status: status,
      title: document.title,
      content: document.content,
      dnaVersion: document.dnaVersion,
      createdAt: document.createdAt,
      updatedAt: updatedAt,
    );
    await _database.transaction(() async {
      await (_database.update(_database.documents)
            ..where((item) => item.id.equals(id)))
          .write(
        db.DocumentsCompanion(
          status: Value(status.name.toUpperCase()),
          updatedAt: Value(updatedAt),
        ),
      );
      await _record(updated);
    });
  }

  db.DocumentsCompanion _toCompanion(Document document) =>
      db.DocumentsCompanion.insert(
        id: document.id,
        projectId: document.projectId,
        type: document.type.name.toUpperCase(),
        version: document.version,
        status: document.status.name.toUpperCase(),
        title: document.title,
        content: document.content,
        dnaVersion: document.dnaVersion,
        createdAt: document.createdAt,
        updatedAt: document.updatedAt,
      );

  Future<void> _record(Document document) async {
    await _outbox?.enqueue(
      SyncOutboxEntry(
        id: _uuid.v4(),
        entityType: SyncEntityType.document,
        entityId: document.id,
        operation: SyncOperation.upsert,
        payloadJson: jsonEncode({
          'id': document.id,
          'project_id': document.projectId,
          'type': document.type.name.toUpperCase(),
          'version': document.version,
          'status': document.status.name.toUpperCase(),
          'title': document.title,
          'content': document.content,
          'dna_version': document.dnaVersion,
          'created_at': document.createdAt.toIso8601String(),
          'updated_at': document.updatedAt.toIso8601String(),
        }),
        createdAt: document.updatedAt,
      ),
    );
  }

  Document _fromRow(db.Document row) => Document(
        id: row.id,
        projectId: row.projectId,
        type: DocumentType.values.firstWhere(
          (value) => value.name.toUpperCase() == row.type,
        ),
        version: row.version,
        status: DocumentStatus.values.firstWhere(
          (value) => value.name.toUpperCase() == row.status,
        ),
        title: row.title,
        content: row.content,
        dnaVersion: row.dnaVersion,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}
