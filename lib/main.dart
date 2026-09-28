import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/project_providers.dart';
import 'conversation_screen.dart';
import 'core/infrastructure/supabase/supabase_config.dart';
import 'core/infrastructure/supabase/supabase_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await const SupabaseInitializer().initialize(SupabaseConfig.fromEnvironment);
  runApp(const ProviderScope(child: ThinkNestApp()));
}

class ThinkNestApp extends StatelessWidget {
  const ThinkNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThinkNest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B5CE2)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  final _controller = TextEditingController();
  bool _saving = false;
  bool _syncing = false;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(ref.read(aiTaskWorkerProvider).start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(aiTaskWorkerProvider).resume());
    }
  }

  Future<void> _sync() async {
    final engine = ref.read(syncEngineProvider);
    if (engine == null || _syncing) return;

    setState(() => _syncing = true);
    try {
      final result = await engine.sync();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sincronização concluída: '
              '${result.pushed} enviados, ${result.pulled} recebidos.',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sincronização não concluída: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleVoiceCapture() async {
    final speech = ref.read(speechCaptureProvider);
    if (_listening) {
      await speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }

    final started = await speech.start(
      onResult: (text, isFinal) {
        if (!mounted || text.trim().isEmpty) return;
        _controller.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
        if (isFinal) {
          unawaited(_finishVoiceCapture());
        }
      },
    );

    if (!mounted) return;
    setState(() => _listening = started);
    if (!started) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Reconhecimento de voz indisponível neste dispositivo.',
          ),
        ),
      );
    }
  }

  Future<void> _finishVoiceCapture() async {
    final speech = ref.read(speechCaptureProvider);
    await speech.stop();
    if (mounted) setState(() => _listening = false);
    await _capture();
  }

  Future<void> _capture() async {
    if (_saving) return;
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    setState(() => _saving = true);
    try {
      await ref.read(createProjectProvider)(
        title: title,
      );
      _controller.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Projeto capturado localmente.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível capturar: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ThinkNest'),
        actions: [
          IconButton(
            tooltip: 'Sincronizar',
            onPressed: ref.watch(syncEngineProvider) == null || _syncing
                ? null
                : _sync,
            icon: _syncing
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.sync),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Capture uma ideia.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Registre primeiro. Estruturamos depois.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                minLines: 3,
                maxLines: 5,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _capture(),
                decoration: const InputDecoration(
                  hintText: 'Escreva sua ideia...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _capture,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add),
                      label: const Text('Capturar ideia'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: _listening ? 'Parar gravação' : 'Capturar por voz',
                    onPressed: _saving ? null : _toggleVoiceCapture,
                    icon: Icon(_listening ? Icons.stop : Icons.mic),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Projetos capturados',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: projects.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text('Erro ao carregar projetos: $error'),
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return const Center(
                        child: Text('Nenhuma ideia capturada ainda.'),
                      );
                    }
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final project = items[index];
                        return ListTile(
                          title: Text(project.title),
                          subtitle: Text(
                            project.maturity.name,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: const Icon(Icons.chat_bubble_outline),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ConversationScreen(
                                projectId: project.id,
                                title: project.title,
                              ),
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
      ),
    );
  }
}
