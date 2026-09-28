import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../application/ai/ai_task_worker.dart';
import '../application/conversation/send_message.dart';
import '../application/document/change_document_status.dart';
import '../application/document/generate_document.dart';
import '../application/export/build_implementation_pack.dart';
import '../application/export/share_implementation_pack.dart';
import '../application/project/create_project.dart';
import '../application/readiness/evaluate_readiness.dart';
import '../application/sync/sync_engine.dart';
import '../domain/ai/ai_provider.dart';
import '../domain/auth/auth_repository.dart';
import '../domain/ai/ai_task_repository.dart';
import '../domain/conversation/conversation_repository.dart';
import '../domain/document/document.dart';
import '../domain/document/document_repository.dart';
import '../domain/project/project.dart';
import '../domain/project/project_repository.dart';
import '../domain/sync/sync_cursor_repository.dart';
import '../domain/sync/sync_outbox_repository.dart';
import '../domain/sync/sync_remote_repository.dart';
import '../infrastructure/ai/drift_ai_task_repository.dart';
import '../infrastructure/ai/echo_provider.dart';
import '../infrastructure/ai/openai_compatible_provider.dart';
import '../infrastructure/conversation/drift_conversation_repository.dart';
import '../infrastructure/document/drift_document_repository.dart';
import '../infrastructure/database/thinknest_database.dart'
    hide Document, Project;
import '../infrastructure/project/drift_project_repository.dart';
import '../infrastructure/sync/drift_sync_applier.dart';
import '../infrastructure/sync/drift_sync_cursor_repository.dart';
import '../infrastructure/sync/drift_sync_outbox_repository.dart';
import '../infrastructure/sync/supabase_sync_remote_repository.dart';
import '../infrastructure/supabase/supabase_auth_repository.dart';
import '../infrastructure/supabase/supabase_config.dart';

final databaseProvider = Provider<ThinkNestDatabase>((ref) {
  final database = ThinkNestDatabase();
  ref.onDispose(database.close);
  return database;
});

final syncOutboxRepositoryProvider = Provider<SyncOutboxRepository>((ref) {
  return DriftSyncOutboxRepository(ref.watch(databaseProvider));
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return DriftProjectRepository(
    ref.watch(databaseProvider),
    outbox: ref.watch(syncOutboxRepositoryProvider),
  );
});

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DriftDocumentRepository(
    ref.watch(databaseProvider),
    outbox: ref.watch(syncOutboxRepositoryProvider),
  );
});

final generateDocumentProvider = Provider<GenerateDocument>((ref) {
  return GenerateDocument(
    ref.watch(projectRepositoryProvider),
    ref.watch(documentRepositoryProvider),
  );
});

final changeDocumentStatusProvider = Provider<ChangeDocumentStatus>((ref) {
  return ChangeDocumentStatus(ref.watch(documentRepositoryProvider));
});

final documentsProvider = StreamProvider.family<List<Document>, String>(
  (ref, projectId) {
    return ref.watch(documentRepositoryProvider).watchByProject(projectId);
  },
);

final buildImplementationPackProvider =
    Provider<BuildImplementationPack>((ref) {
  return BuildImplementationPack(
    ref.watch(projectRepositoryProvider),
    ref.watch(documentRepositoryProvider),
  );
});

final shareImplementationPackProvider =
    Provider<ShareImplementationPack>((ref) {
  return ShareImplementationPack();
});

final evaluateReadinessProvider = Provider<EvaluateReadiness>((ref) {
  return EvaluateReadiness(
    ref.watch(projectRepositoryProvider),
    ref.watch(documentRepositoryProvider),
  );
});

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return DriftConversationRepository(
    ref.watch(databaseProvider),
    outbox: ref.watch(syncOutboxRepositoryProvider),
  );
});

final aiTaskRepositoryProvider = Provider<AiTaskRepository>((ref) {
  return DriftAiTaskRepository(
    ref.watch(databaseProvider),
    outbox: ref.watch(syncOutboxRepositoryProvider),
  );
});

final aiProvider = Provider<AiProvider>((ref) {
  const baseUrl = String.fromEnvironment('THINKNEST_AI_BASE_URL');
  const apiKey = String.fromEnvironment('THINKNEST_AI_API_KEY');
  const model = String.fromEnvironment(
    'THINKNEST_AI_MODEL',
    defaultValue: 'default',
  );

  if (baseUrl.isEmpty || apiKey.isEmpty) {
    return const EchoProvider();
  }

  return OpenAiCompatibleProvider(
    baseUrl: baseUrl,
    apiKey: apiKey,
    defaultModel: model,
  );
});

final aiTaskWorkerProvider = Provider<AiTaskWorker>((ref) {
  final worker = AiTaskWorker(
    ref.watch(aiTaskRepositoryProvider),
    ref.watch(conversationRepositoryProvider),
    ref.watch(projectRepositoryProvider),
    ref.watch(aiProvider),
  );
  ref.onDispose(() {
    worker.dispose();
  });
  return worker;
});

final sendMessageProvider = Provider<SendMessage>((ref) {
  return SendMessage(
    ref.watch(conversationRepositoryProvider),
    ref.watch(aiTaskRepositoryProvider),
    ref.watch(aiTaskWorkerProvider),
  );
});

final projectsProvider = StreamProvider<List<Project>>((ref) {
  return ref.watch(projectRepositoryProvider).watchAll();
});

final createProjectProvider = Provider<CreateProject>((ref) {
  return CreateProject(ref.watch(projectRepositoryProvider));
});

final syncCursorRepositoryProvider = Provider<SyncCursorRepository>((ref) {
  return DriftSyncCursorRepository(ref.watch(databaseProvider));
});

final syncRemoteRepositoryProvider = Provider<SyncRemoteRepository?>((ref) {
  final config = ref.watch(supabaseConfigProvider);
  if (!config.isValid) return null;
  return SupabaseSyncRemoteRepository(Supabase.instance.client);
});

final syncEngineProvider = Provider<SyncEngine?>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  final remote = ref.watch(syncRemoteRepositoryProvider);
  if (auth == null || remote == null) return null;
  return SyncEngine(
    auth,
    ref.watch(syncOutboxRepositoryProvider),
    remote,
    ref.watch(syncCursorRepositoryProvider),
    DriftSyncApplier(
      ref.watch(databaseProvider),
      ref.watch(syncOutboxRepositoryProvider),
    ),
  );
});

final supabaseConfigProvider = Provider<SupabaseConfig>((ref) {
  return SupabaseConfig.fromEnvironment;
});

final authRepositoryProvider = Provider<AuthRepository?>((ref) {
  final config = ref.watch(supabaseConfigProvider);
  if (!config.isValid) return null;
  return SupabaseAuthRepository(
    Supabase.instance.client,
  );
});

/// Thin application boundary around the platform speech recognizer.
///
/// The controller intentionally keeps the plugin out of the UI layer so the
/// capture flow can later be replaced by another local STT implementation.
class SpeechCaptureController {
  SpeechCaptureController() : _speech = SpeechToText();

  final SpeechToText _speech;
  bool _initialized = false;
  bool _isAvailable = false;
  bool _isListening = false;
  void Function(String text, bool isFinal)? _onResult;

  bool get isAvailable => _isAvailable;
  bool get isListening => _isListening;

  Future<bool> initialize() async {
    if (_initialized) return _isAvailable;

    _initialized = true;
    _isAvailable = await _speech.initialize(
      onStatus: (status) {
        _isListening = status == SpeechToText.listeningStatus;
      },
      onError: (_) {
        _isListening = false;
      },
    );
    return _isAvailable;
  }

  Future<bool> start({
    required void Function(String text, bool isFinal) onResult,
  }) async {
    if (!await initialize()) return false;

    _onResult = onResult;
    await _speech.listen(
      listenOptions: const SpeechListenOptions(
        localeId: 'pt_BR',
        partialResults: true,
        onDevice: true,
      ),
      onResult: (result) {
        _onResult?.call(result.recognizedWords, result.finalResult);
      },
    );
    _isListening = _speech.isListening;
    return _isListening;
  }

  Future<void> stop() async {
    await _speech.stop();
    _isListening = false;
    _onResult = null;
  }

  Future<void> cancel() async {
    await _speech.cancel();
    _isListening = false;
    _onResult = null;
  }

  void dispose() {
    _onResult = null;
  }
}

final speechCaptureProvider = Provider<SpeechCaptureController>((ref) {
  final controller = SpeechCaptureController();
  ref.onDispose(controller.dispose);
  return controller;
});
