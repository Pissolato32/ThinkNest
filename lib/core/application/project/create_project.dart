import 'package:uuid/uuid.dart';

import '../../domain/project/project.dart';
import '../../domain/project/project_dna.dart';
import '../../domain/project/project_repository.dart';

class CreateProject {
  CreateProject(this._repository, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final ProjectRepository _repository;
  final Uuid _uuid;

  Future<Project> call({
    required String title,
    String? category,
  }) async {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'A ideia não pode estar vazia.');
    }

    final now = DateTime.now().toUtc();
    final project = Project(
      id: _uuid.v4(),
      title: normalizedTitle,
      category: category?.trim().isEmpty == true ? null : category?.trim(),
      createdAt: now,
      updatedAt: now,
    );
    final dna = ProjectDna(
      projectId: project.id,
      version: 1,
      updatedAt: now,
      identity: {'title': normalizedTitle},
    );

    await _repository.create(project, dna: dna);
    return project;
  }
}
