import 'dart:async';

import '../../domain/auth/auth_repository.dart';
import '../../domain/sync/sync_cursor.dart';
import '../../domain/sync/sync_cursor_repository.dart';
import '../../domain/sync/sync_outbox_entry.dart';
import '../../domain/sync/sync_outbox_repository.dart';
import '../../domain/sync/sync_remote_repository.dart';
import '../../domain/sync/sync_result.dart';
import '../../infrastructure/sync/drift_sync_applier.dart';

class SyncEngine {
  SyncEngine(
    this._authRepository,
    this._outbox,
    this._remote,
    this._cursorRepository,
    this._applier,
  );

  final AuthRepository _authRepository;
  final SyncOutboxRepository _outbox;
  final SyncRemoteRepository _remote;
  final SyncCursorRepository _cursorRepository;
  final DriftSyncApplier _applier;

  Future<SyncResult> sync() async {
    final session = _authRepository.currentSession;
    if (session == null || session.isExpired) {
      throw StateError(
          'Uma sessão autenticada válida é necessária para sincronizar.');
    }

    final pushResult = await _push(session.userId);
    final pulled = await _pull();

    return SyncResult(
      pushed: pushResult.pushed,
      pulled: pulled,
      failed: pushResult.failed,
    );
  }

  Future<_PushResult> _push(String userId) async {
    final pending = await _outbox.watchPending().first;
    var pushed = 0;
    var failed = 0;

    for (final entry in pending) {
      var completed = false;
      Object? lastError;
      for (var attempt = 0; attempt < 3; attempt++) {
        try {
          if (entry.operation == SyncOperation.upsert) {
            await _remote.upsert(entry, userId: userId);
          } else {
            await _remote.delete(entry, userId: userId);
          }
          await _outbox.remove(entry.id);
          pushed++;
          completed = true;
          break;
        } catch (error) {
          lastError = error;
          await _outbox.markAttempt(
            entry.id,
            error: error.toString(),
          );
          if (attempt < 2) {
            await Future<void>.delayed(
              Duration(milliseconds: 250 * (1 << attempt)),
            );
          }
        }
      }
      if (!completed) {
        failed++;
        if (lastError != null) break;
      }
    }

    return _PushResult(pushed: pushed, failed: failed);
  }

  Future<int> _pull() async {
    var total = 0;
    for (final entityType in SyncEntityType.values) {
      var cursor = await _cursorRepository.get(entityType.name);
      while (true) {
        final rows = await _remote.fetchSince(entityType, cursor);
        if (rows.isEmpty) break;

        for (final row in rows) {
          await _applier.apply(entityType, row);
          cursor = _applier.cursorFor(entityType, row);
          total++;
        }
        await _cursorRepository.save(cursor!);

        if (rows.length < 500) break;
      }
    }
    return total;
  }
}

class _PushResult {
  const _PushResult({
    required this.pushed,
    required this.failed,
  });

  final int pushed;
  final int failed;
}
