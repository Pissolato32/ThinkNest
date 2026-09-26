import 'package:drift/drift.dart';

import '../../domain/document/document.dart';
import '../../domain/document/document_repository.dart';
import '../database/thinknest_database.dart' as db;

class DriftDocumentRepository implements DocumentRepository {
  DriftDocumentRepository(this._database);

  final db.ThinkNestDatabase _database;

  @override
  Future<void> create(Document document) => _database.insertDocument(
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
        ),
      );

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
    await (_database.update(_database.documents)
          ..where((item) => item.id.equals(id)))
        .write(
      db.DocumentsCompanion(
        status: Value(status.name.toUpperCase()),
        updatedAt: Value(updatedAt),
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
