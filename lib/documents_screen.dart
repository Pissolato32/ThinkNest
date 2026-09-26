import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/domain/document/document.dart';
import 'core/providers/project_providers.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({
    required this.projectId,
    required this.title,
    super.key,
  });

  final String projectId;
  final String title;

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  bool _generating = false;

  Future<void> _generate(DocumentType type) async {
    if (_generating) return;
    setState(() => _generating = true);
    try {
      await ref.read(generateDocumentProvider)(
        projectId: widget.projectId,
        type: type,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Documento gerado a partir do Project DNA.'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível gerar: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _advance(Document document) async {
    final next = switch (document.status) {
      DocumentStatus.generated => DocumentStatus.userReviewed,
      DocumentStatus.userReviewed => DocumentStatus.approved,
      DocumentStatus.approved => DocumentStatus.archived,
      DocumentStatus.draft => DocumentStatus.generated,
      DocumentStatus.archived => null,
    };
    if (next == null) return;

    try {
      await ref.read(changeDocumentStatusProvider)(
        documentId: document.id,
        nextStatus: next,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transição inválida: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final documents = ref.watch(documentsProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(title: Text('Documentos — ${widget.title}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _generating
                        ? null
                        : () => _generate(DocumentType.prd),
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('Gerar PRD'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _generating
                        ? null
                        : () => _generate(DocumentType.architecture),
                    icon: const Icon(Icons.account_tree_outlined),
                    label: const Text('Arquitetura'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: documents.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Erro: $error')),
                data: (items) {
                  if (items.isEmpty) {
                    return const Center(
                      child: Text('Nenhum documento gerado ainda.'),
                    );
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final document = items[index];
                      return ListTile(
                        title: Text(document.title),
                        subtitle: Text(
                          'v${document.version} • DNA v${document.dnaVersion} '
                          '• ${document.status.name}',
                        ),
                        trailing: document.status == DocumentStatus.archived
                            ? null
                            : IconButton(
                                tooltip: 'Avançar lifecycle',
                                onPressed: () => _advance(document),
                                icon: const Icon(Icons.arrow_forward),
                              ),
                        onTap: () => showDialog<void>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(document.title),
                            content: SingleChildScrollView(
                              child: SelectableText(document.content),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Fechar'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
