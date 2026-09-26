import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/project/create_project.dart';
import '../domain/project/project.dart';
import '../domain/project/project_repository.dart';
import '../infrastructure/database/thinknest_database.dart';
import '../infrastructure/project/drift_project_repository.dart';

final databaseProvider = Provider<ThinkNestDatabase>((ref) {
  final database = ThinkNestDatabase();
  ref.onDispose(database.close);
  return database;
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return DriftProjectRepository(ref.watch(databaseProvider));
});

final projectsProvider = StreamProvider<List<Project>>((ref) {
  return ref.watch(projectRepositoryProvider).watchAll();
});

final createProjectProvider = Provider<CreateProject>((ref) {
  return CreateProject(ref.watch(projectRepositoryProvider));
});
