import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ThinkNest')),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: _QuickCapturePlaceholder(),
        ),
      ),
    );
  }
}

class _QuickCapturePlaceholder extends StatelessWidget {
  const _QuickCapturePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Capture uma ideia.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'O fluxo Capture → Project → Project DNA será implementado nas próximas fatias.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        const TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Escreva sua ideia...',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
