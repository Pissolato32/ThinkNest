import 'dart:convert';

import '../../domain/project/project.dart';
import '../../domain/project/project_dna.dart';
import '../../domain/project/project_repository.dart';
import '../database/thinknest_database.dart';

class DriftProjectRepository implements ProjectRepository {
  DriftProjectRepository(this._database);

  final ThinkNestDatabase _database;

  @override
  Future<Project?> getById(String id) async {
    try {
      final row = await _database.findProject(id);
      return _fromRow(row);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<List<Project>> watchAll() =>
      _database.watchProjects().map((rows) => rows.map(_fromRow).toList());

  @override
  Future<void> create(Project project, {ProjectDna? dna}) async {
    await _database.transaction(() async {
      await _database.upsertProject(
        ProjectsCompanion.insert(
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
  Future<void> update(Project project) => _database.upsertProject(
        ProjectsCompanion.insert(
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
      (_database.delete(_database.projects)..where((row) => row.id.equals(id))).go();

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
      updatedAt: DateTime.parse(json['updated_at'] as String),
      identity: Map<String, dynamic>.from(json['identity'] as Map),
      corePillars: Map<String, dynamic>.from(json['core_pillars'] as Map),
      technicalConstraints:
          Map<String, dynamic>.from(json['technical_constraints'] as Map),
      keyDecisions: Map<String, dynamic>.from(json['key_decisions'] as Map),
      openUncertainties:
          Map<String, dynamic>.from(json['open_uncertainties'] as Map),
      specialistState:
          Map<String, dynamic>.from(json['specialist_state'] as Map),
    );
  }

  @override
  Future<void> saveDna(ProjectDna dna) => _database.upsertDna(
        ProjectDnaRowsCompanion.insert(
          projectId: dna.projectId,
          version: Value(dna.version),
          dnaJson: jsonEncode(dna.toJson()),
          updatedAt: dna.updatedAt,
        ),
      );

  Project _fromRow(Project row) => Project(
        id: row.id,
        title: row.title,
        category: row.category,
        maturity: ProjectMaturity.values.firstWhere(
          (value) => value.name.toUpperCase() == row.maturityLevel,
          orElse: () => ProjectMaturity.captured,
        ),
        isPinned: row.isPinned,
        isArchived: row.isArchived,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}
