import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'thinknest_database.g.dart';

class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get category => text().nullable()();
  TextColumn get maturityLevel =>
      text().withDefault(const Constant('CAPTURED'))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ProjectDnaRows extends Table {
  TextColumn get projectId =>
      text().references(Projects, #id, onDelete: KeyAction.cascade)();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get dnaJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {projectId};
}

class ProjectSnapshots extends Table {
  TextColumn get id => text()();
  TextColumn get projectId =>
      text().references(Projects, #id, onDelete: KeyAction.cascade)();
  IntColumn get projectVersion => integer()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get reason => text()();
  TextColumn get projectJson => text()();
  TextColumn get dnaJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Projects, ProjectDnaRows, ProjectSnapshots])
class ThinkNestDatabase extends _$ThinkNestDatabase {
  ThinkNestDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'thinknest'));

  @override
  int get schemaVersion => 1;

  Future<Project> findProject(String id) =>
      (select(projects)..where((row) => row.id.equals(id))).getSingle();

  Stream<List<Project>> watchProjects() => (select(projects)
        ..where((row) => row.isArchived.equals(false))
        ..orderBy([
          (row) => OrderingTerm.desc(row.updatedAt),
        ]))
      .watch();

  Future<void> upsertProject(ProjectsCompanion entry) =>
      into(projects).insertOnConflictUpdate(entry);

  Future<void> upsertDna(ProjectDnaRowsCompanion entry) =>
      into(projectDnaRows).insertOnConflictUpdate(entry);
}
