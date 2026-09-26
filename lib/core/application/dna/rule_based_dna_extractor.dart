import '../../domain/dna/dna_extractor.dart';
import '../../domain/dna/dna_inference.dart';

class RuleBasedDnaExtractor implements DnaExtractor {
  const RuleBasedDnaExtractor();

  @override
  List<DnaInference> extract(String text) {
    final source = text.trim();
    final pattern = RegExp(
      r'(objetivo:|público:|restrição:|decisão:|incerteza:|risco:)',
      caseSensitive: false,
    );
    final matches = pattern.allMatches(source).toList();
    final inferences = <DnaInference>[];

    for (var index = 0; index < matches.length; index++) {
      final match = matches[index];
      final nextStart = index + 1 < matches.length
          ? matches[index + 1].start
          : source.length;
      final value = source.substring(match.end, nextStart).trim();
      if (value.isEmpty) continue;

      final marker = match.group(0)!.toLowerCase();
      final type = switch (marker) {
        'objetivo:' || 'público:' => DnaInferenceType.corePillar,
        'restrição:' => DnaInferenceType.technicalConstraint,
        'decisão:' => DnaInferenceType.decision,
        'incerteza:' => DnaInferenceType.uncertainty,
        'risco:' => DnaInferenceType.risk,
        _ => null,
      };
      if (type == null) continue;

      inferences.add(
        DnaInference(
          type: type,
          key: marker.substring(0, marker.length - 1),
          value: value,
          confidence: 0.99,
          rationale: 'Fato explicitamente marcado pelo usuário.',
        ),
      );
    }
    return inferences;
  }
}
