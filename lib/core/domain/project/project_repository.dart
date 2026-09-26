import 'project.dart';
import 'project_dna.dart';
import 'project_snapshot.dart';

abstract interface class ProjectRepository {
  Future<Project?> getById(String id);

  Stream<List<Project>> watchAll();

  Future<void> create(Project project, {ProjectDna? dna});

  Future<void> update(Project project);

  Future<void> delete(String id);

  Future<ProjectDna?> getDna(String projectId);

  Future<void> saveDna(ProjectDna dna);

  Future<void> createSnapshot(ProjectSnapshot snapshot);
}
