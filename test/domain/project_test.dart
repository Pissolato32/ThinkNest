import 'package:flutter_test/flutter_test.dart';
import 'package:thinknest/core/domain/project/project.dart';
import 'package:thinknest/core/domain/project/project_dna.dart';

void main() {
  group('Project', () {
    test('defaults to captured maturity', () {
      final now = DateTime.utc(2026, 1, 1);
      final project = Project(id: 'p1', title: 'Idea', createdAt: now, updatedAt: now);

      expect(project.maturity, ProjectMaturity.captured);
      expect(project.isPinned, isFalse);
      expect(project.isArchived, isFalse);
    });

    test('copyWith preserves identity and creation time', () {
      final created = DateTime.utc(2026, 1, 1);
      final project = Project(id: 'p1', title: 'Idea', createdAt: created, updatedAt: created);
      final updated = project.copyWith(title: 'Updated');

      expect(updated.id, 'p1');
      expect(updated.createdAt, created);
      expect(updated.title, 'Updated');
      expect(updated.updatedAt, isNot(created));
    });
  });

  group('ProjectDna', () {
    test('serializes the canonical top-level sections', () {
      final dna = ProjectDna(
        projectId: 'p1',
        version: 1,
        updatedAt: DateTime.utc(2026, 1, 1),
        identity: {'title': 'Idea'},
      );

      final json = dna.toJson();

      expect(json['project_id'], 'p1');
      expect(json['version'], 1);
      expect(json['identity'], {'title': 'Idea'});
      expect(json.containsKey('key_decisions'), isTrue);
      expect(json.containsKey('open_uncertainties'), isTrue);
    });
  });
}
