import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thinknest/core/domain/project/project.dart';
import 'package:thinknest/core/domain/project/project_dna.dart';
import 'package:thinknest/core/domain/project/project_repository.dart';
import 'package:thinknest/core/providers/project_providers.dart';
import 'package:thinknest/main.dart';

class _WidgetRepository implements ProjectRepository {
  final List<Project> projects = [];

  @override
  Future<void> create(Project project, {ProjectDna? dna}) async {
    projects.add(project);
  }

  @override
  Future<Project?> getById(String id) async =>
      projects.where((item) => item.id == id).firstOrNull;

  @override
  Stream<List<Project>> watchAll() async* {
    yield projects;
  }

  @override
  Future<void> update(Project project) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<ProjectDna?> getDna(String projectId) async => null;

  @override
  Future<void> saveDna(ProjectDna dna) async {}
}

void main() {
  testWidgets('captures an idea and shows it in the project list', (tester) async {
    final repository = _WidgetRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectRepositoryProvider.overrideWithValue(repository),
        ],
        child: const ThinkNestApp(),
      ),
    );

    expect(find.text('Capture uma ideia.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Meu novo projeto');
    await tester.tap(find.text('Capturar ideia'));
    await tester.pumpAndSettle();

    expect(find.text('Meu novo projeto'), findsOneWidget);
  });
}
