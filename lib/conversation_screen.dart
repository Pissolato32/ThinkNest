import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/domain/conversation/conversation_message.dart';
import 'core/providers/project_providers.dart';
import 'documents_screen.dart';
import 'readiness_screen.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({
    required this.projectId,
    required this.title,
    super.key,
  });

  final String projectId;
  final String title;

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _controller = TextEditingController();
  bool _sending = false;
  bool _listening = false;
  bool _voiceAvailable = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initializeVoice());
  }

  Future<void> _initializeVoice() async {
    try {
      final available = await ref.read(voiceTranscriberProvider).initialize();
      if (mounted) setState(() => _voiceAvailable = available);
    } catch (_) {
      if (mounted) setState(() => _voiceAvailable = false);
    }
  }

  Future<void> _toggleVoice() async {
    final voice = ref.read(voiceTranscriberProvider);
    if (_listening) {
      await voice.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    if (!_voiceAvailable) {
      await _initializeVoice();
      if (!_voiceAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reconhecimento de voz indisponível ou sem permissão.'),
            ),
          );
        }
        return;
      }
    }
    setState(() => _listening = true);
    await voice.start(
      onText: (text) {
        if (!mounted) return;
        _controller
          ..text = text
          ..selection = TextSelection.collapsed(offset: text.length);
      },
      onError: (message) {
        if (!mounted) return;
        setState(() => _listening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reconhecimento de voz: $message')),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending || _controller.text.trim().isEmpty) return;
    final content = _controller.text;
    _controller.clear();
    setState(() => _sending = true);
    try {
      await ref.read(sendMessageProvider)(
        projectId: widget.projectId,
        content: content,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível responder: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(
      conversationMessagesProvider(widget.projectId),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Readiness',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ReadinessScreen(
                  projectId: widget.projectId,
                  title: widget.title,
                ),
              ),
            ),
            icon: const Icon(Icons.fact_check_outlined),
          ),
          IconButton(
            tooltip: 'Documentos',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => DocumentsScreen(
                  projectId: widget.projectId,
                  title: widget.title,
                ),
              ),
            ),
            icon: const Icon(Icons.description_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Erro: $error')),
              data: (items) => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final message = items[index];
                  final isUser = message.role == ConversationMessageRole.user;
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(message.content),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Continue a conversa...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: _listening ? 'Parar gravação' : 'Falar',
                    onPressed: _sending ? null : _toggleVoice,
                    icon: Icon(_listening ? Icons.stop : Icons.mic_none),
                    color: _listening
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                  const SizedBox(width: 4),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final conversationMessagesProvider =
    StreamProvider.family<List<ConversationMessage>, String>(
  (ref, projectId) {
    return ref.watch(conversationRepositoryProvider).watchMessages(projectId);
  },
);
