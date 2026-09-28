import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thinknest/core/domain/project/project.dart';
import 'package:thinknest/core/domain/project/project_dna.dart';
import 'package:thinknest/core/domain/project/project_repository.dart';
import 'package:thinknest/core/domain/project/project_snapshot.dart';
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
      projects.where((item) => item.id == id).isEmpty
          ? null
          : projects.firstWhere((item) => item.id == id);

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
  Future<void> createSnapshot(ProjectSnapshot snapshot) async {}

  @override
  Future<void> saveDna(ProjectDna dna) async {}
}

class _FakeSpeechCaptureController extends SpeechCaptureController {
  bool started = false;
  void Function(String text, bool isFinal)? onResult;

  @override
  Future<bool> start({
    required void Function(String text, bool isFinal) onResult,
  }) async {
    this.onResult = onResult;
    started = true;
    return true;
  }

  @override
  Future<void> stop() async {
    started = false;
  }
}

void main() {
  testWidgets('captures an idea and shows it in the project list',
      (tester) async {
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

  testWidgets('captures an idea from voice recognition', (tester) async {
    final repository = _WidgetRepository();
    final speech = _FakeSpeechCaptureController();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectRepositoryProvider.overrideWithValue(repository),
          speechCaptureProvider.overrideWithValue(speech),
        ],
        child: const ThinkNestApp(),
      ),
    );

    await tester.tap(find.byTooltip('Capturar por voz'));
    await tester.pump();
    expect(speech.started, isTrue);

    speech.onResult?.call('Projeto capturado por voz', true);
    await tester.pumpAndSettle();

    expect(find.text('Projeto capturado por voz'), findsOneWidget);
    expect(repository.projects.single.title, 'Projeto capturado por voz');
  });
}
