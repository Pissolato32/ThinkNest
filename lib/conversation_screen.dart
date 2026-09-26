import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/domain/conversation/conversation_message.dart';
import 'core/providers/project_providers.dart';

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
      appBar: AppBar(title: Text(widget.title)),
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
                  const SizedBox(width: 8),
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
