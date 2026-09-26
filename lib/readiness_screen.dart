import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/domain/readiness/readiness.dart';
import 'core/providers/project_providers.dart';

class ReadinessScreen extends ConsumerWidget {
  const ReadinessScreen({
    required this.projectId,
    required this.title,
    super.key,
  });

  final String projectId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<ReadinessReport>(
      future: ref.read(evaluateReadinessProvider)(projectId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: Text('Readiness — $title')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('Readiness — $title')),
            body: Center(
              child: Text(
                'Não foi possível avaliar readiness: ' +
                snapshot.error.toString(),
              ),
            ),
          );
        }

        final report = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: Text('Readiness — $title')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatusCard(report: report),
              const SizedBox(height: 16),
              Text(
                'Dimensões',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ...report.dimensions.map(
                (dimension) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    dimension.satisfied
                        ? Icons.check_circle_outline
                        : Icons.radio_button_unchecked,
                  ),
                  title: Text(dimension.label),
                  subtitle: dimension.detail == null
                      ? null
                      : Text(dimension.detail!),
                ),
              ),
              if (report.blockers.isNotEmpty) ...[
                const SizedBox(height: 16),
                _FindingsSection(
                  title: 'Blockers',
                  findings: report.blockers,
                ),
              ],
              if (report.warnings.isNotEmpty) ...[
                const SizedBox(height: 16),
                _FindingsSection(
                  title: 'Warnings',
                  findings: report.warnings,
                ),
              ],
              if (report.recommendations.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Recomendações',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ...report.recommendations.map(
                  (recommendation) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.lightbulb_outline),
                    title: Text(recommendation),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.report});

  final ReadinessReport report;

  @override
  Widget build(BuildContext context) {
    final label = switch (report.status) {
      ReadinessStatus.notReady => 'NOT READY',
      ReadinessStatus.readyWithWarnings => 'READY WITH WARNINGS',
      ReadinessStatus.ready => 'READY',
      ReadinessStatus.blocked => 'BLOCKED',
    };

    final icon = switch (report.status) {
      ReadinessStatus.notReady => Icons.hourglass_empty,
      ReadinessStatus.readyWithWarnings => Icons.warning_amber_outlined,
      ReadinessStatus.ready => Icons.check_circle_outline,
      ReadinessStatus.blocked => Icons.block,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estado',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.blockers.length.toString() +
                    ' blocker(s) • ' +
                    report.warnings.length.toString() +
                    ' warning(s)',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FindingsSection extends StatelessWidget {
  const _FindingsSection({
    required this.title,
    required this.findings,
  });

  final String title;
  final List<ReadinessFinding> findings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...findings.map(
          (finding) => Card(
            child: ListTile(
              title: Text(finding.message),
              subtitle: Text(finding.recommendation),
            ),
          ),
        ),
      ],
    );
  }
}
