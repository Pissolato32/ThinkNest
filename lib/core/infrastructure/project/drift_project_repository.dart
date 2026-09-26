import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/project/project.dart' as domain;
import '../../domain/project/project_dna.dart';
import '../../domain/project/project_repository.dart';
import '../../domain/project/project_snapshot.dart';
import '../database/thinknest_database.dart' as db;

class DriftProjectRepository implements ProjectRepository {
  DriftProjectRepository(this._database);

  final db.ThinkNestDatabase _database;

  @override
  Future<domain.Project?> getById(String id) async {
    try {
      final row = await _database.findProject(id);
      return _fromRow(row);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<List<domain.Project>> watchAll() =>
      _database.watchProjects().map((rows) => rows.map(_fromRow).toList());

  @override
  Future<void> create(domain.Project project, {ProjectDna? dna}) async {
    await _database.transaction(() async {
      await _database.upsertProject(
        db.ProjectsCompanion.insert(
          id: project.id,
          title: project.title,
          category: project.category == null
              ? const Value.absent()
              : Value(project.category),
          maturityLevel: Value(project.maturity.name.toUpperCase()),
          isPinned: Value(project.isPinned),
          isArchived: Value(project.isArchived),
          createdAt: project.createdAt,
          updatedAt: project.updatedAt,
        ),
      );

      if (dna != null) {
        await saveDna(dna);
      }
    });
  }

  @override
  Future<void> update(domain.Project project) => _database.upsertProject(
        db.ProjectsCompanion.insert(
          id: project.id,
          title: project.title,
          category: project.category == null
              ? const Value.absent()
              : Value(project.category),
          maturityLevel: Value(project.maturity.name.toUpperCase()),
          isPinned: Value(project.isPinned),
          isArchived: Value(project.isArchived),
          createdAt: project.createdAt,
          updatedAt: project.updatedAt,
        ),
      );

  @override
  Future<void> delete(String id) =>
      (_database.delete(_database.projects)..where((row) => row.id.equals(id)))
          .go();

  @override
  Future<ProjectDna?> getDna(String projectId) async {
    final row = await (_database.select(_database.projectDnaRows)
          ..where((item) => item.projectId.equals(projectId)))
        .getSingleOrNull();
    if (row == null) return null;

    final json = jsonDecode(row.dnaJson) as Map<String, dynamic>;
    return ProjectDna(
      projectId: json['project_id'] as String,
      version: json['version'] as int,
      updatedAt: DateTime.parse(json['last_updated'] as String),
      identity: Map<String, Object?>.from(json['identity'] as Map),
      corePillars: Map<String, Object?>.from(json['core_pillars'] as Map),
      technicalConstraints:
          Map<String, Object?>.from(json['technical_constraints'] as Map),
      keyDecisions: (json['key_decisions'] as List)
          .map((item) => Map<String, Object?>.from(item as Map))
          .toList(),
      openUncertainties: List<String>.from(json['open_uncertainties'] as List),
      knownRisks: List<String>.from(json['known_risks'] as List? ?? const []),
      specialistState:
          Map<String, Object?>.from(json['specialist_state'] as Map),
    );
  }

  @override
  Future<void> saveDna(ProjectDna dna) => _database.upsertDna(
        db.ProjectDnaRowsCompanion.insert(
          projectId: dna.projectId,
          version: Value(dna.version),
          dnaJson: jsonEncode(dna.toJson()),
          updatedAt: dna.updatedAt,
        ),
      );

  @override
  Future<void> createSnapshot(ProjectSnapshot snapshot) =>
      _database.insertSnapshot(
        db.ProjectSnapshotsCompanion.insert(
          id: snapshot.id,
          projectId: snapshot.projectId,
          projectVersion: snapshot.projectVersion,
          createdAt: snapshot.createdAt,
          reason: snapshot.reason,
          projectJson: snapshot.projectJson,
          dnaJson: snapshot.dnaJson,
        ),
      );

  domain.Project _fromRow(db.Project row) => domain.Project(
        id: row.id,
        title: row.title,
        category: row.category,
        maturity: domain.ProjectMaturity.values.firstWhere(
          (value) => value.name.toUpperCase() == row.maturityLevel,
          orElse: () => domain.ProjectMaturity.captured,
        ),
        isPinned: row.isPinned,
        isArchived: row.isArchived,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}
