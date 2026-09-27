import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thinknest/core/application/sync/sync_engine.dart';
import 'package:thinknest/core/domain/auth/auth_repository.dart';
import 'package:thinknest/core/domain/auth/auth_session.dart';
import 'package:thinknest/core/domain/sync/sync_cursor.dart';
import 'package:thinknest/core/domain/sync/sync_cursor_repository.dart';
import 'package:thinknest/core/domain/sync/sync_outbox_entry.dart';
import 'package:thinknest/core/domain/sync/sync_outbox_repository.dart';
import 'package:thinknest/core/domain/sync/sync_remote_repository.dart';
import 'package:thinknest/core/infrastructure/database/thinknest_database.dart'
    hide SyncCursor, SyncOutboxEntry;
import 'package:thinknest/core/infrastructure/sync/drift_sync_applier.dart';
import 'package:thinknest/core/infrastructure/sync/drift_sync_cursor_repository.dart';
import 'package:thinknest/core/infrastructure/sync/drift_sync_outbox_repository.dart';

void main() {
  late ThinkNestDatabase database;
  late SyncOutboxRepository outbox;
  late SyncCursorRepository cursors;
  late DriftSyncApplier applier;

  setUp(() {
    database = ThinkNestDatabase(NativeDatabase.memory());
    outbox = DriftSyncOutboxRepository(database);
    cursors = DriftSyncCursorRepository(database);
    applier = DriftSyncApplier(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('pushes pending entries and removes them after confirmation', () async {
    final remote = FakeSyncRemoteRepository();
    await outbox.enqueue(
      SyncOutboxEntry(
        id: 'o1',
        entityType: SyncEntityType.project,
        entityId: 'p1',
        operation: SyncOperation.upsert,
        payloadJson: '{"id":"p1","title":"Projeto"}',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    );

    final engine = SyncEngine(
      FakeAuthRepository(),
      outbox,
      remote,
      cursors,
      applier,
    );

    final result = await engine.sync();

    expect(result.pushed, 1);
    expect(result.failed, 0);
    expect(await outbox.watchPending().first, isEmpty);
    expect(remote.upserted, hasLength(1));
  });

  test('retries a failed push before succeeding', () async {
    final remote = FakeSyncRemoteRepository(failuresBeforeSuccess: 2);
    await outbox.enqueue(
      SyncOutboxEntry(
        id: 'o1',
        entityType: SyncEntityType.project,
        entityId: 'p1',
        operation: SyncOperation.upsert,
        payloadJson: '{"id":"p1","title":"Projeto"}',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    );

    final engine = SyncEngine(
      FakeAuthRepository(),
      outbox,
      remote,
      cursors,
      applier,
    );

    final result = await engine.sync();
    final entry = await outbox.watchPending().first;

    expect(result.pushed, 1);
    expect(result.failed, 0);
    expect(remote.attempts, 3);
    expect(entry, isEmpty);
  });

  test(
      'pulls remote project and advances its cursor without creating outbox work',
      () async {
    final remote = FakeSyncRemoteRepository(
      remoteRows: {
        SyncEntityType.project: [
          {
            'id': 'p1',
            'user_id': 'u1',
            'title': 'Projeto remoto',
            'category': null,
            'maturity_level': 'CAPTURED',
            'is_pinned': false,
            'is_archived': false,
            'created_at': '2026-01-01T00:00:00Z',
            'updated_at': '2026-01-02T00:00:00Z',
          },
        ],
      },
    );

    final engine = SyncEngine(
      FakeAuthRepository(),
      outbox,
      remote,
      cursors,
      applier,
    );

    final result = await engine.sync();
    final project = await database.findProject('p1');
    final cursor = await cursors.get(SyncEntityType.project.name);

    expect(result.pulled, 1);
    expect(project.title, 'Projeto remoto');
    expect(cursor?.lastEntityId, 'p1');
    expect(await outbox.watchPending().first, isEmpty);
  });
}

class FakeAuthRepository implements AuthRepository {
  static final _session = AuthSession(
    userId: 'u1',
    accessToken: 'token',
    expiresAt: DateTime.utc(2099, 1, 1),
  );

  @override
  AuthSession? get currentSession => _session;

  @override
  Stream<AuthSession?> watchSession() => Stream.value(_session);

  @override
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async =>
      _session;

  @override
  Future<void> signOut() async {}
}

class FakeSyncRemoteRepository implements SyncRemoteRepository {
  FakeSyncRemoteRepository({
    this.failuresBeforeSuccess = 0,
    Map<SyncEntityType, List<Map<String, dynamic>>>? remoteRows,
  }) : remoteRows = remoteRows ?? {};

  int failuresBeforeSuccess;
  int attempts = 0;
  final Map<SyncEntityType, List<Map<String, dynamic>>> remoteRows;
  final List<SyncOutboxEntry> upserted = [];

  @override
  Future<void> upsert(
    SyncOutboxEntry entry, {
    required String userId,
  }) async {
    attempts++;
    if (attempts <= failuresBeforeSuccess) {
      throw StateError('temporary failure');
    }
    upserted.add(entry);
  }

  @override
  Future<void> delete(
    SyncOutboxEntry entry, {
    required String userId,
  }) async {}

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    SyncEntityType entityType,
    SyncCursor? cursor,
  ) async {
    final rows = remoteRows[entityType] ?? const [];
    if (cursor == null) return rows;
    return rows.where((row) {
      final timestamp = DateTime.parse(
        row[_timestampColumn(entityType)] as String,
      ).toUtc();
      final id = (row['id'] ?? row['project_id']) as String;
      final last = cursor.lastTimestamp;
      if (last == null) return true;
      if (timestamp.isAfter(last)) return true;
      if (!timestamp.isAtSameMomentAs(last)) return false;
      return cursor.lastEntityId == null ||
          id.compareTo(cursor.lastEntityId!) > 0;
    }).toList();
  }

  String _timestampColumn(SyncEntityType type) => switch (type) {
        SyncEntityType.project => 'updated_at',
        SyncEntityType.projectDna => 'updated_at',
        SyncEntityType.projectSnapshot => 'created_at',
        SyncEntityType.document => 'updated_at',
        SyncEntityType.conversationMessage => 'updated_at',
        SyncEntityType.aiTask => 'updated_at',
      };
}
