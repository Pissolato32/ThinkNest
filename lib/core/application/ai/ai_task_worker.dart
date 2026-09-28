import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/ai/ai_provider.dart';
import '../../domain/ai/ai_task.dart';
import '../../domain/ai/ai_task_repository.dart';
import '../../domain/conversation/conversation_message.dart';
import '../../domain/conversation/conversation_repository.dart';
import '../../domain/project/project_repository.dart';

class AiTaskWorker {
  AiTaskWorker(
    this._taskRepository,
    this._conversationRepository,
    this._projectRepository,
    this._provider, {
    Connectivity? connectivity,
    this.maxAttempts = 3,
  }) : _connectivity = connectivity ?? Connectivity();

  final AiTaskRepository _taskRepository;
  final ConversationRepository _conversationRepository;
  final ProjectRepository _projectRepository;
  final AiProvider _provider;
  final Connectivity _connectivity;
  final int maxAttempts;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _running = false;

  Future<void> start() async {
    await resume();
    _subscription ??= _connectivity.onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        unawaited(drainPending());
      }
    });
  }

  Future<void> resume() async {
    final results = await _connectivity.checkConnectivity();
    if (!results.contains(ConnectivityResult.none)) {
      await drainPending();
    }
  }

  Future<void> drainPending() async {
    if (_running) return;
    _running = true;
    try {
      final tasks = await _taskRepository.listPending();
      for (final task in tasks) {
        try {
          await run(task);
        } catch (_) {
          // Keep the worker alive so later connectivity events can retry.
        }
      }
    } finally {
      _running = false;
    }
  }

  Future<ConversationMessage?> run(AiTask task) async {
    if (task.attempts >= maxAttempts) {
      await _taskRepository.markFailed(
        task.id,
        error: 'Número máximo de tentativas atingido.',
      );
      return null;
    }

    final payloadJson = await _taskRepository.payloadFor(task.id);
    if (payloadJson == null) {
      await _taskRepository.markFailed(
        task.id,
        error: 'Payload da AI Task não encontrado.',
      );
      return null;
    }

    Map<String, dynamic> payload;
    try {
      payload = jsonDecode(payloadJson) as Map<String, dynamic>;
    } catch (_) {
      await _taskRepository.markFailed(
        task.id,
        error: 'Payload da AI Task inválido.',
      );
      return null;
    }

    final projectId = payload['project_id'] as String?;
    final messageId = payload['message_id'] as String?;
    if (projectId == null ||
        messageId == null ||
        projectId != task.projectId) {
      await _taskRepository.markFailed(
        task.id,
        error: 'Payload da AI Task inválido ou projeto inconsistente.',
      );
      return null;
    }

    await _taskRepository.markRunning(task.id);

    try {
      final dna = await _projectRepository.getDna(projectId);
      if (dna == null) {
        throw StateError('Project DNA não encontrado.');
      }

      final messages =
          await _conversationRepository.watchMessages(projectId).first;
      final sourceMessage =
          messages.where((message) => message.id == messageId);
      if (sourceMessage.isEmpty) {
        throw StateError('Mensagem de origem da AI Task não encontrada.');
      }

      final request = AiRequest(
        projectId: projectId,
        dna: dna,
        messages: messages,
      );
      final response = await _provider.complete(request);

      final assistantId = 'ai-task-${task.id}';
      final existing = messages.where((message) => message.id == assistantId);
      final assistantMessage = existing.isNotEmpty
          ? existing.first
          : ConversationMessage(
              id: assistantId,
              projectId: projectId,
              role: ConversationMessageRole.assistant,
              content: response.content,
              createdAt: DateTime.now().toUtc(),
              providerId: response.providerId,
              model: response.model,
            );

      if (existing.isEmpty) {
        await _conversationRepository.addMessage(assistantMessage);
      }
      await _taskRepository.markCompleted(task.id);
      return assistantMessage;
    } catch (error) {
      final nextAttempt = task.attempts + 1;
      if (nextAttempt >= maxAttempts) {
        await _taskRepository.markFailed(
          task.id,
          error: error.toString(),
        );
      } else {
        await _taskRepository.markPending(
          task.id,
          error: error.toString(),
        );
      }
      rethrow;
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
