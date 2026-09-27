import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/sync/sync_cursor.dart';
import '../../domain/sync/sync_outbox_entry.dart';
import '../../domain/sync/sync_remote_repository.dart';

class SupabaseSyncRemoteRepository implements SyncRemoteRepository {
  SupabaseSyncRemoteRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> upsert(
    SyncOutboxEntry entry, {
    required String userId,
  }) async {
    final payload = jsonDecode(entry.payloadJson) as Map<String, dynamic>;
    final normalized = _normalizePayload(entry.entityType, payload);
    if (entry.entityType == SyncEntityType.project) {
      normalized['user_id'] = userId;
    }
    await _client.from(_table(entry.entityType)).upsert(normalized);
  }

  @override
  Future<void> delete(
    SyncOutboxEntry entry, {
    required String userId,
  }) async {
    if (entry.entityType != SyncEntityType.project) {
      throw StateError(
        'Delete remoto não suportado para a entidade ${entry.entityType.name}.',
      );
    }
    await _client
        .from(_table(entry.entityType))
        .delete()
        .eq('id', entry.entityId);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    SyncEntityType entityType,
    SyncCursor? cursor,
  ) async {
    final table = _table(entityType);
    final timestampColumn = _timestampColumn(entityType);
    var query = _client.from(table).select();
    if (cursor?.lastTimestamp != null) {
      query = query.gte(
        timestampColumn,
        cursor!.lastTimestamp!.toIso8601String(),
      );
    }

    final rows = await query
        .order(timestampColumn, ascending: true)
        .order('id', ascending: true)
        .limit(500);

    return rows
        .map((row) => Map<String, dynamic>.from(row))
        .where((row) => _isAfterCursor(row, cursor, timestampColumn))
        .toList();
  }

  Map<String, dynamic> _normalizePayload(
    SyncEntityType entityType,
    Map<String, dynamic> payload,
  ) {
    final normalized = Map<String, dynamic>.from(payload);
    if (entityType == SyncEntityType.projectDna) {
      normalized['dna_json'] = jsonDecode(normalized['dna_json'] as String);
    }
    if (entityType == SyncEntityType.aiTask) {
      normalized['payload_json'] =
          jsonDecode(normalized['payload_json'] as String);
    }
    return normalized;
  }

  bool _isAfterCursor(
    Map<String, dynamic> row,
    SyncCursor? cursor,
    String timestampColumn,
  ) {
    if (cursor?.lastTimestamp == null) return true;
    final timestamp = DateTime.parse(row[timestampColumn] as String).toUtc();
    final lastTimestamp = cursor!.lastTimestamp!.toUtc();
    if (timestamp.isAfter(lastTimestamp)) return true;
    if (!timestamp.isAtSameMomentAs(lastTimestamp)) return false;
    final id = row['id'] ?? row['project_id'];
    return id is String &&
        (cursor.lastEntityId == null || id.compareTo(cursor.lastEntityId!) > 0);
  }

  String _table(SyncEntityType type) => switch (type) {
        SyncEntityType.project => 'projects',
        SyncEntityType.projectDna => 'project_dna',
        SyncEntityType.projectSnapshot => 'project_snapshots',
        SyncEntityType.document => 'documents',
        SyncEntityType.conversationMessage => 'conversation_messages',
        SyncEntityType.aiTask => 'ai_tasks',
      };

  String _timestampColumn(SyncEntityType type) => switch (type) {
        SyncEntityType.project => 'updated_at',
        SyncEntityType.projectDna => 'updated_at',
        SyncEntityType.projectSnapshot => 'created_at',
        SyncEntityType.document => 'updated_at',
        SyncEntityType.conversationMessage => 'updated_at',
        SyncEntityType.aiTask => 'updated_at',
      };
}
